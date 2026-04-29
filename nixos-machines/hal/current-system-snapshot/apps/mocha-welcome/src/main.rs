use adw::prelude::*;
use gtk::prelude::*;
use std::env;
use std::process::Command;

const APP_ID: &str = "org.dieseloslab.MochaWelcome";
const DONE_FILE: &str = "/var/lib/mocha-first-boot/public-first-boot.done";
const BRAND_LOGO_PATH: &str =
    "/run/current-system/sw/share/diesel-os-lab/branding/logo/diesel-os-lab-icon.png";
const DONATE_URL: &str =
    "https://www.paypal.com/donate/?business=RE5E2EWMKAFBW&no_recurring=0&currency_code=BRL";

#[derive(Clone, Copy)]
enum Lang {
    PtBr,
    EnUs,
    EsEs,
    FrFr,
}

fn detect_lang() -> Lang {
    let raw = env::var("MOCHA_LANG")
        .or_else(|_| env::var("LC_ALL"))
        .or_else(|_| env::var("LC_MESSAGES"))
        .or_else(|_| env::var("LANG"))
        .unwrap_or_else(|_| String::from("en_US"));

    let normalized = raw
        .split('.')
        .next()
        .unwrap_or("en_US")
        .split('@')
        .next()
        .unwrap_or("en_US");

    match normalized {
        "pt_BR" => Lang::PtBr,
        "en_US" => Lang::EnUs,
        "es_ES" => Lang::EsEs,
        "fr_FR" => Lang::FrFr,
        value if value.starts_with("pt") => Lang::PtBr,
        value if value.starts_with("en") => Lang::EnUs,
        value if value.starts_with("es") => Lang::EsEs,
        value if value.starts_with("fr") => Lang::FrFr,
        _ => Lang::EnUs,
    }
}

