default:
	just "$(uname)"
Darwin:
	sudo darwin-rebuild switch --flake .
Linux:
	sudo nixos-rebuild switch --flake .
