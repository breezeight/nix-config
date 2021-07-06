{ config, pkgs, lib, fetchFromGithub, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };
  # New: Load the module
  impermanence = builtins.fetchTarball {
    url =
      "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };
in {
  imports = [
      "${home-manager}/nixos"
  ];
  nixpkgs.overlays = [
    (import ./overlays/flavours.nix)
  ];
  home-manager.useUserPackages = true;
  home-manager.users.misterio = {
    imports = [ "${impermanence}/home-manager.nix" ];
    programs.home-manager.enable = true;

    home.packages = [
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
      (pkgs.pass.withExtensions (ext: with ext; [pass-otp]))
      pkgs.flavours
      pkgs.fira
      pkgs.fira-code
      pkgs.steam
      pkgs.qutebrowser
      pkgs.dragon-drop
      pkgs.bottom
      pkgs.jq
      pkgs.pulseaudio
      pkgs.playerctl
      pkgs.swaylock
      pkgs.swayidle
      pkgs.swaybg
      pkgs.sway-contrib.grimshot
      pkgs.slurp
      pkgs.grim
      pkgs.glxinfo
      pkgs.neofetch
      pkgs.neovim-remote
      pkgs.wl-clipboard
      pkgs.inkscape
      pkgs.spotify
      pkgs.xorg.xrandr
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    # Sway
    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      wrapperFeatures.gtk = true;
      extraConfig = ''
        # Monitors
        ## Variables

        ## Resolution and disposition
        output DP-1   res 1920x1080@60Hz pos 0    0
        output HDMI-A-1 res 2560x1080@75Hz pos 1920 80
        #adaptive_sync on max_render_time 1

        ## Workspaces
        workspace 1 output HDMI-A-1
        workspace 2 output DP-1

        ## First focused workspace
        exec swaymsg focus output $mcenter

        # Colors
        include ~/.config/sway/colors
        client.focused $base00 $base02 $base00 $base03 $base05
        client.focused_inactive $base00 $base02 $base00 $base04 $base04
        client.unfocused $base00 $base02 $base00 $base04 $base04
        client.urgent $base00 $base02 $base00 $base09 $base09
        client.background $base00
      '';
      config = {
        bars = [];
        startup = [
          # Set initial theme, wallpaper, and lock screen
          { command = "initial_theming.sh"; }
          # Focus main output
          { command = "swaymsg focus output HDMI-A-1"; }
          # Swayidle
          { command = "swayidle -w \\
          timeout 600 'swaylock.sh --screenshots --daemonize' \\
          timeout 20  'pgrep -x swaylock && swaymsg \"output * dpms off\"' \\
              resume  'pgrep -x swaylock && swaymsg \"output * dpms on\"' \\
          timeout 620 'swaymsg \"output * dpms off\"' \\
              resume  'swaymsg \"output * dpms on\"' \\
          timeout 20  'pgrep -x swaylock && gpg-connect-agent reloadagent /bye' \\
          timeout 620 'gpg-connect-agent reloadagent /bye'"; }
          # Add transparency
          { command = "swayfader.sh"; always = true; }
          # Set icon theme based on scheme
          { command = "seticons $(darkmode query)"; always = true; }
          # Set xwayland main monitor
          { command = "exec_always \"xrandr --output $(xrandr | grep \"XWAYLAND.*2560x1080\" | awk '{printf $1}') --primary\"" ; always = true; }
        ];
        window = {
          border = 2;
        };
        keybindings = lib.mkOptionDefault {
          "Mod4+minus" = "split v";
          "Mod4+backslash" = "split h";
          "Mod4+u" = "scratchpad show";
          "Mod4+Shift+u" = "move scratchpad";
          "Mod4+b" = "exec qutebrowser";
          "Mod4+z" = "exec zathura";
          "Mod4+w" = "exec makoctl dismiss";
          "Mod4+shift+w" = "exec makoctl dismiss -a";
          "Mod4+control+w" = "exec makoctl invoke";
          "Shift+Print" = "exec grimshot --notify copy active";
          "Control+Print" = "exec grimshot --notify copy screen";
          "Print" = "exec grimshot --notify copy output";
          "Mod1+Print" = "exec grimshot --notify copy area";
          "Mod4+Print" = "exec grimshot --notify copy window";
        };
        workspaceAutoBackAndForth = true;
        terminal = "alacritty";
        modifier = "Mod4";
        input = {
          "6940:6985:Corsair_CORSAIR_K70_RGB_MK.2_Mechanical_Gaming_Keyboard" = {
            xkb_layout = "br";
          };
        };
        gaps = {
          horizontal = 5;
          inner = 28;
        };
      };
    };

    # Programs
    programs.alacritty = {
      enable = true;
    };
    #programs.mako = {
      #enable = true;
    #};
    programs.git = {
      enable = true;
      userName = "Gabriel Fontes";
      userEmail = "eu@misterio.me";
      signing = {
        signByDefault = true;
        key = "CE707A2C17FAAC97907FF8EF2E54EA7BFE630916";
      };
      lfs = {
        enable = true;
      };
    };
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        font = "Fira Sans 12";
        recolor = true;
      };
      extraConfig = ''
        include colors
      '';
    };
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    programs.zsh = {
      enable = true;
      enableCompletion = false;
      enableSyntaxHighlighting = true;
      loginExtra = ''
        [[ "$(tty)" == /dev/tty1 ]] && exec sway
      '';
      shellAliases = {
        jqless = "jq -C | less -r";
        nr = "nixos-rebuild";
        nrs = "sudo nixos-rebuild switch";
        nre = "nixos-rebuild edit";
        ns = "nix-shell";
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
        m = "m";
        mutt = "neomutt";
      };
      envExtra = ''
        GLOBALIAS_FILTER_VALUES=(ls)
      '';
      history = {
        size = 1000;
      };
      initExtra = ''
        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"

        bindkey "''${terminfo[kcuu1]}" history-substring-search-up
        bindkey "''${terminfo[kcud1]}" history-substring-search-down

        zstyle ":completion:*" completer _complete
        zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|=* r:|=*"
        export PATH="$PATH":$HOME/bin
      '';
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-completions"; }
          { name = "zsh-users/zsh-history-substring-search"; }
          { name = "softmoth/zsh-vim-mode"; }
          { name = "chisui/zsh-nix-shell"; }
          { name = "plugins/globalias"; tags = [ from:oh-my-zsh ]; }
        ];
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      sshKeys = [ "149F16412997785363112F3DBD713BC91D51B831" ];
    };
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = ''
          $username$hostname$shlvl $cmd_duration
          $directory$git_branch$git_commit$git_state$git_status$hg_branch$docker_context$package$cmake$dart$dotnet$elixir$elm$erlang$golang$helm$java$julia$kotlin$nim$nodejs$ocaml$perl$php$purescript$python$ruby$rust$swift$terraform$zig$nix_shell$conda$memory_usage$aws$gcloud$openstack$env_var$crystal
          $jobs$character
        '';
        username = {
          show_always = true;
          format = "[$user]($style)";
        };
        hostname = {
          ssh_only = false;
          format = "[@$hostname]($style)";
        };
        directory = {};
        character = {
          success_symbol = "[->>](bold green)";
          error_symbol = "[~~>](bold red)";
          vicmd_symbol = "[<<-](bold yellow)";
        };
        aws = {
          symbol = "  ";
          format = "on [$symbol$profile(\\($region\\))]($style) ";
        };
        gcloud = {
          symbol = " ";
          format = "on [$symbol$active(/$project)(\\($region\\))]($style) ";
        };
        nix_shell = {
          impure_msg = "";
          pure_msg = "λ ";
          symbol= " ";
          format = "via [$symbol$state( $name)]($style) ";
        };
        conda = {
          symbol = " ";
        };
        dart = {
          symbol = " ";
        };
        directory = {
          read_only = " ";
        };
        docker_context = {
          symbol = " ";
        };
        elixir = {
          symbol = " ";
        };
        elm = {
          symbol = " ";
        };
        git_branch = {
          symbol = " ";
        };
        golang = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        java = {
          symbol = " ";
        };
        julia = {
          symbol = " ";
        };
        memory_usage = {
          symbol = " ";
        };
        nim = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        package = {
          symbol = " ";
        };
        perl = {
          symbol = " ";
        };
        php = {
          symbol = " ";
        };
        python = {
          symbol = " ";
        };
        ruby = {
          symbol = " ";
        };
        rust = {
          symbol = " ";
        };
        scala = {
          symbol = " ";
        };
        shlvl = {
          symbol = " ";
        };
        swift = {
          symbol = "ﯣ ";
        };
      };
    };
    programs.neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        {
          plugin = ale;
          config = ''
            let g:ale_completion_enabled = 1
            let g:ale_linters = {"c": ["clang"], "rust": ["analyzer", "cargo"]}
            let g:ale_fixers = {"rust": ["rustfmt"], "sql": ["pgformatter"]}
            let g:ale_rust_analyzer_config = {'checkOnSave': {'command': 'clippy', 'enable': v:true}}
          '';
        }
        vim-gitgutter
        auto-pairs
        vim-surround
        vim-markdown
        {
          plugin = rust-vim;
          config = "let g:rust_fold = 1";
        }
        {
          plugin = vimtex;
          config = ''
            let g:vimtex_view_method = "zathura"
            let g:vimtex_view_automatic = 0
          '';
            #let g:vimtex_compiler_latexmk = {'options': ['-pdf','-shell-escape', '-verbose', '-file-line-error', '-synctex=1', '-interaction=nonstopmode',]}
        }
        vim-toml
        vim-nix
        rust-vim
        dart-vim-plugin
      ];
      extraConfig = ''
        "Reload automatically
        set autoread
        au CursorHold,CursorHoldI * checktime
        "Folding
        set foldmethod=syntax
        "Set fold level to highest in file
        "so everything starts out unfolded at just the right level
        autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
        "Tabs
        set tabstop=4 "How many spaces equals a tab
        set softtabstop=4 "How many columns when you hit tab
        set shiftwidth=4 "How many to indent with reindent ops
        set expandtab "Use spaces
        "set noexpandtab "Use tabs
        "Two spaces with html and nix
        autocmd FileType html,nix setlocal ts=2 sts=2 sw=2

        "Clipboard
        set clipboard=unnamedplus

        "Color scheme
        colorscheme base16
        set termguicolors

        "Conceal
        set conceallevel=2

        "Line numbers
        augroup numbertoggle
          autocmd!
          autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
          autocmd BufLeave,FocusLost,InsertEnter   * set number norelativenumber
        augroup END
      '';
    };

    # Writable (persistent) data
    home.persistence."/data" = {
      directories = [ "Documents" "Downloads" "Games" "Pictures" ".local/share/Steam" ".password-store" ".gnupg" ".local/share/Tabletop Simulator" ];
      allowOther = false;
    };

    # Read-only data
    # Configuration files
    xdg.configFile = {
      "flavours/config.toml".source = "/dotfiles/configs/flavours.toml";
      "qutebrowser/config.py".source = "/dotfiles/configs/qutebrowser.py";
      "alacritty/alacritty.yml".source = "/dotfiles/configs/alacritty.yml";
      "neofetch/config.conf".source = "/dotfiles/configs/neofetch.conf";
    };
    xdg.dataFile = {
      "flavours/base16".source = "/dotfiles/configs/flavours";
    };
    home.file = {
      "bin".source = "/dotfiles/scripts";
    };
  };
}
