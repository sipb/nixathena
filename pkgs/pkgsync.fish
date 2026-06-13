# This script is a workaround for https://github.com/NixOS/nix/issues/7965
# Our simple trick is that we add the packages to a fresh new profile, and then atomically switch
# This also means we don't need do any file locking

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

set pkgs
for line in (cat $pkgsync_file)
    if string match -q '#*' $line
        continue
    end
    if string match -q '*#*' $line
        set -a pkgs $line
    else
        set -a pkgs nixpkgs#$line
    end
end

set profile ~/.local/state/nix/profiles/(date +%s)
nix profile add $pkgs --profile $profile
ln -sfn $profile ~/.local/state/nix/profile
