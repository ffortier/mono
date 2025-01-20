{ pkgs ? import <nixpkgs> {} }:
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
      gedit
    ];
  }
