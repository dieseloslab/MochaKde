// Geração do arquivo `optional-apps.nix` a partir da seleção do usuário.
//
// O arquivo gerado tem dois blocos sob `lib.mkMerge`:
//   1. environment.systemPackages, com pacotes nixpkgs.
//   2. blocos `lib.optionalAttrs` para serviços especiais selecionados.
//
// As linhas de service são hardcoded por `app.id`, porque cada serviço
// tem uma forma própria no NixOS. Adicionar um novo serviço significa:
// adicionar caso em `special_service_entry` + caso correspondente em
// `state.rs::has_special`.

use std::collections::BTreeSet;

use crate::catalog::{App, Backend};
use crate::i18n::Lang;

/// Pega o subset de `apps` que está em `selected_ids`.
pub fn selected<'a>(apps: &'a [App], selected_ids: &[String]) -> Vec<&'a App> {
    apps.iter()
        .filter(|a| selected_ids.iter().any(|id| id == &a.id))
        .collect()
}

/// Entrada especial de serviço para um app special.
/// Retorna: nome da variável booleana no let + linha Nix do serviço.
fn special_service_entry(app_id: &str) -> Option<(&'static str, &'static str)> {
    match app_id {
        "teamviewer" => Some(("hasTeamViewerService", "services.teamviewer.enable = true;")),
        "anydesk" => Some(("hasAnyDeskService", "services.anydesk.enable = true;")),
        "virtualbox" => Some((
            "hasVirtualBoxHost",
            "virtualisation.virtualbox.host.enable = true;",
        )),
        "vmware" => Some(("hasVmwareHost", "virtualisation.vmware.host.enable = true;")),
        _ => None,
    }
}

/// Comentário no topo do arquivo gerado, traduzido.
fn header_comment(lang: Lang) -> (&'static str, &'static str) {
    match lang {
        Lang::PtBr => (
            "Este arquivo é gerenciado pelo Mocha App Picker.",
            "Programas opcionais escolhidos pelo usuário após a instalação.",
        ),
        Lang::EnUs => (
            "This file is managed by Mocha App Picker.",
            "Optional programs selected by the user after installation.",
        ),
        Lang::EsEs => (
            "Este archivo es gestionado por Mocha App Picker.",
            "Programas opcionales seleccionados por el usuario después de la instalación.",
        ),
        Lang::FrFr => (
            "Ce fichier est géré par Mocha App Picker.",
            "Programmes optionnels sélectionnés par l'utilisateur après l'installation.",
        ),
    }
}

pub fn generate(lang: Lang, apps: &[App], selected_ids: &[String]) -> String {
    let chosen = selected(apps, selected_ids);

    // Pacotes: vêm de Backend::Nixpkgs e de Backend::Special com pkg não-vazio.
    // BTreeSet garante ordem estável e dedup, importante para cmp -s detectar
    // "sem mudanças" e pular o nixos-rebuild.
    let mut packages: BTreeSet<&str> = BTreeSet::new();
    let mut services: BTreeSet<(&str, &str)> = BTreeSet::new();

    for app in &chosen {
        match app.backend {
            Backend::Nixpkgs => {
                packages.insert(app.pkg.as_str());
            }
            Backend::Special => {
                if !app.pkg.is_empty() {
                    packages.insert(app.pkg.as_str());
                }
                if let Some(entry) = special_service_entry(&app.id) {
                    services.insert(entry);
                }
            }
            Backend::Flatpak => {
                // Flatpaks não vão para o arquivo Nix; são tratados pelo installer.
            }
        }
    }

    let (line1, line2) = header_comment(lang);
    let mut out = String::new();

    out.push_str("# /etc/nixos/modules/optional-apps.nix\n");
    out.push_str("#\n");
    out.push_str("# Diesel OS Lab - GNOME Mocha Edition\n");
    out.push_str("#\n");
    out.push_str("# ");
    out.push_str(line1);
    out.push('\n');
    out.push_str("# ");
    out.push_str(line2);
    out.push_str("\n\n");

    out.push_str("{ pkgs, lib, options, ... }:\n\n");
    out.push_str("let\n");
    out.push_str("  hasTeamViewerService = options.services ? teamviewer;\n");
    out.push_str("  hasAnyDeskService = options.services ? anydesk;\n");
    out.push_str("  hasVirtualBoxHost = (options.virtualisation ? virtualbox) && (options.virtualisation.virtualbox ? host);\n");
    out.push_str("  hasVmwareHost = (options.virtualisation ? vmware) && (options.virtualisation.vmware ? host);\n");
    out.push_str("in\n");
    out.push_str("lib.mkMerge [\n");
    out.push_str("  {\n");
    out.push_str("    environment.systemPackages = with pkgs; [\n");

    for pkg in &packages {
        out.push_str("      ");
        out.push_str(pkg);
        out.push('\n');
    }

    out.push_str("    ];\n");
    out.push_str("  }\n");

    for (condition, line) in &services {
        out.push_str("  (lib.optionalAttrs ");
        out.push_str(condition);
        out.push_str(" {\n");
        out.push_str("    ");
        out.push_str(line);
        out.push('\n');
        out.push_str("  })\n");
    }

    out.push_str("]\n");

    out
}
