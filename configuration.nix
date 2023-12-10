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

          # sensory stuff
          libqmi = prev.libqmi.overrideAttrs (_: {
            version = "1.34.0";
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "mobile-broadband";
              repo = "libqmi";
              rev = "1.34.0";
              hash = "sha256-l9ev9ZOWicVNZ/Wj//KNd3NHcefIrLVriqJhEpwWvtQ=";
            };
          });

          libssc = (prev.callPackage ./packages/libssc.nix {}).override { libqmi = final.libqmi; };

          iio-sensor-proxy = prev.iio-sensor-proxy.overrideAttrs (attrs: {
            # https://gitlab.com/dylanvanassche/pmaports/-/tree/qcom-sdm845-sensors/temp/iio-sensor-proxy
            src = prev.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "hadess";
              repo = "iio-sensor-proxy";
              rev = "48cb957c41b8d51d882219866e1366c45e21c352";
              hash = "sha256-1faWUqkQIrngAehg8uRVyiE4PmIYHp9KNVd0tonemZQ=";
            };

            buildInputs = attrs.buildInputs ++ [
              final.libssc
            ];

            patches = [
              ./overlays/patches/0001-iio-sensor-proxy-depend-on-libssc.patch
              ./overlays/patches/0002-proximity-support-SSC-proximity-sensor.patch
              ./overlays/patches/0003-light-support-SSC-light-sensor.patch
              ./overlays/patches/0004-accelerometer-support-SSC-accelerometer-sensor.patch
              ./overlays/patches/0005-compass-support-SSC-compass-sensor.patch
              ./overlays/patches/0006-accelerometer-apply-accel-attributes.patch
              ./overlays/patches/0007-data-add-libssc-udev-rules.patch
            ];
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
