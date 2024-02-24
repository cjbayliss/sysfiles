{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "iosevka-term";
  # TODO: figure out the newest version that doesn't have emoji
  version = "2.3.3";

  src = fetchurl {
    url = "https://github.com/be5invis/Iosevka/releases/download/v${version}/02-${pname}-${version}.zip";
    hash = "sha256-APzmF0BfzNf79zFtrdP2s8yx4nbykQ6anN4S4/BYtNc=";
  };

  nativeBuildInputs = [unzip];

  phases = ["unpackPhase"];

  dontInstall = true;

  unpackPhase = ''
    mkdir -p $out/share/fonts
    unzip -d $out/share/fonts/truetype $src "ttf/*.ttf"
  '';

  meta = with lib; {
    homepage = "https://github.com/be5invis/Iosevka";
    description = "older version of iosevka that doesn't contain emoji (so that emoji can be provided by another font)";
    platforms = platforms.all;
  };
}
