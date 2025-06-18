# A flake for plover with support for plugins

This is an experimental flake which packages plover for nix, along with support for plugins from the plugins registry.

> [!NOTE]
> This flake recently upgraded plover to switch from QT5 to QT6, which broke many GUI plugins. If you wish to keep using the old version of plover, switch to an older version of this flake by changing the input URL to `github:openstenoproject/plover-flake/6807afead2fb9e402dddb038d45b38e6226e94d1`. The documentation for the old version can be found [here](https://github.com/openstenoproject/plover-flake/tree/6807afead2fb9e402dddb038d45b38e6226e94d1).

## Usage

Add this flake to your flake inputs, e.g. `inputs.plover-flake.url = "github:openstenoproject/plover-flake";`

Then a plover derivation containing the plugins you want can be built with

```nix
inputs.plover-flake.packages.${system}.plover.withPlugins (ps: with ps; [
  plover-lapwing-aio
  plover-console-ui
]);
```

Where `ps` is an attribute set containing all plugins from the plugin registry, as well as some extra plugins.

## home-manager module

If you use [home-manager](https://github.com/nix-community/home-manager), there is a module available. Here is an example of a configuration:

```nix
# any file imported by home-manager, e.g. home.nix

{ inputs, ... }: {
  imports = [
    inputs.plover-flake.homeManagerModules.plover
  ];

  programs.plover = {
    enable = true;
    package = inputs.plover-flake.packages.${pkgs.system}.plover.withPlugins (
      ps: with ps; [
        plover-lapwing-aio
      ]
    );
    settings = {
      "Machine Configuration" = {
        machine_type = "Gemini PR";
        auto_start = true;
      };
      "Output Configuration".undo_levels = 100;
    };
  };
}
```

If you don't want nix to manage the configuration of plover, you can omit the `settings` value.

## NixOS configuration

To let Plover find serial ports, add your user to the `dialout` user group:

```nix
users.users."YOUR USER".extraGroups = [ "dialout" ];
```

If you use wayland, you will want to add the following snippet to your NixOS system configuration.

```nix
services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
'';

users.users."YOUR USER".extraGroups = [ "input" ];
```

This gives your user the necessary permissions to output characters through plover.

## Troubleshooting

If a specific plugin fails to build it is most likely because of a missing dependency. In that case that dependency can be added to overrides.nix, any pull requests doing so are welcome.
