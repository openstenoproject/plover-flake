{
  ruamel-yaml,
  prompt-toolkit,
  pysdl2,
  setuptools,
  setuptools-scm,
  evdev,
  xkbcommon,
  lxml,
  inflect,
  buildPythonPackage,
  fetchPypi,
}:
final: prev: {
  plover-yaml-dictionary = prev.plover-yaml-dictionary.overridePythonAttrs (old: {
    dependencies = [ ruamel-yaml ];
  });
  plover-console-ui = prev.plover-console-ui.overridePythonAttrs (old: {
    dependencies = [ prompt-toolkit ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-controller = prev.plover-controller.overridePythonAttrs (old: {
    dependencies = [ pysdl2 ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-dict-commands = prev.plover-dict-commands.overridePythonAttrs (old: {
    dependencies = [ setuptools-scm ];
  });
  plover-uinput = prev.plover-uinput.overridePythonAttrs (old: {
    dependencies = [
      evdev
      xkbcommon
    ];
  });
  plover-svg-layout-display = prev.plover-svg-layout-display.overridePythonAttrs (old: {
    dependencies = [ lxml ];
  });
  plover-stenobee = prev.plover-stenobee.overridePythonAttrs (old: {
    dependencies = [
      inflect
      final.plover-python-dictionary
    ];
  });
  plover-lapwing-aio = prev.plover-lapwing-aio.overridePythonAttrs (old: {
    dependencies = [
      final.plover-stitching
      final.plover-python-dictionary
      final.plover-modal-dictionary
      final.plover-last-translation
      final.plover-dict-commands
    ];
    # NOTE: Remove it on failure:
    postPatch = ''
      substituteInPlace "setup.cfg" --replace-fail "setuptools<77" "setuptools"
    '';
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
        pyproject = true;
        build-system = [ setuptools ];
      };
    in
    prev.plover-emoji.overridePythonAttrs (old: {
      dependencies = [
        simplefuzzyset
      ];
    });
}
