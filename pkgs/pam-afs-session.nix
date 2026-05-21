{ stdenv, lib, fetchurl,
  pam, krb5, openafs,
}:

# Note that there are two projects named pam_krb5! The one in nixpkgs doesn't have AFS support so we need to use pam-afs-session instead
# Based on https://github.com/NixOS/nixpkgs/blob/f4df4db3be2a5c3926b406d1b2ddeb5d88a6d94d/pkgs/by-name/pa/pam_krb5/package.nix#L27
stdenv.mkDerivation (finalAttrs: {
  pname = "pam-afs-session";
  version = "2.6";

  src = fetchurl {
    url = "https://archives.eyrie.org/software/afs/pam-afs-session-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-v2wqYKB57FORfSaKl9Awc15hiftWkA01xvawGRtd/MU=";
  };

  buildInputs = [
    pam
    krb5
    openafs
  ];

  meta = {
    homepage = "https://www.eyrie.org/~eagle/software/pam-afs-session/";
    description = "PAM module providing AFS session support";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
  };
})
