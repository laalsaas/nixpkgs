{ lib
, stdenvNoCC
, fetchzip
, runtimeShell
, bashInteractive
, glibcLocales
}:

stdenvNoCC.mkDerivation rec {
  pname = "blesh";
  version = "unstable-2022-07-29";

  src = fetchzip {
    url = "https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly-20220729+a22e145.tar.xz";
    sha256 = "088jv02y40pjcfzgrbx8n6aksznfh6zl0j5siwfw3pmwn3i16njw";
  };

  dontBuild = true;

  doCheck = true;
  nativeCheckInputs = [ bashInteractive glibcLocales ];
  preCheck = "export LC_ALL=en_US.UTF-8";

  installPhase = ''
    runHook preInstall

    install -d "$out/share/blesh/lib"

    cat <<EOF >"$out/share/blesh/lib/_package.sh"
    _ble_base_package_type=nix

    function ble/base/package:nix/update {
      echo "Ble.sh is installed by Nix. You can update it there." >&2
      return 1
    }
    EOF

    cp -rv $src/* $out/share/blesh

    runHook postInstall
  '';

  postInstall = ''
    install -d $out/bin
    cat <<EOF >"$out/bin/blesh-share"
    #!${runtimeShell}
    # TODO: remove this after 23.05, but ideally before 23.11, as well as in fzf, skim, zsh-autoenv.
    echo 'The ${pname}-share script is deprecated and will be removed soon.' >&2
    if [ -f "/etc/NIXOS" ]; then
      echo 'On NixOS, you can just use the module (programs.bash.blesh.enable).'
    else
      echo 'On non-NixOS-systems, you can just directly source `~/.nix-profile/share/blesh/ble.sh`.'
    fi >&2

    echo "$out/share/blesh"
    EOF
    chmod +x "$out/bin/blesh-share"
  '';

  meta = with lib; {
    homepage = "https://github.com/akinomyoga/ble.sh";
    description = "Bash Line Editor -- a full-featured line editor written in pure Bash";
    license = licenses.bsd3;
    maintainers = with maintainers; [ aiotter ];
    platforms = platforms.unix;
  };
}