fn tr(lang: Lang, key: &str) -> &'static str {
    match (lang, key) {
        (Lang::PtBr, "window_title") => "Mocha Welcome",
        (Lang::EnUs, "window_title") => "Mocha Welcome",
        (Lang::EsEs, "window_title") => "Mocha Welcome",
        (Lang::FrFr, "window_title") => "Mocha Welcome",

        (Lang::PtBr, "title") => "Bem-vindo ao Mocha",
        (Lang::EnUs, "title") => "Welcome to Mocha",
        (Lang::EsEs, "title") => "Bienvenido a Mocha",
        (Lang::FrFr, "title") => "Bienvenue dans Mocha",

        (Lang::PtBr, "subtitle") => "Diesel OS Lab - GNOME Mocha Edition",
        (Lang::EnUs, "subtitle") => "Diesel OS Lab - GNOME Mocha Edition",
        (Lang::EsEs, "subtitle") => "Diesel OS Lab - GNOME Mocha Edition",
        (Lang::FrFr, "subtitle") => "Diesel OS Lab - GNOME Mocha Edition",

        (Lang::PtBr, "intro") => {
            "Este assistente prepara o sistema para o primeiro uso: permissões do usuário, Firefox, IBus, senha, aplicativos opcionais e snapshot de segurança."
        }
        (Lang::EnUs, "intro") => {
            "This assistant prepares the system for first use: user permissions, Firefox, IBus, password, optional apps and a safety snapshot."
        }
        (Lang::EsEs, "intro") => {
            "Este asistente prepara el sistema para el primer uso: permisos del usuario, Firefox, IBus, contraseña, aplicaciones opcionales y snapshot de seguridad."
        }
        (Lang::FrFr, "intro") => {
            "Cet assistant prépare le système pour la première utilisation : permissions utilisateur, Firefox, IBus, mot de passe, applications optionnelles et instantané de sécurité."
        }

        (Lang::PtBr, "ready") => "Pronto para começar.",
        (Lang::EnUs, "ready") => "Ready to start.",
        (Lang::EsEs, "ready") => "Listo para comenzar.",
        (Lang::FrFr, "ready") => "Prêt à commencer.",

        (Lang::PtBr, "running") => "Executando...",
        (Lang::EnUs, "running") => "Running...",
        (Lang::EsEs, "running") => "Ejecutando...",
        (Lang::FrFr, "running") => "Exécution...",

        (Lang::PtBr, "check") => "Verificar sistema",
        (Lang::EnUs, "check") => "Check system",
        (Lang::EsEs, "check") => "Verificar sistema",
        (Lang::FrFr, "check") => "Vérifier le système",

        (Lang::PtBr, "fix") => "Corrigir permissões",
        (Lang::EnUs, "fix") => "Fix permissions",
        (Lang::EsEs, "fix") => "Corregir permisos",
        (Lang::FrFr, "fix") => "Corriger les permissions",

        (Lang::PtBr, "password") => "Trocar senha",
        (Lang::EnUs, "password") => "Change password",
        (Lang::EsEs, "password") => "Cambiar contraseña",
        (Lang::FrFr, "password") => "Changer le mot de passe",

        (Lang::PtBr, "apps") => "Abrir App Picker",
        (Lang::EnUs, "apps") => "Open App Picker",
        (Lang::EsEs, "apps") => "Abrir App Picker",
        (Lang::FrFr, "apps") => "Ouvrir App Picker",

        (Lang::PtBr, "donate") => "Doar para o projeto",
        (Lang::EnUs, "donate") => "Donate to the project",
        (Lang::EsEs, "donate") => "Donar al proyecto",
        (Lang::FrFr, "donate") => "Faire un don au projet",

        (Lang::PtBr, "donate_note") => {
            "As doações ajudam a manter o desenvolvimento do Diesel OS Lab e também apoiam a missão social do projeto: beneficiar entidades, crianças e famílias ligadas à síndrome de Down, incluindo acesso a atendimentos especializados de alta qualidade quando o custo impedir esse cuidado."
        }
        (Lang::EnUs, "donate_note") => {
            "Donations help sustain Diesel OS Lab development and also support the project’s social mission: helping organizations, children and families connected to Down syndrome, including access to high-quality specialized care when cost prevents that support."
        }
        (Lang::EsEs, "donate_note") => {
            "Las donaciones ayudan a mantener el desarrollo de Diesel OS Lab y también apoyan la misión social del proyecto: beneficiar a entidades, niños y familias vinculadas al síndrome de Down, incluyendo acceso a atención especializada de alta calidad cuando el costo impide ese cuidado."
        }
        (Lang::FrFr, "donate_note") => {
            "Les dons aident à soutenir le développement de Diesel OS Lab et la mission sociale du projet : aider des organisations, des enfants et des familles liés à la trisomie 21, y compris l’accès à des soins spécialisés de haute qualité lorsque le coût empêche cet accompagnement."
        }

        (Lang::PtBr, "finish") => "Finalizar primeiro boot",
        (Lang::EnUs, "finish") => "Finish first boot",
        (Lang::EsEs, "finish") => "Finalizar primer arranque",
        (Lang::FrFr, "finish") => "Terminer le premier démarrage",

        (Lang::PtBr, "password_note") => {
            "Por segurança, troque a senha temporária pelo painel do GNOME. Senhas muito fracas podem ser bloqueadas."
        }
        (Lang::EnUs, "password_note") => {
            "For security, change the temporary password in GNOME Settings. Very weak passwords may be blocked."
        }
        (Lang::EsEs, "password_note") => {
            "Por seguridad, cambie la contraseña temporal en Configuración de GNOME. Las contraseñas muy débiles pueden ser bloqueadas."
        }
        (Lang::FrFr, "password_note") => {
            "Pour la sécurité, changez le mot de passe temporaire dans les Paramètres GNOME. Les mots de passe très faibles peuvent être bloqués."
        }

        (Lang::PtBr, "done") => "Primeiro boot público concluído.",
        (Lang::EnUs, "done") => "Public first boot completed.",
        (Lang::EsEs, "done") => "Primer arranque público completado.",
        (Lang::FrFr, "done") => "Premier démarrage public terminé.",

        _ => "Missing translation",
    }
}

