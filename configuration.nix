{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkForce;
  system_type = config.mobile.system.type;
  defaultUserName = "fl42v";
in
{
  imports = [
    ./sxmo.nix
    #./phosh.nix #y'know what? fuck gnome. I can't make this stupid piece of crapware build without a fucking browser engine
    # like seriously, i hate this bullshit. I mean i knew DEs suck, but not THAT much
    #./plasma.nix # yeah, this piece of garbage also builds a web engine
  ];

  config = {
    documentation.enable = false;

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (final: prev: {

          sxmo-utils = prev.callPackage ./sxmo-utils.nix { }; # github:chuangzhu/nixpkgs-sxmo

          webkitgtk = (throw "fuck webkit in particular");

          networkmanager-openconnect = (throw "fuck openconnect in particular");

          xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (attrs: {
            outputs = [ "out" ];
            doCheck = false;
            preCheck = "";
            passthru = {};
            mesonFlags = [
              "--sysconfdir=/etc"
              "-Dpytest=disabled"
            ];

          });

          libadwaita = prev.libadwaita.overrideAttrs (attrs: {
            doCheck = false;
          });

          upower = prev.upower.overrideAttrs (attrs: {
            doCheck = false;
          });

          power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs (attrs: {
            doCheck = false;
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
              pkgs.protobufc
            ];

            mesonFlags = attrs.mesonFlags ++ [
              (lib.mesonBool "ssc-support" true)
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


    hardware.sensor.iio.enable = true;

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

    boot.initrd.network.ssh.enable = true;
    services.openssh = {
      enable = true;
    };

    services.xserver.desktopManager.sxmo = {
      enable = true;
      user = defaultUserName;
      group = "users";
    };

    fonts.fonts = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];

    fonts.fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Code Nerd Font" ];
      };
    };

    #services.xserver.displayManager.autoLogin = {
    #  user = defaultUserName;
    #};

    programs.fish.enable = true;
    environment.systemPackages = [
      inputs.nix-software-center.packages."aarch64-linux".nix-software-center
      inputs.nixos-conf-editor.packages."aarch64-linux".nixos-conf-editor
    ] ++ (with pkgs; [
      git
      neovim
      foot
      #mpv
      #phosh
      #wl-clipboard # for waydroid
    ]);

    #virtualisation.waydroid.enable = true;

    # currently both options suck: pa doesn't work with waydroid and bt headphones,
    # and pw breaks mic-s and built-in audio

    hardware.pulseaudio.enable = true;

    #hardware.pulseaudio.enable = lib.mkForce false;
    #security.rtkit.enable = true;
    #services.pipewire = {
    #  enable = true;
    #  alsa.enable = true;
    #  alsa.support32Bit = true;
    #  pulse.enable = true;
    #}; 


    #displayManager.lightdm = {
    #  enable = true;
    #  # Workaround for autologin only working at first launch.
    #  # A logout or session crashing will show the login screen otherwise.
    #  extraSeatDefaults = ''
    #    session-cleanup-script=${pkgs.procps}/bin/pkill -P1 -fx ${pkgs.lightdm}/sbin/lightdm
    #  '';
    #};

    zramSwap.enable = true;

    networking.networkmanager = {
      unmanaged = [ "rndis0" "usb0" ];
      enable = true;
      plugins = lib.mkForce [ pkgs.networkmanager-openvpn ];
    };

    mobile.boot.stage-1.networking.enable = lib.mkDefault true;
    system.stateVersion = "23.11";
  };
}
