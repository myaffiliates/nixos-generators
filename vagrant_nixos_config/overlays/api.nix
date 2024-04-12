inputs:

final:
prev:

let
  buildPhpFromComposer = prev.callPackage ./build-php-from-composer.nix { };
in
{
  api = {
    inherit buildPhpFromComposer;
  };
}
