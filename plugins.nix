{
  buildPythonPackage,
  callPackage,
  fetchPypi,
  lib,
  plover,
  setuptools,
  inputs,
}:
let
  inherit (lib) extends;
  plugins = builtins.fromJSON (builtins.readFile ./plugins.json);
  makePloverPlugin =
    plugin:
    (buildPythonPackage rec {
      pname = plugin.name;
      inherit (plugin) version;
      src = fetchPypi {
        inherit version;
        pname = lib.lists.head (builtins.split "-[0-9]" plugin.filename);
        inherit (plugin) sha256;
      };
      buildInputs = [ plover ];
      pyproject = true;
      build-system = [ setuptools ];
    });
  pluginToAttr = p: {
    name = p.pname;
    value = p;
  };
  basicPlugins =
    final: prev: builtins.listToAttrs (map (p: pluginToAttr (makePloverPlugin p)) plugins);
  overrides = callPackage ./overrides.nix { };

  initialPackages = self: callPackage ./extra-plugins.nix { inherit plover inputs; };

  extensible-self = lib.makeExtensible (extends overrides (extends basicPlugins initialPackages));
in
extensible-self
