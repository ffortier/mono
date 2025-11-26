{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-25.11.tar.gz") {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ 
      bash
      coreutils
      bazelisk 
      bazel-watcher
      bazel-buildtools 
      python313
      git
      qemu
      deno
      vim
      dotnet-sdk_9
      wabt
    ];
  }
