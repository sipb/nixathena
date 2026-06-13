if set -q XDG_CONFIG_HOME
    set PKGSYNC_FILE $XDG_CONFIG_HOME/pkgsync
else
    set PKGSYNC_FILE ~/.config/pkgsync
end

if ! test -e $PKGSYNC_FILE
    echo "$PKGSYNC_FILE not found"
    exit 1
end

nix profile remove --all &> /dev/null

for line in (cat $PKGSYNC_FILE)
    if string match -q '#*' $line
        continue
    end
    echo "Installing $line"
    if string match -q '*#*' $line
        set PKG $line
    else
        set PKG nixpkgs#$line
    end
    nix profile add $PKG
end
