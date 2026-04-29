// Bootstrap do Mocha App Picker GTK.
//
// Responsabilidades:
//   1. detectar idioma
//   2. resolver diretório do catálogo (env var / system / ./catalog)
//   3. carregar o catálogo
//   4. iniciar a Application e delegar a construção da janela para `ui::build`
//
// Em caso de falha no catálogo, mostra um diálogo de erro e fecha.

use adw::prelude::*;

mod catalog;
mod i18n;
mod installer;
mod nix_writer;
mod state;
mod ui;

fn main() {
    let app = adw::Application::builder()
        .application_id("org.dieseloslab.MochaAppPickerGtk")
        .build();

    app.connect_activate(activate);
    app.run();
}

fn activate(app: &adw::Application) {
    let lang = i18n::detect();
    let dir = catalog::resolve_catalog_dir();

    match catalog::load(&dir, lang) {
        Ok(cat) => ui::build(app, cat),
        Err(err) => {
            // Sem Catalog não dá pra traduzir nem o título do erro;
            // usamos texto fixo em inglês — é só fallback de bootstrap.
            let window = adw::ApplicationWindow::new(app);
            window.set_title(Some("Mocha App Picker — error"));
            window.set_default_size(600, 200);

            let label = gtk::Label::new(Some(&format!(
                "Failed to load catalog from {}:\n\n{}",
                dir.display(),
                err
            )));
            label.set_wrap(true);
            label.set_margin_top(24);
            label.set_margin_bottom(24);
            label.set_margin_start(24);
            label.set_margin_end(24);

            window.set_content(Some(&label));
            window.present();
        }
    }
}
