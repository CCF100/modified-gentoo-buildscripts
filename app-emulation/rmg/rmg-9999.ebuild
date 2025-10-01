# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Rosalie's Mupen GUI"
HOMEPAGE="https://github.com/Rosalie241/RMG"

inherit cmake git-r3

EGIT_REPO_URI="${HOMEPAGE}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-libs/hidapi media-libs/libsamplerate media-libs/speexdsp sys-libs/zlib[minizip] media-libs/libsdl3 media-libs/freetype =dev-qt/qtbase-6* dev-qt/qtsvg dev-qt/qtwebsockets"
BDEPEND="dev-vcs/git dev-lang/nasm dev-util/cmake dev-util/vulkan-headers"

src_configure() {
        #mkdir ${S}/build
        local mycmakeargs=(
                -S .
                -DCMAKE_BUILD_TYPE="Release"
                -DPORTABLE_INSTALL="OFF"
                -DCMAKE_INSTALL_PREFIX="${D}/usr"
        )
        # export src_dir="$(pwd)"
        # export build_dir="$(pwd)/build"
        # mkdir -p "$build_dir"
        # cmake -S "$src_dir" -B "$build_dir" -DCMAKE_BUILD_TYPE="Release" -DPORTABLE_INSTALL="OFF" -DCMAKE_INSTALL_PREFIX="/usr" -G "Ninja"
        # cmake --build "$build_dir"
        # cmake --install "$build_dir" --prefix="/usr"
        cmake_src_configure
}
