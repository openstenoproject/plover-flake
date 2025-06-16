self:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.plover;
  iniFormat = pkgs.formats.ini { };
in
{
  options.programs.plover = {
    enable = lib.mkEnableOption "plover";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.plover;
      example =
        lib.literalExpression # nix
          ''
            inputs.plover-flake.${pkgs.system}.plover.withPlugins (ps: with ps; [
              plover-lapwing-aio
              plover-console-ui
            ])
          '';
    };

    settings = lib.mkOption {
      description = ''
        The plover configuration, written to `$XDG_CONFIG_HOME/plover/plover.cfg`.
        If null, the configuration will not be managed by home-manager.
      '';
      type =
        with lib.types;
        with lib.options;
        let
          mkConfig =
            type: example:
            mkOption {
              inherit example;
              type = nullOr type;
              default = null;
            };
        in
        nullOr (submodule {
          freeformType = iniFormat.type;

          options = {
            "Machine Configuration" = {
              machine_type = mkConfig str "Gemini PR";
              auto_start = mkConfig bool false;
            };

            "Output Configuration" = {
              undo_levels = mkConfig int 100;
            };

            "Translation Frame" = {
              opacity = mkConfig int 100;
            };

            "Gemini PR" = {
              baudrate = mkConfig int 9600;
              bytesize = mkConfig int 8;
              parity = mkConfig str "N";
              port = mkConfig str "/dev/ttyACM0";
              stopbits = mkConfig int 1;
              timeout = mkConfig float 2.0;
            };

            "Plugins" = {
              enabled_extensions = lib.options.mkOption {
                example = ["modal_update" "plover_auto_reconnect_machine"];
                type = (listOf str);
                default = null;
                apply = xs: "[" + builtins.concatStringsSep ", " (map (x: "\"${x}\"") xs) + "]";
              };
            };

            "System" = {
              name = mkConfig str "Lapwing";
            };

            "Startup" = {
              "start minimized" = mkConfig bool false;
            };

            "Logging Configuration" = {
              log_file = mkConfig str "strokes.log";
            };

            "System: Lapwing" = {
              dictionaries =
                mkConfig
                  (listOf (submodule {
                    options = {
                      enabled = mkConfig bool true;
                      path = mkConfig str "user.json";
                    };
                  }))
                  [
                    {
                      enabled = true;
                      path = "user.json";
                    }
                  ];
            };
          };
        });
      default = null;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];
      }
      (lib.mkIf (cfg.settings != null) {
        # It is necessary to filter the attrs because the option definitions require a default value, but should be unset in the result.
        xdg.configFile."plover/plover.cfg".source = iniFormat.generate "plover.cfg" (
          lib.filterAttrsRecursive (n: v: v != null) cfg.settings
        );
      })
    ]
  );
}