fn current_user() -> String {
    env::var("SUDO_USER")
        .ok()
        .filter(|value| !value.is_empty() && value != "root")
        .or_else(|| env::var("USER").ok())
        .filter(|value| !value.is_empty() && value != "root")
        .unwrap_or_else(|| String::from("hal"))
}

fn current_home() -> String {
    env::var("HOME").unwrap_or_else(|_| format!("/home/{}", current_user()))
}

fn shell_quote(value: &str) -> String {
    format!("'{}'", value.replace('\'', "'\"'\"'"))
}

fn run_shell(command: &str) -> String {
    match Command::new("sh").arg("-c").arg(command).output() {
        Ok(output) => {
            let mut text = String::new();

            if !output.stdout.is_empty() {
                text.push_str(&String::from_utf8_lossy(&output.stdout));
            }

            if !output.stderr.is_empty() {
                text.push_str(&String::from_utf8_lossy(&output.stderr));
            }

            if text.trim().is_empty() {
                text.push_str("OK\n");
            }

            text
        }
        Err(error) => format!("ERROR: {}\n", error),
    }
}

fn run_pkexec_shell(command: &str) -> String {
    match Command::new("pkexec").arg("sh").arg("-c").arg(command).output() {
        Ok(output) => {
            let mut text = String::new();

            if !output.stdout.is_empty() {
                text.push_str(&String::from_utf8_lossy(&output.stdout));
            }

            if !output.stderr.is_empty() {
                text.push_str(&String::from_utf8_lossy(&output.stderr));
            }

            if text.trim().is_empty() {
                text.push_str("OK\n");
            }

            text
        }
        Err(error) => format!("ERROR: {}\n", error),
    }
}

fn check_system() -> String {
    let user = current_user();
    let home = current_home();

    let command = format!(
        r#"
echo "User: {user}"
echo "Home: {home}"
echo
echo "Kernel:"
uname -r
echo
echo "Operating system:"
grep -E '^(NAME|PRETTY_NAME|VERSION|VERSION_ID)=' /etc/os-release || true
echo
echo "Home permissions:"
ls -ld {home_q} 2>/dev/null || true
ls -ld {home_q}/.mozilla 2>/dev/null || true
ls -ld {home_q}/.config {home_q}/.config/ibus {home_q}/.config/ibus/bus 2>/dev/null || true
echo
echo "First boot marker:"
if [ -f {done_q} ]; then
  echo "Completed: {done}"
else
  echo "Not completed yet"
fi
"#,
        user = user,
        home = home,
        home_q = shell_quote(&home),
        done_q = shell_quote(DONE_FILE),
        done = DONE_FILE,
    );

    run_shell(&command)
}

fn privileged_fix_command(user: &str, home: &str) -> String {
    format!(
        r#"
set -eu

USER_NAME={user_q}
USER_HOME={home_q}
USER_GROUP="$(id -gn "$USER_NAME" 2>/dev/null || echo users)"

mkdir -p "$USER_HOME"
chown "$USER_NAME:$USER_GROUP" "$USER_HOME"
chmod 700 "$USER_HOME"

mkdir -p "$USER_HOME/.config/ibus/bus"
chown -R "$USER_NAME:$USER_GROUP" "$USER_HOME/.config"
chmod 700 "$USER_HOME/.config" 2>/dev/null || true
chmod 700 "$USER_HOME/.config/ibus" 2>/dev/null || true
chmod 700 "$USER_HOME/.config/ibus/bus" 2>/dev/null || true

mkdir -p "$USER_HOME/.mozilla"
chown -R "$USER_NAME:$USER_GROUP" "$USER_HOME/.mozilla"
find "$USER_HOME/.mozilla" -type d -exec chmod 700 {{}} \; 2>/dev/null || true
find "$USER_HOME/.mozilla" -type f -exec chmod 600 {{}} \; 2>/dev/null || true
find "$USER_HOME/.mozilla" -name '.parentlock' -delete 2>/dev/null || true
find "$USER_HOME/.mozilla" -name 'lock' -type l -delete 2>/dev/null || true

echo "OK: permissions fixed for $USER_NAME"
echo "OK: Firefox profile directory prepared"
echo "OK: IBus directory prepared"
"#,
        user_q = shell_quote(user),
        home_q = shell_quote(home),
    )
}

