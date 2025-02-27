.PHONY: update
update:
	home-manager switch --flake .#Aventrius

.PHONY: clean
clean:
	nix-collect-garbage -d
