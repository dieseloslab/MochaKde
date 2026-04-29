# /etc/nixos/modules/snapshots-btrfs.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Snapshots Btrfs com interface grafica.
#
# Objetivo:
# - usuario comum nao precisar usar linha de comando;
# - Btrfs Assistant como ferramenta grafica principal;
# - Snapper como motor dos snapshots;
# - politica automatica de retencao;
# - snapshots antes/depois de rebuild via comando mocha-rebuild-switch.
#
# Observacao:
# - /home esta em XFS, portanto nao entra nos snapshots Btrfs;
# - o foco inicial e o sistema raiz "/";
# - rollback principal do NixOS continua pelas geracoes;
# - snapshots Btrfs protegem o estado do filesystem.

{ pkgs, ... }:

let
  mochaSnapshotPre = pkgs.writeShellScriptBin "mocha-snapshot-pre" ''
    set -euo pipefail

    desc="pre: ''${*:-manual}"
    exec ${pkgs.snapper}/bin/snapper \
      --config root \
      create \
      --cleanup-algorithm number \
      --description "$desc"
  '';

  mochaSnapshotPost = pkgs.writeShellScriptBin "mocha-snapshot-post" ''
    set -euo pipefail

    desc="post: ''${*:-manual}"
    exec ${pkgs.snapper}/bin/snapper \
      --config root \
      create \
      --cleanup-algorithm number \
      --description "$desc"
  '';

  mochaRebuildSwitch = pkgs.writeShellScriptBin "mocha-rebuild-switch" ''
    set -euo pipefail

    echo "===== MOCHA: SNAPSHOT PRE-REBUILD ====="
    ${pkgs.snapper}/bin/snapper \
      --config root \
      create \
      --cleanup-algorithm number \
      --description "pre: nixos-rebuild switch"

    echo
    echo "===== MOCHA: NIXOS-REBUILD SWITCH ====="
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild \
      switch \
      --flake /etc/nixos#diesel-os-lab \
      --show-trace

    echo
    echo "===== MOCHA: SNAPSHOT POS-REBUILD ====="
    ${pkgs.snapper}/bin/snapper \
      --config root \
      create \
      --cleanup-algorithm number \
      --description "post: nixos-rebuild switch"

    echo
    echo "===== MOCHA: REBUILD FINALIZADO COM SNAPSHOTS ====="
  '';
in
{
  environment.systemPackages = with pkgs; [
    btrfs-progs
    btrfs-assistant
    snapper
    snapper-gui

    mochaSnapshotPre
    mochaSnapshotPost
    mochaRebuildSwitch
  ];

  security.polkit.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.snapper = {
    snapshotRootOnBoot = true;

    configs.root = {
      SUBVOLUME = "/";
      FSTYPE = "btrfs";

      ALLOW_USERS = [ "hal" ];
      ALLOW_GROUPS = [ "wheel" ];

      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;

      NUMBER_CLEANUP = true;
      NUMBER_MIN_AGE = 1800;
      NUMBER_LIMIT = 20;
      NUMBER_LIMIT_IMPORTANT = 10;

      EMPTY_PRE_POST_CLEANUP = true;

      TIMELINE_MIN_AGE = 1800;
      TIMELINE_LIMIT_HOURLY = 10;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };
}
