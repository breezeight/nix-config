{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./discord.nix
    ./fira.nix
    ./firefox.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./mako.nix
    ./qt.nix
    ./qutebrowser.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;

  home.packages = with pkgs; [
    dragon-drop
    imv
    pavucontrol
    spotify
    wofi
    xdg-utils
    ydotool
    wl-clipboard
    wf-recorder
    slurp
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

}
