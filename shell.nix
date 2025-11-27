{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz") {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ 
      bash
      coreutils
      bazelisk 
      python313
      git
      qemu
      vim
      dotnet-sdk_9
      wabt
    ];
  }
