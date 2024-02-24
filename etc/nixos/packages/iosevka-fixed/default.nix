{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "iosevka-fixed";
  version = "22.1.0"; # newest version without emoji

  src = fetchurl {
    url = "https://github.com/be5invis/Iosevka/releases/download/v${version}/ttf-${pname}-${version}.zip";
    hash = "sha256-15PFSh1N7jD1udr1edwEQdE7ifZKDMFq5vctOFzEoeQ=";
  };

  nativeBuildInputs = [unzip];

  phases = ["unpackPhase"];

  dontInstall = true;

  unpackPhase = ''
    mkdir -p $out/share/fonts
    unzip -d $out/share/fonts/truetype $src
  '';

  meta = with lib; {
    homepage = "https://github.com/be5invis/Iosevka";
    description = "older version of iosevka that doesn't contain emoji (so that emoji can be provided by another font)";
    platforms = platforms.all;
  };
}
