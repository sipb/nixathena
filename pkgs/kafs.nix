{
  stdenv,
  lib,
  fetchgit,
  krb5,
  openssl,
  keyutils,
  kmod,
}:

# Based on https://aur.archlinux.org/packages/kafs
stdenv.mkDerivation (finalAttrs: {
  pname = "kafs";
  version = "0.5";

  src = fetchgit {
    url = "git://git.infradead.org/users/dhowells/kafs-client.git";
    name = "kafs-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lg2Unaj7kUwin4kLlEyPpyxuOxfAMZ70nFVf9zkB2hg=";
  };

  buildInputs = [
    krb5
    openssl
    keyutils
  ];

  installFlags = [
    "DESTDIR=$(out)"
    "BINDIR=/bin"
    "LIBEXECDIR=/libexec"
    "MANDIR=/share/man"
    "DATADIR=/share/kafs-client"
    "UNITDIR=/lib/systemd/system"
    "INCLUDEDIR=/include"
  ];

  # TODO: The kafs module fails to load because CONFIG_AF_RXRPC_IPV6 is not set in the default NixOS kernel
  postInstall = ''
    substituteInPlace $out/lib/systemd/system/kafs-config.service \
      --replace-fail /sbin/modprobe ${kmod}/bin/modprobe \
      --replace-fail /usr/libexec/kafs-preload $out/libexec/kafs-preload
  '';

  outputs = [
    "out"
    "man"
    "dev"
  ];

  meta = {
    homepage = "https://www.infradead.org/~dhowells/kafs/";
    description = "kafs client tools";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2;
  };
})
