if set -q XDG_CONFIG_HOME
    set pkgsync_file $XDG_CONFIG_HOME/pkgsync
else
    set pkgsync_file ~/.config/pkgsync
end

if ! test -e $pkgsync_file
    echo "$pkgsync_file not found" >&2
    echo "You should create a package list first" >&2
    exit 1
end

nix profile remove --all &> /dev/null

for line in (cat $pkgsync_file)
    if string match -q '#*' $line
        continue
    end
    echo "Installing $line"
    if string match -q '*#*' $line
        set pkg $line
    else
        set pkg nixpkgs#$line
    end
    nix profile add $pkg
end
