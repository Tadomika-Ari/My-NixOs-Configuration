{ config, pkgs, lib, inputs, ... }:

let
    vars = import ./variable.nix;
in

{
    imports = [
        ./hardware-configuration.nix
	    inputs.silentSDDM.nixosModules.default
    ];

    nixpkgs.config.allowUnfree = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = 2;
    boot.kernelPackages = pkgs.linuxPackages;

    boot.plymouth = {
	    enable = true;
	    theme = "spinner";
    };
    boot.kernelParams = [ "quiet" "splash" ];

    services.displayManager.sddm.settings.General.DisplayStopDelay = 5000;

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    services.fprintd.enable = true;

    # /etc/nixos/configuration.nix
    nix.settings.trusted-users = [ "root" "@wheel" ];

    security.pam.services = {
        login.fprintAuth = lib.mkForce true;
        sudo.fprintAuth = false;
        polkit-1.fprintAuth = true;
        gdm-fingerprint.fprintAuth = true;
    };

    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
        settings = {
            Theme = {
                CursorTheme = "Adwaita";
                CursorSize = 24;
            };
            General.GreeterEnvironment = lib.mkForce "QML2_IMPORT_PATH=/run/current-system/sw/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,XCURSOR_THEME=Adwaita,XCURSOR_SIZE=24,QT_MEDIA_BACKEND=ffmpeg";
        };
    };    

    # Configure SilentSDDM
    programs.silentSDDM = {
        enable = true;
        theme = "rei";         # rei | default | ken | silvia | everforest | catppuccin-mocha | nord | ...
    # settings = { };      # options avancées (voir plus bas)
    };

    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
            libva-vdpau-driver
            libvdpau-va-gl
        ];
    };

    programs.hyprland = {
  	    enable = true;
  	    xwayland.enable = true;
    };

    services.thermald.enable = true;
    powerManagement.enable = true;

    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "fr_FR.UTF-8";
    console.keyMap = "fr";

    services.displayManager.gdm.enable = false;
    services.desktopManager.gnome.enable = true;
    services.displayManager.autoLogin.user = vars.username;
    services.xserver.xkb = {
        layout = "fr";
        variant = "";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
        };
    };

    programs.fish.enable = true;

    users.users.${vars.username} = {
        isNormalUser = true;
        description = vars.descriptionName;
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        shell = pkgs.fish;
    };
  
    programs.dconf.enable = true;

    services.accounts-daemon.enable = true;
    environment.etc."AccountsService/users/root".text = ''
        [User]
        SystemAccount=true
    '';

    environment.systemPackages = with pkgs; [
        git
        curl
        vim
        htop
        python3

	    gcc
        llvmPackages_20.clang
        llvmPackages_20.llvm
        gcovr
        criterion
        valgrind
        gnumake42
	    devenv
	    ollama
	    mpv
    ];

    virtualisation.docker.enable = true;

    hardware.enableRedistributableFirmware = true;

    nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
    };

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };

    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
    ];

    programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            openssl
        ];
    };

    system.stateVersion = "26.05";
}
