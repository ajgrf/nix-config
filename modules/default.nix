{ utils }:

utils.lib.modulesFromList [
  ./desktop.nix
  ./nas
  ../hosts/iroh.nix
  ../hosts/petrus.nix
  ../hosts/poki.nix
  ../hosts/tenzin.nix
]