fn fix_permissions() -> String {
    let user = current_user();
    let home = current_home();
    let command = privileged_fix_command(&user, &home);

    run_pkexec_shell(&command)
}

fn open_password_settings() -> String {
    let command = r#"
if command -v gnome-control-center >/dev/null 2>&1; then
  nohup gnome-control-center users >/dev/null 2>&1 &
  echo "OK: opened GNOME Users settings"
else
  echo "GNOME Control Center not found"
fi
"#;

    run_shell(command)
}

fn open_app_picker() -> String {
    let command = r#"
if command -v mocha-app-picker-gtk >/dev/null 2>&1; then
  nohup mocha-app-picker-gtk >/dev/null 2>&1 &
  echo "OK: opened mocha-app-picker-gtk"
elif command -v mocha-app-picker >/dev/null 2>&1; then
  nohup mocha-app-picker >/dev/null 2>&1 &
  echo "OK: opened mocha-app-picker"
else
  echo "Mocha App Picker not found yet"
fi
"#;

    run_shell(command)
}

fn open_donate_url() -> String {
    let command = format!(
        r#"
if command -v xdg-open >/dev/null 2>&1; then
  nohup xdg-open {url_q} >/dev/null 2>&1 &
  echo "OK: opened donation page"
else
  echo "xdg-open not found"
fi
"#,
        url_q = shell_quote(DONATE_URL),
    );

    run_shell(&command)
}

fn finish_first_boot() -> String {
    let user = current_user();
    let home = current_home();

    let fix = privileged_fix_command(&user, &home);

    let command = format!(
        r#"
{fix}

mkdir -p /var/lib/mocha-first-boot

cat > {done_q} <<EOF
Diesel OS Lab - GNOME Mocha Edition
Public first boot completed at: $(date -Is)
User: {user}
EOF

echo "OK: marked first boot as completed"

if command -v snapper >/dev/null 2>&1; then
  snapper create --description "Mocha public first boot completed" 2>/dev/null || true
  echo "OK: safety snapshot requested"
else
  echo "INFO: snapper not found, snapshot skipped"
fi

echo "OK: finish routine completed"
"#,
        fix = fix,
        done_q = shell_quote(DONE_FILE),
        user = user,
    );

    run_pkexec_shell(&command)
}

fn set_output(buffer: &gtk::TextBuffer, text: &str) {
    buffer.set_text(text);
}

fn append_output(buffer: &gtk::TextBuffer, text: &str) {
    let current = buffer
        .text(&buffer.start_iter(), &buffer.end_iter(), false)
        .to_string();

    let combined = if current.trim().is_empty() {
        text.to_string()
    } else {
        format!("{}\n{}", current, text)
    };

    buffer.set_text(&combined);
}

