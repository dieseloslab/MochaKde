# /etc/nixos/modules/user-hal.nix

{ ... }:

{
  users.users.hal = {
    isNormalUser = true;
    description = "hal";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.activationScripts.halAvatar = {
    text = ''
      install -d -m 0755 /var/lib/AccountsService
      install -d -m 0755 /var/lib/AccountsService/icons
      install -d -m 0700 /var/lib/AccountsService/users

      install -m 0644 /etc/nixos/assets/branding/avatar/avatar.png /var/lib/AccountsService/icons/hal.png

      cat > /var/lib/AccountsService/users/hal <<'AVATAR_EOF'
      [User]
      Icon=/var/lib/AccountsService/icons/hal.png
      AVATAR_EOF

      chmod 0644 /var/lib/AccountsService/icons/hal.png
      chmod 0600 /var/lib/AccountsService/users/hal
    '';
  };
}
