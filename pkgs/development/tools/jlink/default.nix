{ stdenv
, fetchurl
, autoPatchelfHook
, substituteAll
, qt4
, fontconfig
, freetype
, libusb
, libICE
, libSM
, ncurses5
, udev
, libX11
, libXext
, libXcursor
, libXfixes
, libXrender
, libXrandr
}:

#PR: https://github.com/NixOS/nixpkgs/pull/80990


let
  jlinkVersion = "680e";

  architecture = {
    x86_64-linux = "x86_64";
    i686-linux = "i386";
    armv7l-linux = "arm";
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");

  sha256 = {
    x86_64-linux = "0vzzd9vz433zb89rr1y2gidx8d1lkjymmqqh8jb5gw9wfdncdqjz";
    i686-linux = "0wfb5w237ci4zgygydizlji07w8vq0pjaywfibk4fgnnr5qbi25i";
    armv7l-linux = "1xwq1ylr6i93qkxrwbk8jv5wa2lvi9ys6zk19ngna7wgwr350nsb";
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");

  url = {
    x86_64-linux = "https://www.segger.com/downloads/jlink/JLink_Linux_V${jlinkVersion}_x86_64.tgz";
    i686-linux = "https://www.segger.com/downloads/jlink/JLink_Linux_V${jlinkVersion}_i386.tgz";
    armv7l-linux = "https://www.segger.com/downloads/jlink/JLink_Linux_V${jlinkVersion}_arm.tgz";
  }.${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation rec {
  pname = "jlink";
  version = jlinkVersion;

  src = fetchurl {
    url = url;
    sha256 = sha256;
    curlOpts = "-d accept_license_agreement=accepted -d non_emb_ctr=confirmed";
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    qt4
    fontconfig
    freetype
    libusb
    libICE
    libSM
    ncurses5
    udev
    libX11
    libXext
    libXcursor
    libXfixes
    libXrender
    libXrandr
  ];

  runtimeDependencies = [ udev ];

  installPhase = ''
    mkdir -p $out/{JLink,bin}
    cp -R * $out/JLink
    ln -s $out/JLink/J* $out/bin/
    rm -r $out/bin/JLinkDevices.xml $out/JLink/libQt*
    install -D -t $out/lib/udev/rules.d 99-jlink.rules
  '';

  preFixup = ''
    patchelf --add-needed libudev.so.1 $out/JLink/libjlinkarm.so
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.segger.com/downloads/jlink";
    description = "SEGGER J-Link";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" "armv7l-linux" ];
  };
}
