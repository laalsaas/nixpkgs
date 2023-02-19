{ lib
, stdenv
, fetchFromGitHub
, runtimeShell
}:

stdenv.mkDerivation rec {
  pname = "zsh-autoenv";
  version = "unstable-2017-12-16";

  src = fetchFromGitHub {
    owner = "Tarrasch";
    repo = "zsh-autoenv";
    rev = "2c8cfbcea8e7286649840d7ec98d7e9d5e1d45a0";
    sha256 = "004svkfzhc3ab6q2qvwzgj36wvicg5bs8d2gcibx6adq042di7zj";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp -R $src $out/share/zsh-autoenv

    cat <<SCRIPT > $out/bin/zsh-autoenv-share
    #!${runtimeShell}
    # TODO: remove this after 23.05, but ideally before 23.11, as well as in fzf, skim and blesh.
    echo 'The ${pname}-share script is deprecated and will be removed soon.' >&2
    if [ -f "/etc/NIXOS" ]; then
      echo 'On NixOS, you can just use the module (programs.zsh.zsh-autoenv.enable).'
    else
      echo 'On non-NixOS-systems, you can just directly source `~/.nix-profile/share/zsh-autoenv/init.zsh`.'
    fi >&2
    echo $out/share/zsh-autoenv
    SCRIPT
    chmod +x $out/bin/zsh-autoenv-share
  '';

  meta = with lib; {
    description = "Automatically sources whitelisted .autoenv.zsh files";
    longDescription = ''
      zsh-autoenv automatically sources (known/whitelisted)
      .autoenv.zsh files, typically used in project root directories.
      It handles "enter" and "leave" events, nesting, and stashing of
      variables (overwriting and restoring).
    '';
    homepage = "https://github.com/Tarrasch/zsh-autoenv";
    mainProgram = "zsh-autoenv-share";
    platforms = lib.platforms.all;
  };
}
