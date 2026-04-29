// Renderiza uma linha (ListBoxRow) para um App do catálogo.

use std::cell::RefCell;
use std::collections::BTreeSet;
use std::rc::Rc;

use adw::prelude::*;
use gtk::prelude::*;

use crate::catalog::{App, Catalog};
use crate::ui::dialogs;

/// Tipo do registro de seleção: lista global de (app_id, checkbox).
/// Usado pelo window.rs pra coletar os IDs marcados ao clicar "Aplicar".
pub type SelectionRegistry = Rc<RefCell<Vec<(String, gtk::CheckButton)>>>;

pub fn build_row(
    window: &adw::ApplicationWindow,
    catalog: &Catalog,
    app: &App,
    selection: SelectionRegistry,
    installed_ids: &BTreeSet<String>,
) -> gtk::ListBoxRow {
    let row = gtk::ListBoxRow::new();

    let outer = gtk::Box::new(gtk::Orientation::Horizontal, 12);
    outer.set_margin_top(10);
    outer.set_margin_bottom(10);
    outer.set_margin_start(12);
    outer.set_margin_end(12);

    let check = gtk::CheckButton::new();
    check.set_active(installed_ids.contains(&app.id));
    selection
        .borrow_mut()
        .push((app.id.clone(), check.clone()));

    let text_box = gtk::Box::new(gtk::Orientation::Vertical, 4);
    text_box.set_hexpand(true);

    let title = gtk::Label::new(Some(&app.name));
    title.set_xalign(0.0);
    title.add_css_class("heading");

    let desc = gtk::Label::new(Some(&app.desc));
    desc.set_xalign(0.0);
    desc.set_wrap(true);

    let backend_text = format!("{}: {}", catalog.ui_str("source"), app.backend.label());
    let backend_label = gtk::Label::new(Some(&backend_text));
    backend_label.set_xalign(0.0);
    backend_label.add_css_class("dim-label");

    text_box.append(&title);
    text_box.append(&desc);
    text_box.append(&backend_label);

    outer.append(&check);
    outer.append(&text_box);

    // Botão "Detalhes" só aparece se o app tiver uma Note resolvida.
    // O botão fica à direita, alinhado verticalmente ao centro.
    if let Some(note) = app.note.clone() {
        let details_btn = gtk::Button::with_label(&catalog.ui_str("btn_details"));
        details_btn.set_valign(gtk::Align::Center);
        details_btn.add_css_class("flat");

        let window_clone = window.clone();
        let close_label = catalog.ui_str("btn_close");
        details_btn.connect_clicked(move |_| {
            dialogs::show_note(&window_clone, &note, &close_label);
        });

        outer.append(&details_btn);
    }

    row.set_child(Some(&outer));
    row
}
