{
	description = "SystemVerilog keyword matching for Neovim";

	inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

	outputs = {nixpkgs, ...}: let
		systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
	in {
		devShells =
			nixpkgs.lib.genAttrs systems (system: let
					pkgs = import nixpkgs {inherit system;};
				in {
					default =
						pkgs.mkShell {
							packages = [pkgs.cargo pkgs.rustc];
						};
				});
	};
}
