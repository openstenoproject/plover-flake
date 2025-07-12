{
  appdirs,
  Babel,
  buildPythonPackage,
  certifi,
  pyside6,
  pyserial,
  qt6,
  requests-futures,
  psutil,
  setuptools,
  wcwidth,
  xlib,
  evdev,
  packaging,
  pkginfo,
  pygments,
  readme-renderer,
  cmarkgfm,
  requests-cache,
  inputs,
  writeShellScriptBin,
}:
let
  plover-stroke = buildPythonPackage {
    pname = "plover_stroke";
    version = "master";
    src = inputs.plover-stroke;
    pyproject = true;
    build-system = [ setuptools ];
  };
  rtf-tokenize = buildPythonPackage {
    pname = "rtf_tokenize";
    version = "master";
    src = inputs.rtf-tokenize;
    pyproject = true;
    build-system = [ setuptools ];
  };
  # Matches missing pyside6-uic and pyside6-rcc implementations
  # https://github.com/NixOS/nixpkgs/issues/277849
  # https://github.com/NixOS/nixpkgs/blob/0ab0fd44102fd7259708584c6eafb78b1aeee0d3/pkgs/development/python-modules/openusd/default.nix#L44-L50
  # https://code.qt.io/cgit/pyside/pyside-setup.git/tree/sources/pyside-tools/pyside_tool.py?id=9b310d4c0654a244147766e382834b5e8bdeb762#n90
  pyside-tools-uic = writeShellScriptBin "pyside6-uic" ''
    exec ${qt6.qtbase}/libexec/uic -g python "$@"
  '';
  pyside-tools-rcc = writeShellScriptBin "pyside6-rcc" ''
    exec ${qt6.qtbase}/libexec/rcc -g python "$@"
  '';
in
buildPythonPackage {
  pname = "plover";
  version = "master";
  src = inputs.plover;
  pyproject = true;
  build-system = [ setuptools ];

  nativeBuildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
    pyside-tools-uic
    pyside-tools-rcc
  ];

  buildInputs = [
    qt6.qtsvg # required for rendering icons
    qt6.qtwayland
  ];

  dependencies = [
    Babel
    pyside6
    xlib
    pyserial
    appdirs
    wcwidth
    setuptools
    certifi
    evdev
    packaging
    pkginfo
    pygments
    readme-renderer
    cmarkgfm
    requests-cache
    requests-futures
    plover-stroke
    psutil
    rtf-tokenize
  ];

  # PySide6-Essentials it not on nixpkgs. See: https://github.com/NixOS/nixpkgs/issues/277849
  postPatch = ''
    substituteInPlace "pyproject.toml" --replace-fail "PySide6-Essentials" "PySide6"
    substituteInPlace "reqs/setup.txt" --replace-fail "PySide6-Essentials" "PySide6"
    substituteInPlace "reqs/dist_extra_gui_qt.txt" --replace-fail "PySide6-Essentials" "PySide6"
    substituteInPlace "reqs/constraints.txt" --replace-fail "PySide6-Essentials" "PySide6"
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp $src/plover/assets/plover.png $out/share/icons/hicolor/128x128/apps/plover.png

    mkdir -p $out/share/applications
    cp $src/linux/plover.desktop $out/share/applications/plover.desktop
    substituteInPlace "$out/share/applications/plover.desktop" \
      --replace-fail "Exec=plover" "Exec=$out/bin/plover"
  '';

  # See: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/qt.section.md
  dontWrapQtApps = true;
  preFixup = ''
    wrapQtApp "$out/bin/plover"
  '';

  doCheck = false;
}
