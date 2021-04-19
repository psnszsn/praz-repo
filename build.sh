#!/bin/sh
set -ue

export SRCDEST=/tmp/srcdest
export BUILDDIR=/tmp/builddir

REPODIR=$(pwd)
AURPKGS=$(cat aur.txt)
mkdir -p /tmp/aur
mkdir -p /tmp/crepo

cp /var/lib/pacman/sync/crepo.db /tmp/crepo
ln -sf crepo.db /tmp/crepo/crepo.db.tar.gz

cd /tmp/aur
for pkg in ${AURPKGS} ; do
	echo _____
	echo "$pkg"
	paru -G "$pkg" --aur --nopgpfetch
	cd "$pkg"

	OLD_VERSION="$(pacman -Sl crepo | grep "$pkg" | awk '{print $3}' )"
	NEW_VERSION="$(. ./PKGBUILD; echo ${epoch:-0}:${pkgver}-${pkgrel})"

	echo n: $NEW_VERSION o: ${OLD_VERSION:-0}
	if test $(vercmp $NEW_VERSION ${OLD_VERSION:-r0}) -gt 0; then
		echo Updating $pkg...
		PKGDEST=/tmp/crepo makepkg -s --noconfirm --skippgpcheck
	fi

	cd ..
done


cd $REPODIR/pkgs
for pkg in $(ls $REPODIR/pkgs) ; do
	echo ____
	echo "$pkg"
	cd "$pkg"
	OLD_VERSION="$(pacman -Sl crepo | grep "$pkg" | awk '{print $3}' )"
	NEW_VERSION="$(. ./PKGBUILD; echo ${epoch:-0}:${pkgver}-${pkgrel})"

	echo n: $NEW_VERSION o: ${OLD_VERSION:-a}
	if test $(vercmp $NEW_VERSION ${OLD_VERSION:-a}) -gt 0; then
		echo Updating $pkg...
		PKGDEST=/tmp/crepo makepkg -s --noconfirm --skippgpcheck
	fi

	cd ..
done

cd /tmp/crepo
repo-add crepo.db.tar.gz *.pkg.tar.zst
rm crepo.files*


