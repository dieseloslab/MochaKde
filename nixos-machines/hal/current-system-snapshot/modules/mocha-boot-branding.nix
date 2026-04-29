# /etc/nixos/modules/mocha-boot-branding.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Branding visivel no boot e nos labels das geracoes.
# Objetivo:
#   - mostrar "Diesel OS Lab - Mocha Edition";
#   - remover aparencia ".dirty" do label exibido no boot.

{ lib, ... }:

{
  system.nixos.distroName = lib.mkForce "Diesel OS Lab - Mocha Edition";

  system.nixos.variantName = lib.mkForce "Mocha Edition";
  system.nixos.variant_id = lib.mkForce "mocha";

  # Label tecnico usado em nomes de geracoes/boot.
  # Nao pode conter espacos.
  system.nixos.label = lib.mkForce "Diesel-OS-Lab-Mocha-Edition";

  boot.initrd.stage1Greeting = lib.mkForce "<<< Diesel OS Lab - Mocha Edition Stage 1 >>>";
  boot.stage2Greeting = lib.mkForce "<<< Diesel OS Lab - Mocha Edition >>>";
}
