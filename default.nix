{ lib ? import <nixpkgs/lib> }: src:

with lib;
let
  isGit = pathIsGitRepo (toString src + "/.git");
  repo = builtins.fetchGit { url = src; submodules = true; };
  dirty = repo.revCount == 0;
  filterSrc = src:
    cleanSourceWith {
      name = "source";
      inherit src;
      filter = path: _: !hasSuffix "nix" path;
    };
in
if isStorePath src then src
else if isGit then
  if dirty then filterSrc (gitignoreSource src) else repo
else builtins.path { name = "source"; path = src; }
