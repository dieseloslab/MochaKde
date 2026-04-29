// Backend de instalação: gera arquivos temporários, escreve um script bash
// e roda via pkexec.
//
// O script bash:
//   1. compara o optional-apps.nix gerado com o atual; se mudou, instala e roda nixos-rebuild
//   2. desinstala flatpaks que estavam instalados mas foram desmarcados
//   3. instala flatpaks novos selecionados (via flathub)
//
// Toda string visível ao usuário (mensagens do script, log) vem do `Catalog`,
// usando ui_str() para fallback amigável se faltar tradução.
//
// O arquivo de progresso é atualizado por fases para que a UI mostre uma
// barra determinada, em vez de uma barra indeterminada/pulsante.

use std::collections::BTreeSet;
use std::fs;
use std::process::Command;

use crate::catalog::{App, Backend, Catalog};
use crate::nix_writer;
use crate::state::{flatpak_is_installed, OPTIONAL_APPS_PATH};

const PKEXEC: &str = "/run/wrappers/bin/pkexec";
const BASH: &str = "/run/current-system/sw/bin/bash";
const NIXOS_REBUILD: &str = "/run/current-system/sw/bin/nixos-rebuild";
const FLATPAK: &str = "/run/current-system/sw/bin/flatpak";
const INSTALL: &str = "/run/current-system/sw/bin/install";
const CMP: &str = "/run/current-system/sw/bin/cmp";
const GREP: &str = "/run/current-system/sw/bin/grep";

pub fn progress_path() -> String {
    if let Ok(runtime_dir) = std::env::var("XDG_RUNTIME_DIR") {
        let runtime_dir = runtime_dir.trim();

        if !runtime_dir.is_empty() {
            return format!(
                "{}/mocha-app-picker-gtk-progress-{}.txt",
                runtime_dir,
                std::process::id()
            );
        }
    }

    format!(
        "/tmp/mocha-app-picker-gtk-progress-{}.txt",
        std::process::id()
    )
}

fn write_progress_file(path: &str, fraction: f64, message: &str) {
    let fraction = fraction.clamp(0.0, 1.0);
    let _ = fs::write(path, format!("{:.2}|{}\n", fraction, message));
}

/// Calcula listas de flatpak a instalar e a remover.
fn flatpak_diff(apps: &[App], selected_ids: &[String]) -> (Vec<String>, Vec<String>) {
    let desired: BTreeSet<String> = nix_writer::selected(apps, selected_ids)
        .iter()
        .filter(|a| a.backend == Backend::Flatpak)
        .map(|a| a.pkg.clone())
        .collect();

    let existing: BTreeSet<String> = apps
        .iter()
        .filter(|a| a.backend == Backend::Flatpak)
        .filter(|a| flatpak_is_installed(&a.pkg))
        .map(|a| a.pkg.clone())
        .collect();

    let to_install: Vec<String> = desired.difference(&existing).cloned().collect();
    let to_remove: Vec<String> = existing.difference(&desired).cloned().collect();

    (to_install, to_remove)
}

fn write_lines(path: &str, lines: &[String]) -> Result<(), String> {
    let mut content = String::new();

    for line in lines {
        content.push_str(line);
        content.push('\n');
    }

    fs::write(path, content).map_err(|err| format!("{}: {}", path, err))
}

fn tail_log(log_path: &str, count: usize) -> String {
    let content = fs::read_to_string(log_path).unwrap_or_default();

    if content.trim().is_empty() {
        return log_path.to_string();
    }

    let lines: Vec<&str> = content.lines().collect();
    let start = lines.len().saturating_sub(count);

    lines[start..].join("\n")
}

