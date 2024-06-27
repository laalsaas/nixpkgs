{ fetchFromGitHub
, buildGoModule
, lib
}:

buildGoModule {
  pname = "tpm-fido";
  version = "unstable-2023-05-22";

  src = fetchFromGitHub {
    owner = "psanford";
    repo = "tpm-fido";
    rev = "5f8828b82b58f9badeed65718fca72bc31358c5c";
    hash = "sha256-Yfr5B4AfcBscD31QOsukamKtEDWC9Cx2ee4L6HM2554=";
  };

  vendorHash = "sha256-qm/iDc9tnphQ4qooufpzzX7s4dbnUbR9J5L770qXw8Y=";

  meta = with lib; {
    description = "A WebAuthn/U2F token protected by a TPM (Go/Linux)";
    longDescription = ''
      tpm-fido is FIDO token implementation for Linux that protects
      the token keys by using your system's TPM. tpm-fido uses Linux's
      uhid facility to emulate a USB HID device so that it is properly
      detected by browsers.

      This package is best used via the `programs.tpm-fido` module,
      which ensures required udev rules, as well as a pinentry program
    '';
    homepage = "https://github.com/psanford/tpm-fido/tree/main";
    license = licenses.mit;
    platform = platforms.linux;
    mainProgram = "tpm-fido";
    maintainers = with maintainers; [ laalsaas ];
  };
}
