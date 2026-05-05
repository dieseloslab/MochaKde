{ pkgs, ... }:

let
  mochaSteamRun = pkgs.writeShellScriptBin "mocha-steam-run" ''
    set -e
    export MANGOHUD=1
    export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
    export DXVK_STATE_CACHE=1
    exec "$@"
  '';

  mochaSteamRunGamemode = pkgs.writeShellScriptBin "mocha-steam-run-gamemode" ''
    set -e
    export MANGOHUD=1
    export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
    export DXVK_STATE_CACHE=1
    exec gamemoderun "$@"
  '';
in
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  environment.systemPackages = with pkgs; [
    steam
    steam-run
    mangohud
    gamemode
    gamescope
    protonup-qt
    protontricks
    winetricks
    vulkan-tools
    goverlay
    mochaSteamRun
    mochaSteamRunGamemode
  ];

  system.activationScripts.mochaMangoHudUserConfig.text = ''
    install -d -m 0755 -o hal -g users /home/hal/.config/MangoHud

    cat > /home/hal/.config/MangoHud/MangoHud.conf <<'EOF_MANGOHUD'
legacy_layout=0
horizontal
table_columns=20
position=top-left
font_size=20
background_alpha=0.35

fps
frametime

gpu_stats
gpu_temp
gpu_core_clock
gpu_mem_clock
gpu_power
vram

cpu_stats
cpu_temp
cpu_mhz
ram

gamemode
vulkan_driver
wine

time
time_format=%H:%M
EOF_MANGOHUD

    chown hal:users /home/hal/.config/MangoHud/MangoHud.conf
    chmod 0644 /home/hal/.config/MangoHud/MangoHud.conf
  '';
}
