#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-/mnt/lfs}"
LOGDIR="$ROOT/logs/toolchain"
SRC="$ROOT/sources"
JOBS="${JOBS:-$(nproc)}"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"

mkdir -p "$LOGDIR" "$SRC" "$LFS/tools"

echo "[!] Script squelette: téléchargez/validez les tarballs avant build."

build_binutils() {
	cd "$SRC"
	local pkg=binutils-2.43.1
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	../"$pkg"/configure --prefix="$LFS/tools" --with-sysroot="$LFS" --target="$TARGET" --disable-nls --disable-werror >"$LOGDIR/binutils.config.log"
	make -j"$JOBS" >"$LOGDIR/binutils.make.log"
	make install >"$LOGDIR/binutils.install.log"
}

build_gcc() {
	cd "$SRC"
	local pkg=gcc-13.2.0
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	../"$pkg"/configure --target="$TARGET" --prefix="$LFS/tools" --with-glibc-version=2.40 --with-sysroot="$LFS" --with-newlib --without-headers --enable-initfini-array --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++ >"$LOGDIR/gcc.config.log"
	make -j"$JOBS" all-gcc >"$LOGDIR/gcc.make.log"
	make -j"$JOBS" all-target-libgcc >>"$LOGDIR/gcc.make.log"
	make install-gcc >"$LOGDIR/gcc.install.log"
	make install-target-libgcc >>"$LOGDIR/gcc.install.log"
}

build_linux_headers() {
	cd "$SRC"
	local pkg=linux-6.6.54
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	cd "$pkg"
	make mrproper >"$LOGDIR/linux.mrproper.log"
	make headers >"$LOGDIR/linux.headers.log"
	find usr/include -name '.*' -delete
	rm -f usr/include/Makefile
	cp -rv usr/include "$LFS/usr"
}

build_glibc_headers() {
	cd "$SRC"
	local pkg=glibc-2.40
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	../"$pkg"/configure --prefix=/usr --host="$TARGET" --build="$(../"$pkg"/scripts/config.guess)" --enable-kernel=4.14 --with-headers="$LFS/usr/include" libc_cv_slibdir=/usr/lib >"$LOGDIR/glibc.config.log"
	make -j"$JOBS" >"$LOGDIR/glibc.make.log"
	make DESTDIR="$LFS" install >"$LOGDIR/glibc.install.log"
}

case "${1:-}" in
	binutils) build_binutils ;;
	gcc) build_gcc ;;
	linux-headers) build_linux_headers ;;
	glibc) build_glibc_headers ;;
	all) build_binutils; build_gcc; build_linux_headers; build_glibc_headers ;;
	*) echo "Usage: $0 {binutils|gcc|linux-headers|glibc|all}" >&2; exit 1 ;;
esac