fn build_ui(app: &adw::Application) {
    let lang = detect_lang();

    let window = adw::ApplicationWindow::builder()
        .application(app)
        .title(tr(lang, "window_title"))
        .default_width(820)
        .default_height(640)
        .build();

    let header = adw::HeaderBar::new();

    let logo = gtk::Image::from_file(BRAND_LOGO_PATH);
    logo.set_pixel_size(96);
    logo.set_halign(gtk::Align::Center);
    logo.set_margin_bottom(4);

    let title = gtk::Label::new(Some(tr(lang, "title")));
    title.add_css_class("title-1");
    title.set_halign(gtk::Align::Center);

    let subtitle = gtk::Label::new(Some(tr(lang, "subtitle")));
    subtitle.add_css_class("title-4");
    subtitle.set_halign(gtk::Align::Center);

    let intro = gtk::Label::new(Some(tr(lang, "intro")));
    intro.set_wrap(true);
    intro.set_halign(gtk::Align::Start);
    intro.add_css_class("dim-label");

    let button_box = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    button_box.set_halign(gtk::Align::Start);

    let check_button = gtk::Button::with_label(tr(lang, "check"));
    let fix_button = gtk::Button::with_label(tr(lang, "fix"));
    let password_button = gtk::Button::with_label(tr(lang, "password"));
    let apps_button = gtk::Button::with_label(tr(lang, "apps"));
    let donate_button = gtk::Button::with_label(tr(lang, "donate"));
    donate_button.set_halign(gtk::Align::Start);

    let donate_note = gtk::Label::new(Some(tr(lang, "donate_note")));
    donate_note.set_wrap(true);
    donate_note.set_halign(gtk::Align::Start);
    donate_note.add_css_class("dim-label");

    let finish_button = gtk::Button::with_label(tr(lang, "finish"));
    finish_button.add_css_class("suggested-action");

    button_box.append(&check_button);
    button_box.append(&fix_button);
    button_box.append(&password_button);
    button_box.append(&apps_button);
    button_box.append(&finish_button);

    let password_note = gtk::Label::new(Some(tr(lang, "password_note")));
    password_note.set_wrap(true);
    password_note.set_halign(gtk::Align::Start);
    password_note.add_css_class("dim-label");

    let output_view = gtk::TextView::new();
    output_view.set_editable(false);
    output_view.set_monospace(true);
    output_view.set_wrap_mode(gtk::WrapMode::WordChar);

    let output_buffer = output_view.buffer();
    output_buffer.set_text(tr(lang, "ready"));

    let scrolled = gtk::ScrolledWindow::builder()
        .vexpand(true)
        .hexpand(true)
        .child(&output_view)
        .build();

    let content = gtk::Box::new(gtk::Orientation::Vertical, 18);
    content.set_margin_top(24);
    content.set_margin_bottom(24);
    content.set_margin_start(24);
    content.set_margin_end(24);

    content.append(&logo);
    content.append(&title);
    content.append(&subtitle);
    content.append(&intro);
    content.append(&button_box);
    content.append(&password_note);
    content.append(&donate_note);
    content.append(&donate_button);
    content.append(&scrolled);

    let root = gtk::Box::new(gtk::Orientation::Vertical, 0);
    root.append(&header);
    root.append(&content);

    window.set_content(Some(&root));

    let buffer = output_buffer.clone();
    check_button.connect_clicked(move |_| {
        set_output(&buffer, tr(lang, "running"));
        let result = check_system();
        set_output(&buffer, &result);
    });

    let buffer = output_buffer.clone();
    fix_button.connect_clicked(move |_| {
        set_output(&buffer, tr(lang, "running"));
        let result = fix_permissions();
        set_output(&buffer, &result);
    });

    let buffer = output_buffer.clone();
    password_button.connect_clicked(move |_| {
        let result = open_password_settings();
        append_output(&buffer, &result);
    });

    let buffer = output_buffer.clone();
    apps_button.connect_clicked(move |_| {
        let result = open_app_picker();
        append_output(&buffer, &result);
    });

    let buffer = output_buffer.clone();
    donate_button.connect_clicked(move |_| {
        let result = open_donate_url();
        append_output(&buffer, &result);
    });

    let buffer = output_buffer.clone();
    finish_button.connect_clicked(move |_| {
        set_output(&buffer, tr(lang, "running"));
        let result = finish_first_boot();
        let final_text = format!("{}\n\n{}", result, tr(lang, "done"));
        set_output(&buffer, &final_text);
    });

    window.present();
}

fn main() {
    let app = adw::Application::builder()
        .application_id(APP_ID)
        .build();

    app.connect_activate(build_ui);
    app.run();
}
