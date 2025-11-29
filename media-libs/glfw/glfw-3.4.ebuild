# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib git-r3

DESCRIPTION="Portable OpenGL FrameWork"
HOMEPAGE="https://www.glfw.org/"
EGIT_REPO_URI="https://github.com/glfw/glfw.git"
EGIT_COMMIT="3eaf1255b29fdf5c2895856c7be7d7185ef2b241"


LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ~ppc64 ~riscv x86"
IUSE="wayland X"

# Most are dlopen'd so use strings or check the source:
# grep -Eiro '[a-z0-9-]+\.so\.[0-9]+'
DEPEND="
	wayland? (
		dev-libs/wayland[${MULTILIB_USEDEP}]
		dev-libs/wayland-protocols
	)
	X? (
		x11-base/xorg-proto
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXinerama[${MULTILIB_USEDEP}]
		x11-libs/libxkbcommon[${MULTILIB_USEDEP}]
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
	)
"
RDEPEND="
	${DEPEND}
	media-libs/libglvnd[X?,${MULTILIB_USEDEP}]
	wayland? (
		gui-libs/libdecor[${MULTILIB_USEDEP}]
	)
	X? (
		x11-libs/libXrender[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	)
"
BDEPEND="
	wayland? (
		dev-util/wayland-scanner
		kde-frameworks/extra-cmake-modules
	)
"

PATCHES=(
	"${FILESDIR}/0001-Ignore-some-additional-errors.patch"
	#"${FILESDIR}/0003-Don-t-crash-on-calls-to-focus-or-icon.patch"
	#"${FILESDIR}/0007-Platform-Prefer-Wayland-over-X11.patch"
	#"${FILESDIR}/0008-Wayland-Add-support-for-wp_fractional_scale_v1.patch"
	#"${FILESDIR}/0009-Defer-setting-cursor-position-until-the-cursor-is-lo.patch"
)


src_configure() {
	local mycmakeargs=(
		-DGLFW_BUILD_EXAMPLES=no
		-DGLFW_BUILD_WAYLAND=$(usex wayland)
		-DGLFW_BUILD_X11=$(usex X)
	)

	cmake-multilib_src_configure
}
