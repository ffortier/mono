{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz") {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ 
      coreutils
      bazelisk 
      bazel-buildtools 
      python313
      git
      qemu
      deno
      vim
    ];
  }
