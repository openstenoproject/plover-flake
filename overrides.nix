{
  ruamel-yaml,
  prompt-toolkit,
  pysdl2,
  setuptools-scm,
  evdev,
  xkbcommon,
  lxml,
  inflect,
  buildPythonPackage,
  fetchPypi,
}:
final: prev: {
  plover-yaml-dictionary = prev.plover-yaml-dictionary.overrideAttrs (old: {
    dependencies = [ ruamel-yaml ];
  });
  plover-console-ui = prev.plover-console-ui.overrideAttrs (old: {
    dependencies = [ prompt-toolkit ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-controller = prev.plover-controller.overrideAttrs (old: {
    dependencies = [ pysdl2 ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-dict-commands = prev.plover-dict-commands.overrideAttrs (old: {
    dependencies = [ setuptools-scm ];
  });
  plover-uinput = prev.plover-uinput.overrideAttrs (old: {
    dependencies = [
      evdev
      xkbcommon
    ];
  });
  plover-svg-layout-display = prev.plover-svg-layout-display.overrideAttrs (old: {
    dependencies = [ lxml ];
  });
  plover-stenobee = prev.plover-stenobee.overrideAttrs (old: {
    dependencies = [
      inflect
      final.plover-python-dictionary
    ];
  });
  plover-lapwing-aio = prev.plover-lapwing-aio.overrideAttrs (old: {
    dependencies = [
      final.plover-stitching
      final.plover-python-dictionary
      final.plover-modal-dictionary
      final.plover-last-translation
      final.plover-dict-commands
    ];
  });
  plover-emoji =
    let
      simplefuzzyset = buildPythonPackage rec {
        pname = "simplefuzzyset";
        version = "0.0.12";

        src = fetchPypi {
          inherit pname version;
          hash = "sha256-mhsww4tq+3bGYAvdZsHB3D2FBbCC6ePUZvYPQOi34fI=";
        };
      };
    in
    prev.plover-emoji.overrideAttrs (old: {
      dependencies = [
        simplefuzzyset
      ];
    });
}
