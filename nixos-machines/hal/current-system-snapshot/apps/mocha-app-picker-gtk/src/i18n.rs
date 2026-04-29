// Detecção de idioma e enum `Lang`.
//
// O lookup das strings em si vive no `Catalog` (catalog.rs); aqui só
// resolvemos qual idioma usar com base em variáveis de ambiente.

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Lang {
    PtBr,
    EnUs,
    EsEs,
    FrFr,
}

impl Lang {
    /// Código usado para casar com o nome do arquivo: `strings.pt-BR.toml`.
    pub fn code(self) -> &'static str {
        match self {
            Lang::PtBr => "pt-BR",
            Lang::EnUs => "en-US",
            Lang::EsEs => "es-ES",
            Lang::FrFr => "fr-FR",
        }
    }
}

/// Tenta extrair um `Lang` de um valor estilo locale (ex.: "pt_BR.UTF-8").
fn lang_from_value(value: &str) -> Option<Lang> {
    let normalized = value.trim().replace('-', "_").to_ascii_lowercase();

    if normalized.starts_with("pt_br") || normalized == "pt" || normalized.starts_with("pt_") {
        return Some(Lang::PtBr);
    }
    if normalized.starts_with("en_us") || normalized == "en" || normalized.starts_with("en_") {
        return Some(Lang::EnUs);
    }
    if normalized.starts_with("es_es") || normalized == "es" || normalized.starts_with("es_") {
        return Some(Lang::EsEs);
    }
    if normalized.starts_with("fr_fr") || normalized == "fr" || normalized.starts_with("fr_") {
        return Some(Lang::FrFr);
    }

    None
}

/// Detecta o idioma na ordem MOCHA_LANG → LC_ALL → LC_MESSAGES → LANG.
/// Default: en-US.
pub fn detect() -> Lang {
    for key in ["MOCHA_LANG", "LC_ALL", "LC_MESSAGES", "LANG"] {
        if let Ok(value) = std::env::var(key) {
            if let Some(lang) = lang_from_value(&value) {
                return lang;
            }
        }
    }
    Lang::EnUs
}
