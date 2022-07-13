{ pkgs, lib, config, outputs, hostname, ... }:
let
  user = "misterio";
  cage = "${pkgs.cage}/bin/cage";
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  homeConfig = outputs.homeConfigurations."misterio@${hostname}".config;

  hasSteam = config.programs.steam.enable;
  hasSway = homeConfig.wayland.windowManager.sway.enable;
  hasHyprland = homeConfig.wayland.windowManager.hyprland.enable;

  kioskCmd = "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    exec "${gtkgreet} -l; ${pkgs.sway}/bin/swaymsg exit"
  ''}";
in
{
  environment.systemPackages = [ pkgs.cage ];
  environment.etc."greetd/environments".text =
    (lib.optionalString hasSway ''sway
    '') +
    (lib.optionalString hasHyprland ''Hyprland
    '') +
    (lib.optionalString hasSteam ''cage -- steam -bigpicture
    '') +
    ''$SHELL
    '';
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        inherit user;
        command = "${kioskCmd} &> /dev/null";
      };
      initial_session = {
        inherit user;
        command =
          if hasSway then "sway"
          else if hasHyprland then "Hyprland"
          else "$SHELL -l";
      };
    };
  };
}
