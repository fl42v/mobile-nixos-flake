{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkForce;
  system_type = config.mobile.system.type;
  defaultUserName = "fl42v";
in
{
  imports = [
    ./phosh.nix
  ];

  config = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (final: prev: {
          gnome = prev.gnome.overrideScope' (gfinal: gprev: {
            gnome-control-center = gprev.gnome-control-center.overrideAttrs (attrs: {
              # so, yeah, apparently this bastards have tests enabled in the meson_options.txt
              # -> my doCheck's don't do shit
              patches = attrs.patches ++ [
                ./fuck_tests.patch # No, seriously, they suck ass
              ];
            });
          });
        })
      ];
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    networking.hostName = "n-chill-ada";      # ik, laaaaaaame
    boot.plymouth.enable = lib.mkForce false; # breaks boot (not sure, tho)

    users.users."${defaultUserName}" = {
      isNormalUser = true;
      password = "1234";
      extraGroups = [
        "dialout"
        "feedbackd"
        "networkmanager"
        "video"
        "wheel"
      ];
      shell = pkgs.fish;
    };
    services.openssh = {
      enable = true;
    };
    services.xserver.desktopManager.phosh.user = "fl42v";

    programs.fish.enable = true;
    environment.systemPackages = [
      inputs.nix-software-center.packages."aarch64-linux".nix-software-center
      inputs.nixos-conf-editor.packages."aarch64-linux".nixos-conf-editor
    ] ++ (with pkgs; [
      git
      mpv
      neovim
      #phosh
      wl-clipboard # for waydroid
    ]);

    virtualisation.waydroid.enable = true;

    # currently both options suck: pa doesn't work with waydroid and bt headphones,
    # and pw breaks mic-s and built-in audio

    #hardware.pulseaudio.enable = true;

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    }; 

    zramSwap.enable = true;
    # why, tho?
    networking.firewall.enable = false;
    system.stateVersion = "23.11";
  };
}
