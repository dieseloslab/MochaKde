imports.gi.versions.Gtk = "4.0";
imports.gi.versions.Adw = "1";

const { Adw, Gio, GLib, Gtk } = imports.gi;
const ByteArray = imports.byteArray;

const APP_ID = "org.dieseloslab.MochaDonationReminder";
const DONATE_URL = "https://www.paypal.com/donate/?business=RE5E2EWMKAFBW&no_recurring=0&currency_code=BRL";
const BRAND_LOGO_PATH = "/run/current-system/sw/share/diesel-os-lab/branding/logo/diesel-os-lab-icon.png";
const INTERVAL_SECONDS = 30 * 24 * 60 * 60;

const STRINGS = {
    pt_BR: {
        window_title: "Apoie o Diesel OS Lab",
        title: "Apoie o Diesel OS Lab",
        subtitle: "GNOME Mocha Edition",
        message:
            "As doações ajudam a manter o desenvolvimento do Diesel OS Lab e também apoiam a missão social do projeto: beneficiar entidades, crianças e famílias ligadas à síndrome de Down, incluindo acesso a atendimentos especializados de alta qualidade quando o custo impedir esse cuidado.",
        donate: "Doar agora",
        later: "Agora não",
        opened: "Página de doação aberta no navegador.",
    },
    en_US: {
        window_title: "Support Diesel OS Lab",
        title: "Support Diesel OS Lab",
        subtitle: "GNOME Mocha Edition",
        message:
            "Donations help sustain Diesel OS Lab development and also support the project’s social mission: helping organizations, children and families connected to Down syndrome, including access to high-quality specialized care when cost prevents that support.",
        donate: "Donate now",
        later: "Not now",
        opened: "Donation page opened in the browser.",
    },
    es_ES: {
        window_title: "Apoya Diesel OS Lab",
        title: "Apoya Diesel OS Lab",
        subtitle: "GNOME Mocha Edition",
        message:
            "Las donaciones ayudan a mantener el desarrollo de Diesel OS Lab y también apoyan la misión social del proyecto: beneficiar a entidades, niños y familias vinculadas al síndrome de Down, incluyendo acceso a atención especializada de alta calidad cuando el costo impide ese cuidado.",
        donate: "Donar ahora",
        later: "Ahora no",
        opened: "Página de donación abierta en el navegador.",
    },
    fr_FR: {
        window_title: "Soutenir Diesel OS Lab",
        title: "Soutenir Diesel OS Lab",
        subtitle: "GNOME Mocha Edition",
        message:
            "Les dons aident à soutenir le développement de Diesel OS Lab et la mission sociale du projet : aider des organisations, des enfants et des familles liés à la trisomie 21, y compris l’accès à des soins spécialisés de haute qualité lorsque le coût empêche cet accompagnement.",
        donate: "Faire un don",
        later: "Pas maintenant",
        opened: "Page de don ouverte dans le navigateur.",
    },
};

function detectLang() {
    const raw =
        GLib.getenv("MOCHA_LANG") ||
        GLib.getenv("LC_ALL") ||
        GLib.getenv("LC_MESSAGES") ||
        GLib.getenv("LANG") ||
        "en_US";

    const normalized = raw.split(".")[0].split("@")[0];

    if (normalized === "pt_BR" || normalized.startsWith("pt")) return "pt_BR";
    if (normalized === "es_ES" || normalized.startsWith("es")) return "es_ES";
    if (normalized === "fr_FR" || normalized.startsWith("fr")) return "fr_FR";
    return "en_US";
}

const LANG = detectLang();

function tr(key) {
    return (STRINGS[LANG] && STRINGS[LANG][key]) || STRINGS.en_US[key] || key;
}

function stateDir() {
    return GLib.build_filenamev([
        GLib.get_user_state_dir(),
        "diesel-os-lab",
        "mocha-donation-reminder",
    ]);
}

function lastShownPath() {
    return GLib.build_filenamev([stateDir(), "last-shown"]);
}

function nowSeconds() {
    return Math.floor(Date.now() / 1000);
}

function shouldShow(force) {
    if (force) return true;

    const file = Gio.File.new_for_path(lastShownPath());

    if (!file.query_exists(null)) {
        return true;
    }

    try {
        const [, contents] = file.load_contents(null);
        const text = ByteArray.toString(contents).trim();
        const lastShown = parseInt(text, 10);

        if (!Number.isFinite(lastShown)) {
            return true;
        }

        return nowSeconds() - lastShown >= INTERVAL_SECONDS;
    } catch (error) {
        return true;
    }
}

function markShown() {
    GLib.mkdir_with_parents(stateDir(), 0o700);
    GLib.file_set_contents(lastShownPath(), String(nowSeconds()) + "\n");
}

function openDonationPage() {
    try {
        Gio.AppInfo.launch_default_for_uri(DONATE_URL, null);
        return true;
    } catch (error) {
        return false;
    }
}

function buildWindow(app) {
    markShown();

    const window = new Adw.ApplicationWindow({
        application: app,
        title: tr("window_title"),
        default_width: 560,
        default_height: 420,
    });

    const header = new Adw.HeaderBar();

    const logo = Gtk.Image.new_from_file(BRAND_LOGO_PATH);
    logo.set_pixel_size(96);
    logo.set_halign(Gtk.Align.CENTER);
    logo.set_margin_bottom(4);

    const title = new Gtk.Label({
        label: tr("title"),
        halign: Gtk.Align.CENTER,
    });
    title.add_css_class("title-1");

    const subtitle = new Gtk.Label({
        label: tr("subtitle"),
        halign: Gtk.Align.CENTER,
    });
    subtitle.add_css_class("title-4");
    subtitle.add_css_class("dim-label");

    const message = new Gtk.Label({
        label: tr("message"),
        wrap: true,
        max_width_chars: 56,
        halign: Gtk.Align.CENTER,
        justify: Gtk.Justification.CENTER,
    });

    const donateButton = new Gtk.Button({
        label: tr("donate"),
    });
    donateButton.add_css_class("suggested-action");

    const laterButton = new Gtk.Button({
        label: tr("later"),
    });

    const buttonBox = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 12,
        halign: Gtk.Align.CENTER,
    });
    buttonBox.append(laterButton);
    buttonBox.append(donateButton);

    const content = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 16,
        margin_top: 28,
        margin_bottom: 28,
        margin_start: 28,
        margin_end: 28,
    });

    content.append(logo);
    content.append(title);
    content.append(subtitle);
    content.append(message);
    content.append(buttonBox);

    const root = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 0,
    });
    root.append(header);
    root.append(content);

    window.set_content(root);

    donateButton.connect("clicked", () => {
        openDonationPage();
        window.close();
    });

    laterButton.connect("clicked", () => {
        window.close();
    });

    window.connect("close-request", () => {
        app.quit();
        return false;
    });

    window.present();
}

Adw.init();

const force = ARGV.includes("--force");

const app = new Adw.Application({
    application_id: APP_ID,
    flags: Gio.ApplicationFlags.FLAGS_NONE,
});

app.connect("activate", () => {
    if (!shouldShow(force)) {
        app.quit();
        return;
    }

    buildWindow(app);
});

app.run(ARGV);
