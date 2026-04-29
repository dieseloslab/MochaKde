// Parser do catálogo TOML do Mocha App Picker.
//
// Lê três tipos de arquivo de um diretório:
//   - apps.toml                       (lista de apps, schema fixo)
//   - strings.<lang>.toml             (UI + nomes/descrições por idioma)
//   - notes.<lang>.toml               (notas técnicas opcionais por idioma)
//
// O resultado é um `Catalog` já resolvido para um idioma específico:
// cada `App` carrega name/desc traduzidos e, se tiver `note_key`,
// a `Note` correspondente.

use serde::Deserialize;
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

use crate::i18n::Lang;

// ============================================================
// Schema bruto dos arquivos TOML (deserializado por serde).
// ============================================================

#[derive(Debug, Deserialize)]
struct AppsFile {
    #[serde(default)]
    app: Vec<AppRaw>,
}

#[derive(Debug, Deserialize, Clone)]
struct AppRaw {
    id: String,
    pkg: String,
    tab: String,
    backend: String,
    #[serde(default)]
    note_key: Option<String>,
}

#[derive(Debug, Deserialize)]
struct StringsFile {
    #[serde(default)]
    ui: BTreeMap<String, String>,
    #[serde(default)]
    tabs: BTreeMap<String, String>,
    #[serde(default)]
    apps: BTreeMap<String, AppStrings>,
}

#[derive(Debug, Deserialize, Clone)]
struct AppStrings {
    name: String,
    desc: String,
}

#[derive(Debug, Deserialize)]
struct NotesFile {
    #[serde(flatten)]
    entries: BTreeMap<String, NoteRaw>,
}

#[derive(Debug, Deserialize, Clone)]
struct NoteRaw {
    #[serde(default = "default_level")]
    level: String,
    title: String,
    body: String,
}

fn default_level() -> String {
    "info".to_string()
}

// ============================================================
// Tipos públicos (já resolvidos para um idioma).
// ============================================================

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Backend {
    Nixpkgs,
    Flatpak,
    Special,
}

impl Backend {
    fn parse(value: &str) -> Result<Self, String> {
        match value {
            "nixpkgs" => Ok(Backend::Nixpkgs),
            "flatpak" => Ok(Backend::Flatpak),
            "special" => Ok(Backend::Special),
            other => Err(format!("backend desconhecido: {}", other)),
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Backend::Nixpkgs => "Nix",
            Backend::Flatpak => "Flatpak",
            Backend::Special => "Special",
        }
    }
}

#[derive(Debug, Clone)]
pub enum NoteLevel {
    Info,
    Warning,
    Caution,
}

