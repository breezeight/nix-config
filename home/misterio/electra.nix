{ inputs, outputs, ... }:
{
  imports = [
    ./global
    ./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/pass
  ];

  wallpaper = outputs.wallpapers.aenami-wait;
  colorscheme = inputs.nix-colors.colorSchemes.silk-dark;

  monitors = [
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      x = 0;
    }
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1920;
      primary = true;
    }
  ];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
