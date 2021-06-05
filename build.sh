#!/bin/sh
set -ue

REPODIR=$(pwd)
export SRCDEST=$REPODIR/tmp/srcdest
export BUILDDIR=$REPODIR/tmp/builddir
export PKGDEST=/srv/http/repo.praz.xyz/arch


build_dir() {
	oldpath=$(pwd)
	echo _____
	if [ ! -d "$1" ]; then
		echo "DIR $1 does not exist"
		exit 1
	fi
	cd "$1"

    	echo Building $1...
	makepkg -s --noconfirm --skippgpcheck || echo "???"
	cd $oldpath

}

build_aur() {
	AURPKGS=$(cat aur.txt)
	mkdir -p /tmp/aur
	cd /tmp/aur
	for pkg in ${AURPKGS} ; do
		echo "Downloading $pkg"
		paru -G "$pkg" --aur --nopgpfetch
		build_dir $pkg
	done
	cd $REPODIR
}

build_local() {
	for pkg in $(ls $REPODIR/pkgs) ; do
		build_dir pkgs/$pkg
	done

}

build_local
build_aur