impl NoteLevel {
    fn parse(value: &str) -> Self {
        match value {
            "warning" => NoteLevel::Warning,
            "caution" => NoteLevel::Caution,
            _ => NoteLevel::Info,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Note {
    pub level: NoteLevel,
    pub title: String,
    pub body: String,
}

#[derive(Debug, Clone)]
pub struct App {
    pub id: String,
    pub pkg: String,
    pub tab: String,
    pub backend: Backend,
    pub name: String,
    pub desc: String,
    pub note: Option<Note>,
}

#[derive(Debug, Clone)]
pub struct Tab {
    pub id: String,
    pub title: String,
}

#[derive(Debug, Clone)]
pub struct Catalog {
    pub lang: Lang,
    pub ui: BTreeMap<String, String>,
    pub tabs: Vec<Tab>,
    pub apps: Vec<App>,
}

impl Catalog {
    /// Retorna a string da seção [ui] ou uma fallback (a própria key) se ausente.
    /// Permitir fallback evita crash em produção quando faltar uma chave;
    /// a chave aparece literalmente na UI, o que é fácil de notar e corrigir.
    pub fn ui_str(&self, key: &str) -> String {
        self.ui
            .get(key)
            .cloned()
            .unwrap_or_else(|| format!("[{}]", key))
    }
}

// ============================================================
// Carregamento.
// ============================================================

/// Resolve o diretório do catálogo na seguinte ordem:
///   1. variável de ambiente `MOCHA_CATALOG_DIR` (útil em dev: `cargo run`)
///   2. `/run/current-system/sw/share/mocha-app-picker-gtk/catalog`
///   3. `./catalog` (último recurso, pra rodar a partir do source tree)
pub fn resolve_catalog_dir() -> PathBuf {
    if let Ok(value) = std::env::var("MOCHA_CATALOG_DIR") {
        let path = PathBuf::from(value);
        if path.is_dir() {
            return path;
        }
    }

    let system_path = PathBuf::from("/run/current-system/sw/share/mocha-app-picker-gtk/catalog");
    if system_path.is_dir() {
        return system_path;
    }

    PathBuf::from("./catalog")
}

/// Carrega o catálogo completo já resolvido para `lang`.
pub fn load(dir: &Path, lang: Lang) -> Result<Catalog, String> {
    let apps_raw = load_apps(dir)?;
    let strings = load_strings(dir, lang)?;
    let notes = load_notes(dir, lang)?;

    // Tabs: derivadas dos apps, na ordem em que aparecem em apps.toml,
    // com título vindo de strings[tabs]. Tabs sem string definida caem
    // num placeholder visível em vez de quebrar.
    let mut seen_tabs = Vec::<String>::new();
    for app in &apps_raw {
        if !seen_tabs.contains(&app.tab) {
            seen_tabs.push(app.tab.clone());
        }
    }
    let tabs: Vec<Tab> = seen_tabs
        .into_iter()
        .map(|id| {
            let title = strings
                .tabs
                .get(&id)
                .cloned()
                .unwrap_or_else(|| format!("[{}]", id));
            Tab { id, title }
        })
        .collect();

    let mut apps: Vec<App> = Vec::with_capacity(apps_raw.len());
    for raw in apps_raw {
        let backend = Backend::parse(&raw.backend)
            .map_err(|e| format!("app {}: {}", raw.id, e))?;

        let app_strings = strings.apps.get(&raw.id).cloned().unwrap_or(AppStrings {
            name: raw.id.clone(),
            desc: String::new(),
        });

        let note = raw
            .note_key
            .as_ref()
            .and_then(|k| notes.entries.get(k))
            .cloned()
            .map(|raw_note| Note {
                level: NoteLevel::parse(&raw_note.level),
                title: raw_note.title,
                body: raw_note.body,
            });

        apps.push(App {
            id: raw.id,
            pkg: raw.pkg,
            tab: raw.tab,
            backend,
            name: app_strings.name,
            desc: app_strings.desc,
            note,
        });
    }

    Ok(Catalog {
        lang,
        ui: strings.ui,
        tabs,
        apps,
    })
}

fn load_apps(dir: &Path) -> Result<Vec<AppRaw>, String> {
    let path = dir.join("apps.toml");
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("não foi possível ler {}: {}", path.display(), e))?;
    let parsed: AppsFile = toml::from_str(&content)
        .map_err(|e| format!("erro de parse em {}: {}", path.display(), e))?;
    Ok(parsed.app)
}

fn load_strings(dir: &Path, lang: Lang) -> Result<StringsFile, String> {
    let path = dir.join(format!("strings.{}.toml", lang.code()));
    let content = fs::read_to_string(&path)
        .map_err(|e| format!("não foi possível ler {}: {}", path.display(), e))?;
    toml::from_str(&content)
        .map_err(|e| format!("erro de parse em {}: {}", path.display(), e))
}

fn load_notes(dir: &Path, lang: Lang) -> Result<NotesFile, String> {
    let path = dir.join(format!("notes.{}.toml", lang.code()));

    // notes é opcional: se não existir, retorna vazio.
    if !path.exists() {
        return Ok(NotesFile {
            entries: BTreeMap::new(),
        });
    }

    let content = fs::read_to_string(&path)
        .map_err(|e| format!("não foi possível ler {}: {}", path.display(), e))?;
    toml::from_str(&content)
        .map_err(|e| format!("erro de parse em {}: {}", path.display(), e))
}
