{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.fcitx5;
  mkAyayaTheme =
    name: palette:
    let
      theme = (pkgs.formats.ini { }).generate "theme.conf" {
        Metadata = {
          Name = "Ayaya ${name}";
          Author = palette.author;
          Description = "Port of the Ayaya Squirrel color scheme";
          Version = 1;
        };
        InputPanel = {
          NormalColor = palette.text;
          HighlightColor = palette.selectedText;
          HighlightBackgroundColor = palette.highlight;
          HighlightCandidateColor = palette.selectedText;
          CandidateLabelColor = palette.label;
          HighlightCandidateLabelColor = palette.selectedLabel;
          CandidateCommentColor = palette.comment;
          HighlightCandidateCommentColor = palette.selectedComment;
          LabelTextSizeFactor = 73;
          CommentTextSizeFactor = 73;
          FullWidthHighlight = false;
        };
        "InputPanel/Background".Image = "background.png";
        "InputPanel/Background/Margin" = {
          Left = 7;
          Right = 7;
          Top = 3;
          Bottom = 3;
        };
        "InputPanel/Highlight".Image = "highlight.png";
        "InputPanel/Highlight/Margin" = {
          Left = 7;
          Right = 7;
          Top = 3;
          Bottom = 3;
        };
        "InputPanel/ContentMargin" = {
          Left = 0;
          Right = 0;
          Top = 0;
          Bottom = 0;
        };
        "InputPanel/TextMargin" = {
          Left = 7;
          Right = 7;
          Top = 3;
          Bottom = 3;
        };
      };
    in
    pkgs.runCommand "fcitx5-ayaya-${name}" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
      mkdir -p "$out"
      cp ${theme} "$out/theme.conf"
      magick -size 128x128 xc:none -fill '${palette.background}' \
        -stroke '${palette.border}' -strokewidth 2 \
        -draw 'roundrectangle 1,1 126,126 28,12' -resize 32x32 "$out/background.png"
      magick -size 80x80 xc:none -fill '${palette.highlight}' \
        -draw 'roundrectangle 0,0 79,79 28,12 rectangle 40,0 79,79' \
        -resize 20x20 "$out/highlight.png"
    '';
  # Squirrel uses BGR; Fcitx5 uses RGB with an optional trailing alpha byte.
  ayayaDay = mkAyayaTheme "Day" {
    author = "Lufs X <i@isteed.cc>";
    background = "#fffffff2";
    border = "#dccbd2b3";
    text = "#121212";
    highlight = "#fce4ecf2";
    selectedText = "#ec407a";
    label = "#858788";
    selectedLabel = "#f48fb1";
    comment = "#8e8e8e";
    selectedComment = "#8e8e8e";
  };
  ayayaNight = mkAyayaTheme "Night" {
    author = "ksqsf <i@ksqsf.moe>";
    background = "#1e1e1ef2";
    border = "#080808cc";
    text = "#f0a6aa";
    highlight = "#f58ba7f2";
    selectedText = "#1e1e1e";
    label = "#f0a6aa";
    selectedLabel = "#1e1e1e";
    comment = "#f0a6aa";
    selectedComment = "#1e1e1e";
  };
in
{
  options.desktop'.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 input method";
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          (fcitx5-rime.override {
            # rime-ice ships the schema and dictionaries as a reproducible
            # package; unlike wanxiang it needs no separately pinned model.
            rimeDataPkgs = [ rime-ice ];
          })
          (qt6Packages.fcitx5-configtool.override { kcmSupport = false; })
        ];
      };
    };

    # Fcitx5 rewrites this file when input methods change at runtime, so force
    # the declarative profile back on every Home Manager activation.
    hm'.xdg.configFile."fcitx5/profile" = {
      source = ./fcitx5/profile;
      force = true;
    };

    hm'.xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      Vertical Candidate List=False
      Font=LXGW WenKai,Source Han Sans SC Medium 13
      Theme=ayaya-day
      DarkTheme=ayaya-night
      UseDarkTheme=True
      UseAccentColor=False
    '';

    hm'.xdg.dataFile = {
      "fcitx5/themes/ayaya-day".source = ayayaDay;
      "fcitx5/themes/ayaya-night".source = ayayaNight;
      "fcitx5/rime/default.custom.yaml".text = ''
        patch:
          __include: rime_ice_suggestion:/
          schema_list:
            - schema: rime_ice
      '';
    };

    preservation'.user.directories = [
      ".config/fcitx5"
      ".local/share/fcitx5"
    ];
  };
}
