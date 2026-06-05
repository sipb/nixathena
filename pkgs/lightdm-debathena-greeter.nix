{
  lib,
  python3Packages,
  fetchFromForgejo,
  librsvg,
  linkFarm,
  wrapGAppsHook3,
  gtk3,
  gobject-introspection,
  lightdm,
  lightdm-debathena-greeter,
  labwc,
  gtk-layer-shell,
  wvkbd,
}:

# Based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/li/lightdm-slick-greeter/package.nix
# Note that the package name is lightdm-debathena-greeter (to follow Nix conventions) but the files are called debathena-lightdm-greeter!
python3Packages.buildPythonApplication rec {
  pname = "lightdm-debathena-greeter";
  version = "2.0.1";
  src = fetchFromForgejo {
    domain = "forgejo.mit.edu";
    owner = "SIPB";
    repo = "lightdm-config";
    rev = "v${version}";
    hash = "sha256-k/aT0NI9hWb1D8NER9A5HGFnLodXwODdExVM82I7Mss=";
  };

  format = "other";

  nativeBuildInputs = [
    librsvg
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    lightdm
    wvkbd
    gtk-layer-shell
    labwc
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    dbus-python
  ];

  extraFiles = ../img;
  postUnpack = ''
    rsvg-convert --zoom 0.35 "$extraFiles"/logo.svg -o source/debian/debathena.png
    for i in {1..8}
    do
      rsvg-convert --zoom 0.35 "$extraFiles"/logo$i.svg -o source/debian/debathena$i.png
    done
  '';

  preConfigure = ''
    cd debian
  '';

  installPhase = ''
    mkdir -p $out/bin $out/etc $out/share/xgreeters $out/share/debathena-lightdm-greeter
    cp debathena-lightdm-greeter $out/bin
    cp debathena-lightdm-greeter.ini $out/etc
    cp debathena-lightdm-greeter.desktop $out/share/xgreeters
    cp debathena-lightdm-greeter.ui background.jpg debathena*.png $out/share/debathena-lightdm-greeter
    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/etc/debathena-lightdm-greeter.ini \
      --replace-fail /usr/share/debathena-lightdm-config $out/share/debathena-lightdm-greeter
    substituteInPlace $out/bin/debathena-lightdm-greeter \
      --replace-fail /usr/share/debathena-lightdm-config $out/share/debathena-lightdm-greeter \
      --replace-fail /etc/debathena-lightdm-greeter.ini $out/etc/debathena-lightdm-greeter.ini \
      --replace-fail /usr/bin/wvkbd-mobintl ${wvkbd}/bin/wvkbd-mobintl
    substituteInPlace $out/share/xgreeters/debathena-lightdm-greeter.desktop \
      --replace-fail "labwc -s /usr/lib/debathena-lightdm-config/debathena-lightdm-greeter" "${labwc}/bin/labwc -s $out/bin/debathena-lightdm-greeter"
  '';

  passthru.xgreeters = linkFarm "debathena-greeter-xgreeters" [
    {
      path = "${lightdm-debathena-greeter}/share/xgreeters/debathena-lightdm-greeter.desktop";
      name = "debathena-lightdm-greeter.desktop";
    }
  ];

  meta = {
    description = "LightDM greeter for Debathena";
    homepage = "https://github.com/mit-athena/lightdm-config";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
}
