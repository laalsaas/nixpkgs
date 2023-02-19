{ lib
, stdenv
, fetchCrate
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "skim";
  version = "0.10.2";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-LkPkwYsaSLfaZktHF23Fgaks+fDlbB1S6SRgXtJRBqQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  outputs = [ "out" "vim" ];

  cargoSha256 = "sha256-lG26dgvjqCZ/4KgzurMrlhl+JKec+xLt/5uA6XcsSPk=";

  postPatch = ''
    sed -i -e "s|expand('<sfile>:h:h')|'$out'|" plugin/skim.vim
  '';

  postInstall = ''
    install -D -m 555 bin/sk-tmux -t $out/bin

    install -D -m 444 plugin/skim.vim -t $vim/plugin

    install -D -m 444 shell/* -t $out/share/skim

    installManPage man/man1/*

    cat <<SCRIPT > $out/bin/sk-share
    #! ${stdenv.shell}
    # TODO: remove this after 23.05, but ideally before 23.11, as well as in zsh-autoenv, fzf and blesh.
    echo 'The sk-share script is deprecated and will be removed soon.' >&2
    if [ -f "/etc/NIXOS" ]; then
      echo 'On NixOS, you can just use the module (programs.skim.enable).'
    else
      echo 'On non-NixOS-systems, you can just directly source `~/.nix-profile/share/skim/<wanted_script.sh>`'
    fi >&2
    echo $out/share/skim
    SCRIPT
    chmod +x $out/bin/sk-share
  '';

  # https://github.com/lotabout/skim/issues/440
  doCheck = !stdenv.isAarch64;

  meta = with lib; {
    description = "Command-line fuzzy finder written in Rust";
    homepage = "https://github.com/lotabout/skim";
    license = licenses.mit;
    mainProgram = "sk";
    maintainers = with maintainers; [ dywedir ];
  };
}
