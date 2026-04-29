// Janela principal e fluxo de instalação assíncrono.

use std::cell::RefCell;
use std::collections::BTreeSet;
use std::fs;
use std::rc::Rc;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use adw::prelude::*;
use gtk::prelude::*;

use crate::catalog::{Catalog, Tab};
use crate::installer;
use crate::state;
use crate::ui::app_row::{self, SelectionRegistry};
use crate::ui::dialogs;

pub fn build(app: &adw::Application, catalog: Catalog) {
    adw::StyleManager::default().set_color_scheme(adw::ColorScheme::ForceDark);

    let installed_ids = state::installed_app_ids(&catalog.apps);
    let selection: SelectionRegistry = Rc::new(RefCell::new(Vec::new()));

    let window = adw::ApplicationWindow::new(app);
    window.set_title(Some(&catalog.ui_str("window_title")));
    window.set_default_size(1080, 720);

    let main_box = gtk::Box::new(gtk::Orientation::Vertical, 12);
    main_box.set_margin_top(12);
    main_box.set_margin_bottom(12);
    main_box.set_margin_start(12);
    main_box.set_margin_end(12);

    let title = gtk::Label::new(Some(&catalog.ui_str("window_title")));
    title.add_css_class("title-1");
    title.set_xalign(0.0);

    let subtitle = gtk::Label::new(Some(&catalog.ui_str("subtitle")));
    subtitle.add_css_class("dim-label");
    subtitle.set_xalign(0.0);

    let stack = gtk::Stack::new();
    stack.set_vexpand(true);

    for tab in &catalog.tabs {
        let page = build_tab_page(&window, &catalog, tab, selection.clone(), &installed_ids);
        stack.add_titled(&page, Some(&tab.id), &tab.title);
    }

    let switcher = gtk::StackSwitcher::new();
    switcher.set_stack(Some(&stack));

    let button_box = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    button_box.set_halign(gtk::Align::End);

    let close_button = gtk::Button::with_label(&catalog.ui_str("btn_close"));
    let install_button = gtk::Button::with_label(&catalog.ui_str("btn_apply"));
    install_button.add_css_class("suggested-action");

    let progress_bar = gtk::ProgressBar::new();
    progress_bar.set_visible(false);
    progress_bar.set_show_text(true);

    let status_label = gtk::Label::new(None);
    status_label.set_xalign(0.0);
    status_label.add_css_class("dim-label");
    status_label.set_visible(false);

    {
        let window = window.clone();
        close_button.connect_clicked(move |_| window.close());
    }

    wire_install_button(
        &install_button,
        &window,
        &catalog,
        selection.clone(),
        &progress_bar,
        &status_label,
    );

    button_box.append(&close_button);
    button_box.append(&install_button);

    main_box.append(&title);
    main_box.append(&subtitle);
    main_box.append(&switcher);
    main_box.append(&stack);
    main_box.append(&status_label);
    main_box.append(&progress_bar);
    main_box.append(&button_box);

    window.set_content(Some(&main_box));
    window.present();
}

fn build_tab_page(
    window: &adw::ApplicationWindow,
    catalog: &Catalog,
    tab: &Tab,
    selection: SelectionRegistry,
    installed_ids: &BTreeSet<String>,
) -> gtk::ScrolledWindow {
    let list = gtk::ListBox::new();
    list.add_css_class("boxed-list");

    for app in catalog.apps.iter().filter(|a| a.tab == tab.id) {
        list.append(&app_row::build_row(
            window,
            catalog,
            app,
            selection.clone(),
            installed_ids,
        ));
    }

    let scrolled = gtk::ScrolledWindow::new();
    scrolled.set_child(Some(&list));

    scrolled
}

fn read_progress(path: &str) -> Option<(f64, String)> {
    let content = fs::read_to_string(path).ok()?;
    let line = content.lines().last()?.trim();
    let (fraction, message) = line.split_once('|')?;
    let fraction = fraction.parse::<f64>().ok()?.clamp(0.0, 1.0);

    Some((fraction, message.to_string()))
}

