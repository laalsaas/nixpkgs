{ config, pkgs, lib, ... }:
let
  cfg = config.programs.tpm-fido;
in {
  options.programs.tpm-fido = {
    enable = lib.mkEnableOption ''
    tpm-fido. Note that you also have to add your user to the `tss`
    and the `tpm-fido` group.
    '';

    package = lib.mkPackageOption pkgs "tpm-fido" {};

    pinentryPackage = lib.mkPackageOption pkgs "pinentry" {
      default = [ "pinentry-gtk2" ];
      example = "pkgs.pinenty-qt";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="tpm-fido", MODE="0660"
    '';

    security.tpm2 = {
      enable = true;
      applyUdevRules = true;
    };

    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "uhid" ];

    users.groups.tpm-fido = {};

    systemd.user.services.tpm-fido = {
      description = "tpm-fido enables the use of the TPM for FIDO keys";
      serviceConfig = {
        Environment = "PATH=${cfg.pinentryPackage}/bin";
        ExecStart = "${lib.getExe cfg.package}";
      };
      wantedBy = [ "default.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ laalsaas ];
}
