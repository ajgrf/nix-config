{ stdenv, lib, fetchFromGitHub, makeWrapper, bc, ffmpeg }:

stdenv.mkDerivation rec {
  pname = "aaxtomp3";
  version = "1.2";
  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "KrumpetPirate";
    repo = "AAXtoMP3";
    rev = "v${version}";
    sha256 = "11d145yj1sc9m9jhj70l8dh2mzzwb710hrpnzjzayxcaq122i9yf";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp AAXtoMP3 $out/bin
  '';

  wrapperPath = with lib; makeBinPath ([ bc ffmpeg ]);

  postFixup = ''
    wrapProgram $out/bin/AAXtoMP3 \
      --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "Convert Audible AAX files";
    homepage = "https://github.com/KrumpetPirate/AAXtoMP3";
    license = licenses.wtfpl;
  };
}
