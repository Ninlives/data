{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  outputs = { self, nixpkgs }:
    let system = "x86_64-linux";
    in with nixpkgs.legacyPackages.${system};
    with nixpkgs.lib; {
      content =
        builtins.mapAttrs (name: _: callPackage (./content + "/${name}") { })
        (builtins.readDir ./content);
      apps.${system}.update = with builtins;
        let
          script = writeShellScript "update" ''
            ${concatMapStringsSep "\n" (dir: ''
              pushd ./content/${dir}
              ${callPackage (./content + "/${dir}/update.nix") { }}
              popd
            '') (filter (dir: pathExists (./content + "/${dir}/update.nix"))
              (attrNames (readDir ./content)))}
          '';
        in {
          type = "app";
          program = "${script}";
        };
      checks.${system} = filterAttrs (_: v: isDerivation v) self.content;
    };
}
