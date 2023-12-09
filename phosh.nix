# https://github.com/NixOS/mobile-nixos/blob/974d9ac5c7834b98a435e6948bbdeaa9b90256fa/examples/phosh/phosh.nix
{ config, lib, pkgs, options, ... }:
{

  mobile.beautification = {
    silentBoot = lib.mkDefault true;
    splash = lib.mkDefault true;
  };

  services.xserver.desktopManager.phosh = {
    enable = true;
    group = "users";
    # overlays don't seem to work for some odd reason, and with checks this crap doesn't compile
    # this approach is also problematic, tho: if some other package needs gaynome, it still won't
    # compile
    #package = pkgs.phosh.override {
    #  gnome = pkgs.gnome.overrideScope' (gfinal: gprev: {
    #    gnome-control-center = gprev.gnome-control-center.overrideAttrs (attrs: {
    #      # so, yeah, apparently this bastards have tests enabled in the meson_options.txt
    #      # -> my doCheck's don't do shit
    #      patches = attrs.patches ++ [
    #        ./fuck_tests.patch # No, seriously, they suck ass
    #      ];

    #      #doCheck = false; # Fuck me? Fuck them!
    #      #checkPhase = ''
    #      #  runHook preCheck
    #      #  runHook postCheck
    #      #'';

    #      ## YOU KNOW WHAT? FUCK NATIVE CHECK INPUTS! I'VE KILLED A WHOLE DAMN DAY TO FIND OUT
    #      ## WHY THE FUCK THE BUILD FAILED DESPITE ME NOT TOUCHING FUCKING INPUTS
    #      #nativeBuildInputs = attrs.nativeBuildInputs ++ [
    #      #  pkgs.xorg.setxkbmap # ALSO, FUCK XORG
    #      #  pkgs.python311Packages.python-dbusmock
    #      #  pkgs.xvfb-run
    #      #];
    #    });
    #  });
    #};
  };

  programs.calls.enable = true;

  environment.systemPackages = with pkgs; [
    chatty              # IM and SMS
    firefox             # Web browser
    gnome-console       # Terminal
    #megapixels          # Camera (won't work anyways)
  ];

  hardware.sensor.iio.enable = true;
}
