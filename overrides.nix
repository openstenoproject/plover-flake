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
    propagatedBuildInputs = [ ruamel-yaml ];
  });
  plover-console-ui = prev.plover-console-ui.overrideAttrs (old: {
    propagatedBuildInputs = [ prompt-toolkit ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-controller = prev.plover-controller.overrideAttrs (old: {
    propagatedBuildInputs = [ pysdl2 ];
    doCheck = false;
    doInstallCheck = false;
  });
  plover-dict-commands = prev.plover-dict-commands.overrideAttrs (old: {
    propagatedBuildInputs = [ setuptools-scm ];
  });
  plover-uinput = prev.plover-uinput.overrideAttrs (old: {
    propagatedBuildInputs = [
      evdev
      xkbcommon
    ];
  });
  plover-svg-layout-display = prev.plover-svg-layout-display.overrideAttrs (old: {
    propagatedBuildInputs = [ lxml ];
  });
  plover-stenobee = prev.plover-stenobee.overrideAttrs (old: {
    propagatedBuildInputs = [
      inflect
      final.plover-python-dictionary
    ];
  });
  plover-lapwing-aio = prev.plover-lapwing-aio.overrideAttrs (old: {
    propagatedBuildInputs = [
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
      };
    in
    prev.plover-emoji.overrideAttrs (old: {
      propagatedBuildInputs = [
        simplefuzzyset
      ];
    });
}
