{
  lib,
  config,
  ...
}:
{
  options.programs'.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator";
  };

  config = lib.mkIf config.programs'.kitty.enable {
    hm'.programs.kitty = {
      enable = true;
      font = {
        name = "Maple Mono NF CN";
        size = 12;
      };

      settings = {
        hide_window_decorations = "titlebar-only";
        window_padding_width = "10";
        mouse_hide_wait = 2;
        url_color = "#ffb4a8";
        url_style = "dotted";
        confirm_os_window_close = 0;
        background_opacity = "0.8";

        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      };

      extraConfig = ''
        include ./themes/noctalia.conf
      '';
    };

    preservation'.user.directories = [
      ".cache/kitty"
    ];
  };
}
