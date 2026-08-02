{ config, pkgs, lib, user, treehouse, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  dotfileSymlinks = {
    ".config/wezterm" = ".config/wezterm";
    ".config/nvim" = ".config/nvim";
    ".config/herdr" = ".config/herdr";
    ".claude/settings.json" = ".claude/settings.json";

    ".claude/CLAUDE.md" = "AGENTS.md";
    ".codex/AGENTS.md" = "AGENTS.md";
    ".config/opencode/AGENTS.md" = "AGENTS.md";
  };
in
{
  imports = [ ./modules/aliases ];

  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = (with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    btop      # process/resource monitor
    neovim
    nodejs_24
    # the font everything renders in
    nerd-fonts.hack
  ]) ++ [
    treehouse.packages.${pkgs.system}.default
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  home.file = lib.mapAttrs
    (_: rel: { source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/${rel}"; })
    dotfileSymlinks;
}
