# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

  networking.hostName = "grafanix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.defaultGateway = "192.168.100.1";
  networking.nameservers = [ "192.168.100.1" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kuala_Lumpur";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ms_MY.UTF-8";
    LC_IDENTIFICATION = "ms_MY.UTF-8";
    LC_MEASUREMENT = "ms_MY.UTF-8";
    LC_MONETARY = "ms_MY.UTF-8";
    LC_NAME = "ms_MY.UTF-8";
    LC_NUMERIC = "ms_MY.UTF-8";
    LC_PAPER = "ms_MY.UTF-8";
    LC_TELEPHONE = "ms_MY.UTF-8";
    LC_TIME = "ms_MY.UTF-8";
  };

  # Configure keymap in X11
  #services.xserver = {
  #  layout = "us";
  #  xkbVariant = "";
  #};

  # Enable zsh system-side to source necessary files
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.noseferatu = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "whoami";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
	zsh
	antibody
	tmux
	ansible
	stow
	magic-wormhole
	rsync
	ripgrep
	fzf
	btop
	gnumake
	gccgo
	cmake
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
	git
  ];

  # virtualisation
  # virtualisation.containerd.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      server = {
	http_addr = "127.0.0.1";
	http_port = 3000;
	domain = "noseferatu.monitoring";
	root_url = "http://${toString config.services.grafana.settings.server.domain}/grafana";
      };
    };
  };

  services.victoriametrics.enable = true;

  services.nginx = {
    enable = true;
    virtualHosts.${config.services.grafana.settings.server.domain}= {
      locations = {
	"/grafana/" = {
	  proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
	  proxyWebsockets = true;
	  extraConfig = 
	    "proxy_set_header Host $host;"
	    ;
	};
	"/victoriametrics/" = {
	  proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:8428/";
	  proxyWebsockets = true;
	};
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment? yes I did my man :)

  nixpkgs.config.allowUnfree = true;
}
