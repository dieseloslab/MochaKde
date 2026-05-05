{ lib, options, ... }:

let
  hasOpt = path: lib.hasAttrByPath path options;
in
lib.mkMerge [
  {
    environment.etc."firefox/policies/policies.json" = lib.mkOverride 0 {
      text = ''
        {
          "policies": {}
        }
      '';
      mode = "0644";
    };
  }

  (lib.optionalAttrs (hasOpt [ "programs" "firefox" "policies" ]) {
    programs.firefox.policies = lib.mkOverride 0 {};
  })

  (lib.optionalAttrs (hasOpt [ "programs" "firefox" "preferences" ]) {
    programs.firefox.preferences = lib.mkOverride 0 {};
  })

  (lib.optionalAttrs (hasOpt [ "programs" "firefox" "autoConfig" ]) {
    programs.firefox.autoConfig = lib.mkOverride 0 "";
  })
]
