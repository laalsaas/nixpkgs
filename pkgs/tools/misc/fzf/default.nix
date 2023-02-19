{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, fetchpatch
, writeText
, writeShellScriptBin
, runtimeShell
, installShellFiles
, ncurses
, perl
, glibcLocales
, testers
, fzf
}:

let
  # on Linux, wrap perl in the bash completion scripts with the glibc locales,
  # so that using the shell completion (ctrl+r, etc) doesn't result in ugly
  # warnings on non-nixos machines
  ourPerl = if !stdenv.isLinux then perl else (
    writeShellScriptBin "perl" ''
      export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
      exec ${perl}/bin/perl "$@"
    '');
in
buildGoModule rec {
  pname = "fzf";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "junegunn";
    repo = pname;
    rev = version;
    hash = "sha256-1PKu8l4Mx17CpePUE0JEnLPNsUdJ0KvW6Lx6VZM27kI=";
  };

  vendorHash = "sha256-MsMwBBualAwJzCrv/WNBJakv6LcKZYsDUqkNmivUMOQ=";

  outputs = [ "out" "man" ];

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ ncurses ];

  ldflags = [
    "-s" "-w" "-X main.version=${version} -X main.revision=${src.rev}"
  ];

  patches = [
    # fix for test failure on 32-bit platforms
    # can be removed in the next release of fzf
    # https://github.com/junegunn/fzf/issues/3127
    (fetchpatch {
      url = "https://github.com/junegunn/fzf/commit/aa7361337d3f78ae1e32283ba395446025323abb.patch";
      hash = "sha256-ZmBdJa7eq9f58f2pL7QrtDSApkQJQBH/Em12J5xk3Q4=";
    })
  ];

  # The vim plugin expects a relative path to the binary; patch it to abspath.
  postPatch = ''
    sed -i -e "s|expand('<sfile>:h:h')|'$out'|" plugin/fzf.vim

    if ! grep -q $out plugin/fzf.vim; then
        echo "Failed to replace vim base_dir path with $out"
        exit 1
    fi

    # Has a sneaky dependency on perl
    # Include first args to make sure we're patching the right thing
    substituteInPlace shell/key-bindings.bash \
      --replace " perl -n " " ${ourPerl}/bin/perl -n "
  '';

  postInstall = ''
    install bin/fzf-tmux $out/bin

    installManPage man/man1/fzf.1 man/man1/fzf-tmux.1

    install -D plugin/* -t $out/share/vim-plugins/${pname}/plugin

    # Install shell integrations
    install -D shell/* -t $out/share/fzf/
    install -D shell/key-bindings.fish $out/share/fish/vendor_functions.d/fzf_key_bindings.fish
    mkdir -p $out/share/fish/vendor_conf.d
    echo fzf_key_bindings > $out/share/fish/vendor_conf.d/load-fzf-key-bindings.fish

    cat <<SCRIPT > $out/bin/fzf-share
    #!${runtimeShell}
    # TODO: remove this after 23.05, but ideally before 23.11, as well as in zsh-autoenv, skim and blesh.
    echo 'The ${pname}-share script is deprecated and will be removed soon.' >&2
    if [ -f "/etc/NIXOS" ]; then
      echo 'On NixOS, you can just use the module (programs.fzf.enable).'
    else
      echo 'On non-NixOS-systems, you can just directly source `~/.nix-profile/share/fzf/<wanted_script.sh>`'
    fi >&2
    echo $out/share/fzf
    SCRIPT
    chmod +x $out/bin/fzf-share
  '';

  passthru.tests.version = testers.testVersion {
    package = fzf;
  };

  meta = with lib; {
    homepage = "https://github.com/junegunn/fzf";
    description = "A command-line fuzzy finder written in Go";
    license = licenses.mit;
    maintainers = with maintainers; [ Br1ght0ne ma27 zowoq ];
    platforms = platforms.unix;
    changelog = "https://github.com/junegunn/fzf/blob/${version}/CHANGELOG.md";
  };
}