fn write_install_script(
    catalog: &Catalog,
    temp_config: &str,
    flatpak_install_list: &str,
    flatpak_remove_list: &str,
    progress_file: &str,
    log_path: &str,
    script_path: &str,
) -> Result<(), String> {
    let script = format!(
        r#"#!/usr/bin/env bash
set -euo pipefail

LOG="{log}"
TEMP_CONFIG="{temp_config}"
FLATPAK_INSTALL_LIST="{flatpak_install_list}"
FLATPAK_REMOVE_LIST="{flatpak_remove_list}"
PROGRESS_FILE="{progress_file}"
DEST="{dest}"

progress() {{
  printf '%s|%s\n' "$1" "$2" > "$PROGRESS_FILE"
}}

exec > "$LOG" 2>&1

progress "0.30" "{script_title}"
echo "{script_title}"
echo

if [ -f "$DEST" ] && "{cmp}" -s "$TEMP_CONFIG" "$DEST"; then
  progress "0.45" "{script_no_nix_changes}"
  echo "{script_no_nix_changes}"
  echo "{script_skip_rebuild}"
else
  progress "0.40" "{script_write_nix} $DEST"
  echo "{script_write_nix} $DEST..."
  "{install}" -m 0644 "$TEMP_CONFIG" "$DEST"

  progress "0.55" "{script_apply_rebuild}"
  echo
  echo "{script_apply_rebuild}"
  cd /etc/nixos
  export NIX_CONFIG='experimental-features = nix-command flakes'
  "{nixos_rebuild}" switch --flake /etc/nixos#diesel-os-lab --show-trace
fi

if [ -s "$FLATPAK_REMOVE_LIST" ]; then
  progress "0.75" "{script_remove_flatpak_selected}"
  echo
  echo "{script_remove_flatpak_selected}"

  while IFS= read -r app_id; do
    [ -z "$app_id" ] && continue

    if "{flatpak}" info --system "$app_id" >/dev/null 2>&1; then
      echo "{script_uninstall_flatpak}: $app_id"
      "{flatpak}" uninstall --system -y "$app_id"
    else
      echo "{script_flatpak_not_installed}: $app_id"
    fi
  done < "$FLATPAK_REMOVE_LIST"
else
  progress "0.75" "{script_no_flatpak_remove}"
  echo
  echo "{script_no_flatpak_remove}"
fi

if [ -s "$FLATPAK_INSTALL_LIST" ]; then
  progress "0.82" "{script_ensure_flathub}"
  echo
  echo "{script_ensure_flathub}"

  if ! "{flatpak}" remotes --system --columns=name | "{grep}" -qx 'flathub'; then
    "{flatpak}" remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi

  progress "0.88" "{script_install_flatpak_selected}"
  echo
  echo "{script_install_flatpak_selected}"

  while IFS= read -r app_id; do
    [ -z "$app_id" ] && continue

    if "{flatpak}" info --system "$app_id" >/dev/null 2>&1; then
      echo "{script_flatpak_already}: $app_id"
    else
      echo "{script_install_flatpak}: $app_id"
      "{flatpak}" install --system -y flathub "$app_id"
    fi
  done < "$FLATPAK_INSTALL_LIST"
else
  progress "0.88" "{script_no_flatpak}"
  echo
  echo "{script_no_flatpak}"
fi

progress "1.00" "{script_success}"
echo
echo "{script_success}"
"#,
        log = log_path,
        temp_config = temp_config,
        flatpak_install_list = flatpak_install_list,
        flatpak_remove_list = flatpak_remove_list,
        progress_file = progress_file,
        dest = OPTIONAL_APPS_PATH,
        cmp = CMP,
        install = INSTALL,
        nixos_rebuild = NIXOS_REBUILD,
        flatpak = FLATPAK,
        grep = GREP,
        script_title = catalog.ui_str("script.title"),
        script_no_nix_changes = catalog.ui_str("script.no_nix_changes"),
        script_skip_rebuild = catalog.ui_str("script.skip_rebuild"),
        script_write_nix = catalog.ui_str("script.write_nix"),
        script_apply_rebuild = catalog.ui_str("script.apply_rebuild"),
        script_remove_flatpak_selected = catalog.ui_str("script.remove_flatpak_selected"),
        script_flatpak_not_installed = catalog.ui_str("script.flatpak_not_installed"),
        script_uninstall_flatpak = catalog.ui_str("script.uninstall_flatpak"),
        script_no_flatpak_remove = catalog.ui_str("script.no_flatpak_remove"),
        script_ensure_flathub = catalog.ui_str("script.ensure_flathub"),
        script_install_flatpak_selected = catalog.ui_str("script.install_flatpak_selected"),
        script_flatpak_already = catalog.ui_str("script.flatpak_already"),
        script_install_flatpak = catalog.ui_str("script.install_flatpak"),
        script_no_flatpak = catalog.ui_str("script.no_flatpak"),
        script_success = catalog.ui_str("script.success"),
    );

    fs::write(script_path, script).map_err(|err| err.to_string())
}

/// Executa todo o pipeline de instalação. Retorna mensagem amigável ou erro.
pub fn run(catalog: &Catalog, selected_ids: &[String]) -> Result<String, String> {
    let pid = std::process::id();

    let temp_config = format!("/tmp/mocha-app-picker-gtk-optional-apps-{}.nix", pid);
    let flatpak_install_list = format!("/tmp/mocha-app-picker-gtk-flatpaks-install-{}.txt", pid);
    let flatpak_remove_list = format!("/tmp/mocha-app-picker-gtk-flatpaks-remove-{}.txt", pid);
    let script_path = format!("/tmp/mocha-app-picker-gtk-install-{}.sh", pid);
    let log_path = format!("/tmp/mocha-app-picker-gtk-install-{}.log", pid);
    let progress_file = progress_path();

    let _ = fs::remove_file(&progress_file);
    write_progress_file(&progress_file, 0.10, &catalog.ui_str("install.running"));

    let optional_content = nix_writer::generate(catalog.lang, &catalog.apps, selected_ids);
    let (flatpaks_to_install, flatpaks_to_remove) = flatpak_diff(&catalog.apps, selected_ids);

    write_progress_file(&progress_file, 0.18, &catalog.ui_str("script.write_nix"));
    fs::write(&temp_config, optional_content).map_err(|err| err.to_string())?;

    write_lines(&flatpak_install_list, &flatpaks_to_install)?;
    write_lines(&flatpak_remove_list, &flatpaks_to_remove)?;

    write_progress_file(&progress_file, 0.24, &catalog.ui_str("install.running"));
    write_install_script(
        catalog,
        &temp_config,
        &flatpak_install_list,
        &flatpak_remove_list,
        &progress_file,
        &log_path,
        &script_path,
    )?;

    write_progress_file(&progress_file, 0.28, &catalog.ui_str("install.running"));

    let status = Command::new(PKEXEC)
        .arg(BASH)
        .arg(&script_path)
        .status()
        .map_err(|err| err.to_string())?;

    if status.success() {
        write_progress_file(&progress_file, 1.0, &catalog.ui_str("install.success"));

        Ok(format!(
            "{}\n\n{}:\n{}",
            catalog.ui_str("install.success"),
            catalog.ui_str("install.log"),
            log_path
        ))
    } else {
        let tail = tail_log(&log_path, 100);

        Err(format!(
            "{}\n\nStatus: {}\n\n{}:\n{}\n\n{}:\n{}",
            catalog.ui_str("install.failed"),
            status,
            catalog.ui_str("install.log"),
            log_path,
            catalog.ui_str("install.log"),
            tail
        ))
    }
}
