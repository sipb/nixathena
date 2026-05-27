*Updated version of https://sipb.mit.edu/previously/doc/kerberized-server/*

If you want kerberized logins on a server you run, you'll need a *keytab* from accounts. Fill out the [keytab request form](https://ist.mit.edu/accounts/keytab), which sends them an e-mail.

Your new keytab will be in `/mit/accounts/srvtabs/FOR_YOURUSERNAME`, which is AFS and vaguely insecure. You probably want to install it in `/etc/krb5.keytab`, and then set a new (random) key.

```bash
# mv -f /etc/krb5.keytab /etc/krb5.keytab.old  # back up any keytab you already have
# mv /mit/accounts/srvtabs/FOR_JOEUSER/joeserver-new-keytab /etc/krb5.keytab
# k5srvutil change -e aes256-cts:normal,aes128-cts:normal # Only use secure ciphers
# k5srvutil delold # Delete old keys
```

Make sure your `/etc/ssh/sshd_config` file includes the line

```
GSSAPIAuthentication yes
```

This will let you SSH in with Kerberos.

Now on the client machine, run `kinit USERNAME` and then `ssh -K USERNAME@server.mit.edu`. If you run into permission issues on the server and `klist` doesn't show any tickets, run `kinit -f USERNAME` on the client instead to make the tickets forwardable (this is already enabled by default on machines running Nixathena).
