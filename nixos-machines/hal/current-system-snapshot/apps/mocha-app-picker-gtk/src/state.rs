// Lê o estado atual do sistema para saber o que já está instalado.
//
// Duas fontes:
//   1. /etc/nixos/modules/optional-apps.nix  -> pacotes nix + services especiais
//   2. `flatpak info --system <id>`          -> apps flatpak
//
// O resultado é um conjunto de `app.id` que devem aparecer marcados na UI.

use std::collections::BTreeSet;
use std::fs;
use std::process::{Command, Stdio};

use crate::catalog::{App, Backend};

pub const OPTIONAL_APPS_PATH: &str = "/etc/nixos/modules/optional-apps.nix";
const FLATPAK: &str = "/run/current-system/sw/bin/flatpak";

/// Retorna o set de IDs (`app.id`) atualmente instalados.
pub fn installed_app_ids(apps: &[App]) -> BTreeSet<String> {
    let nix_content = fs::read_to_string(OPTIONAL_APPS_PATH).unwrap_or_default();
    let mut installed = BTreeSet::new();

    for app in apps {
        if is_app_installed(app, &nix_content) {
            installed.insert(app.id.clone());
        }
    }

    installed
}

fn is_app_installed(app: &App, nix_content: &str) -> bool {
    match app.backend {
        Backend::Nixpkgs => has_package(nix_content, &app.pkg),
        Backend::Flatpak => flatpak_is_installed(&app.pkg),
        Backend::Special => has_special(nix_content, &app.id),
    }
}

/// Pacote aparece como linha solta na lista `environment.systemPackages`.
/// O writer escreve um pacote por linha; após trim, é só o nome.
fn has_package(nix_content: &str, pkg: &str) -> bool {
    nix_content.lines().any(|line| line.trim() == pkg)
}

/// Specials: detectados pela linha de service correspondente ao `app.id`.
/// Esta tabela tem que casar com a de `nix_writer.rs::special_service_entry`.
///
/// Para VMware, TeamViewer, AnyDesk e VirtualBox, o estado do serviço/opção
/// declarativa é o indicador principal de que a opção está ativa no sistema.
fn has_special(nix_content: &str, app_id: &str) -> bool {
    let needle = match app_id {
        "teamviewer" => "services.teamviewer.enable = true;",
        "anydesk" => "services.anydesk.enable = true;",
        "virtualbox" => "virtualisation.virtualbox.host.enable = true;",
        "vmware" => "virtualisation.vmware.host.enable = true;",
        _ => return false,
    };

    nix_content.contains(needle)
}

pub fn flatpak_is_installed(flatpak_id: &str) -> bool {
    Command::new(FLATPAK)
        .arg("info")
        .arg("--system")
        .arg(flatpak_id)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|status| status.success())
        .unwrap_or(false)
}
