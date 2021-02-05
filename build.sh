#!/bin/sh
set -ue

AURPKGS=$(cat aur.txt)
mkdir -p /tmp/aur
mkdir -p /tmp/crepo

cp /var/lib/pacman/sync/crepo.db /tmp/crepo
ln -sf crepo.db /tmp/crepo/crepo.db.tar.gz
cd /tmp/aur

for pkg in ${AURPKGS} ; do

	# $(echo $d | grep _) && continue;
	echo _____
	echo "$pkg"
	paru -G "$pkg" --aur --nopgpfetch
	cd "$pkg"
	# ls -al

	OLD_VERSION="$(pacman -Sl crepo | grep "$pkg" | awk '{print $3}' )"
	NEW_VERSION="$(. ./PKGBUILD; echo ${pkgver}-${pkgrel})"

	echo n: $NEW_VERSION o: ${OLD_VERSION:-0}
	if test $(vercmp $NEW_VERSION ${OLD_VERSION:-0}) -gt 0; then
		echo Updating $pkg...
		PKGDEST=/tmp/crepo makepkg -s --noconfirm --skippgpcheck
	fi

	cd ..
done

cd /tmp/crepo
repo-add crepo.db.tar.gz *.pkg.tar.zst


