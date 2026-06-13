## nixathena\.enable



Whether to enable Nixathena\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/default\.nix](../modules/default.nix)



## nixathena\.packages



list of packages to install



*Type:*
list of package



*Default:*

```nix
[
  <derivation discuss-10.0.17>
  <derivation remctl-3.18>
  <derivation moira-4.2.4.0>
  <derivation zephyr-3.1.2>
  <derivation python3.13-locker-support-10.4.8>
  <derivation barnowl-1.11-master-1f65aee>
  <derivation athrun-10.3.2-3c9c5b7>
]
```

*Declared by:*
 - [/modules/default\.nix](../modules/default.nix)



## nixathena\.discussd\.enable

Whether to enable discussd\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/services/discussd\.nix](../modules/services/discussd.nix)



## nixathena\.discussd\.openFirewall



open firewall for discuss (if service enabled)



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [/modules/services/discussd\.nix](../modules/services/discussd.nix)



## nixathena\.hesiod\.enable



Whether to enable Hesiod client library\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/hesiod\.nix](../modules/config/hesiod.nix)



## nixathena\.hesiod\.classes



Class search order used for Hesiod queries\.



*Type:*
string



*Default:*

```nix
"IN"
```

*Declared by:*
 - [/modules/config/hesiod\.nix](../modules/config/hesiod.nix)



## nixathena\.hesiod\.lhs



Domain prefix used for Hesiod queries\.



*Type:*
string



*Default:*

```nix
".ns"
```

*Declared by:*
 - [/modules/config/hesiod\.nix](../modules/config/hesiod.nix)



## nixathena\.hesiod\.nsswitch



Whether to configure Name Service Switch to use Hesiod\. This makes Linux aware of Athena users\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [/modules/config/hesiod\.nix](../modules/config/hesiod.nix)



## nixathena\.hesiod\.rhs



Default domain used for Hesiod queries\.



*Type:*
string



*Default:*

```nix
".athena.mit.edu"
```

*Declared by:*
 - [/modules/config/hesiod\.nix](../modules/config/hesiod.nix)



## nixathena\.krb5\.enable



Whether to enable Kerberos for ATHENA\.MIT\.EDU\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/krb5\.nix](../modules/config/krb5.nix)



## nixathena\.ldap\.enable



Whether to enable LDAP for MIT\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/ldap\.nix](../modules/config/ldap.nix)



## nixathena\.lightdm\.enable



Whether to enable LightDM\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/lightdm\.nix](../modules/config/lightdm.nix)



## nixathena\.pam-afs-session\.enable



Whether to enable pam-afs-session\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/pam-afs-session\.nix](../modules/config/pam-afs-session.nix)



## nixathena\.pkgsync\.enable



Whether to enable pkgsync, a nix profile convenience wrapper\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/pkgsync\.nix](../modules/config/pkgsync.nix)



## nixathena\.pyhesiodfs\.enable



Whether to enable pyhesiodfs\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/services/pyhesiodfs\.nix](../modules/services/pyhesiodfs.nix)



## nixathena\.remctld\.enable



Whether to enable remctld\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.commands



command definitions



*Type:*
attribute set of attribute set of (submodule)

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.commands\.\<name>\.\<name>\.acl



ACL for the command



*Type:*
list of string



*Default:*

```nix
[
  "ANYUSER"
]
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.commands\.\<name>\.\<name>\.executable



Executable to run



*Type:*
string



*Example:*

```nix
"/bin/echo"
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.commands\.\<name>\.\<name>\.help



Argument for the command that will print help for the subcommand



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"--help"
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.commands\.\<name>\.\<name>\.user



user to run the command as



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"apache2"
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.remctld\.openFirewall



open firewall for discuss (if service enabled)



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [/modules/services/remctld\.nix](../modules/services/remctld.nix)



## nixathena\.workstation



Whether to configure the computer as an Athena workstation and allow any Athena user to log in\.

Note that if you have SSH enabled, then any Athena user will be able to SSH into your computer!



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [/modules/default\.nix](../modules/default.nix)



## nixathena\.zephyr\.enable



Whether to enable Zephyr\.



*Type:*
boolean



*Default:*

```nix
config.nixathena.workstation
```



*Example:*

```nix
true
```

*Declared by:*
 - [/modules/config/zephyr\.nix](../modules/config/zephyr.nix)


