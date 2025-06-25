{
  appdirs,
  Babel,
  buildPythonPackage,
  certifi,
  pyside6,
  pyserial,
  qt6,
  requests-futures,
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
}:
let
  plover-stroke = buildPythonPackage {
    pname = "plover_stroke";
    version = "master";
    src = inputs.plover-stroke;
  };
  rtf-tokenize = buildPythonPackage {
    pname = "rtf_tokenize";
    version = "master";
    src = inputs.rtf-tokenize;
  };
in
buildPythonPackage {
  pname = "plover";
  version = "master";
  src = inputs.plover;

  nativeBuildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtsvg # required for rendering icons
    qt6.qtwayland
  ];

  propagatedBuildInputs = [
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
    rtf-tokenize
  ];

  preConfigure = ''
    export PATH=${qt6.qtbase}/libexec:$PATH
    substituteInPlace "plover_build_utils/setup.py" \
      --replace-fail "'pyside6-rcc'" "'${qt6.qtbase}/libexec/rcc', '-g', 'python'" \
      --replace-fail "'pyside6-uic'" "'${qt6.qtbase}/libexec/uic', '-g', 'python'"
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp $src/plover/assets/plover.png $out/share/icons/hicolor/128x128/apps/plover.png

    mkdir -p $out/share/applications
    cp $src/linux/plover.desktop $out/share/applications/plover.desktop
    substituteInPlace "$out/share/applications/plover.desktop" \
      --replace-warn "Exec=plover" "Exec=$out/bin/plover"
  '';

  doCheck = false;
}
