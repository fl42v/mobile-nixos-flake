{ lib
, stdenv
, fetchFromGitea 
, meson
, ninja
, pkg-config
, cmake
, glib
, mesonEmulatorHook
, libgudev
, libqmi
, protobufc
}:

stdenv.mkDerivation rec {
  pname = "libssc";
  version = "0.1.4";

  outputs = [ "out" "dev" ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "DylanVanAssche";
    repo = "libssc";
    rev = "6efef1c62124b27853914dd2efd8202b4ff71050";
    hash = "sha256-oNfa4vnwzmfRtvgYd6CeP2bG29M7+YOx56VIC9lUqWg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  propagatedBuildInputs = [
    libqmi
  ];

  buildInputs = [
    glib
    libgudev
    protobufc
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://codeberg.org/DylanVanAssche/libssc";
    description = "Library to expose Qualcomm Sensor Core sensors";
    platform = "aarch64-linux";
    license = licenses.gpl3Plus;
  };
}