/// Conecta o botão "Aplicar" ao fluxo de instalação.
/// A barra agora é determinada: ela acompanha fases gravadas pelo backend em
/// um arquivo temporário de progresso.
fn wire_install_button(
    install_button: &gtk::Button,
    window: &adw::ApplicationWindow,
    catalog: &Catalog,
    selection: SelectionRegistry,
    progress_bar: &gtk::ProgressBar,
    status_label: &gtk::Label,
) {
    let apply_label = catalog.ui_str("btn_apply");
    let running_label = catalog.ui_str("install.running");
    let backend_disconnected = catalog.ui_str("install.backend_disconnected");

    let catalog_for_click = catalog.clone();
    let window_for_click = window.clone();
    let install_button_for_click = install_button.clone();
    let progress_bar_for_click = progress_bar.clone();
    let status_label_for_click = status_label.clone();

    install_button.connect_clicked(move |_| {
        let chosen: Vec<String> = selection
            .borrow()
            .iter()
            .filter_map(|(id, check)| {
                if check.is_active() {
                    Some(id.clone())
                } else {
                    None
                }
            })
            .collect();

        let progress_path = installer::progress_path();
        let _ = fs::remove_file(&progress_path);

        install_button_for_click.set_sensitive(false);
        install_button_for_click.set_label(&running_label);

        progress_bar_for_click.set_visible(true);
        progress_bar_for_click.set_fraction(0.02);
        progress_bar_for_click.set_text(Some("2%"));

        status_label_for_click.set_visible(true);
        status_label_for_click.set_label(&running_label);

        let catalog_for_thread = catalog_for_click.clone();
        let (sender, receiver) = mpsc::channel::<Result<String, String>>();

        thread::spawn(move || {
            let result = installer::run(&catalog_for_thread, &chosen);
            let _ = sender.send(result);
        });

        let window_for_result = window_for_click.clone();
        let button_for_result = install_button_for_click.clone();
        let apply_label_for_result = apply_label.clone();
        let progress_bar_for_result = progress_bar_for_click.clone();
        let status_label_for_result = status_label_for_click.clone();
        let backend_disconnected_for_result = backend_disconnected.clone();
        let progress_path_for_timer = progress_path.clone();

        gtk::glib::timeout_add_local(Duration::from_millis(300), move || {
            if let Some((fraction, message)) = read_progress(&progress_path_for_timer) {
                progress_bar_for_result.set_fraction(fraction);
                progress_bar_for_result.set_text(Some(&format!("{:.0}%", fraction * 100.0)));
                status_label_for_result.set_label(&message);
            }

            match receiver.try_recv() {
                Ok(result) => {
                    button_for_result.set_sensitive(true);
                    button_for_result.set_label(&apply_label_for_result);

                    progress_bar_for_result.set_fraction(1.0);
                    progress_bar_for_result.set_text(Some("100%"));
                    progress_bar_for_result.set_visible(false);
                    status_label_for_result.set_visible(false);

                    match result {
                        Ok(message) => dialogs::show_message(
                            &window_for_result,
                            gtk::MessageType::Info,
                            &message,
                        ),
                        Err(message) => dialogs::show_message(
                            &window_for_result,
                            gtk::MessageType::Error,
                            &message,
                        ),
                    }

                    gtk::glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => gtk::glib::ControlFlow::Continue,
                Err(mpsc::TryRecvError::Disconnected) => {
                    button_for_result.set_sensitive(true);
                    button_for_result.set_label(&apply_label_for_result);

                    progress_bar_for_result.set_visible(false);
                    status_label_for_result.set_visible(false);

                    dialogs::show_message(
                        &window_for_result,
                        gtk::MessageType::Error,
                        &backend_disconnected_for_result,
                    );

                    gtk::glib::ControlFlow::Break
                }
            }
        });
    });
}
