EAPI=8
inherit autotools git-r3
DESCRIPTION="Original Xbox emulator (fork of XQEMU)"
HOMEPAGE="https://xemu.app/"
EGIT_REPO_URI="https://github.com/xemu-project/xemu.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	sys-devel/gcc
	sys-libs/glibc
	dev-util/glslang
	x11-themes/hicolor-icon-theme
	media-libs/libsdl2
	dev-libs/glib
	media-libs/glu
	gui-libs/gtk
	media-libs/libepoxy
	net-libs/libpcap
	media-libs/libsamplerate
	net-libs/libslirp
	dev-cpp/nlohmann_json
	dev-python/distlib
	dev-python/pyyaml
	dev-cpp/tomlplusplus
	dev-util/vulkan-headers
	media-libs/vulkan-loader
	dev-libs/xxhash
	sys-libs/zlib
"

BDEPEND="virtual/pkgconfig
	dev-build/cmake
	net-misc/curl
	dev-vcs/git
	dev-build/meson
	"
src_prepare() {
	default
	eapply "${FILESDIR}/0001-Big-Endian-Patches.patch"
}


src_configure() {
	# --disable-download
	local myeconfargs=(
		--audio-drv-list="sdl" \
		--disable-docs
		--disable-werror
		--enable-pie
		--extra-cflags="-DXBOX=1"
		--target-list="i386-softmmu"
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake qemu-system-i386

}

src_install() {
	mv -v build/qemu-system-i386 build/xemu
	dobin build/xemu
	install -Dm644 ui/xemu.desktop ${D}/usr/share/applications/xemu.desktop
	local size
	for size in 16 24 32 48 64 128 256 512; do
		install -Dm644 ui/icons/xemu_${size}x${size}.png "${D}"/usr/share/icons/hicolor/${size}x${size}/apps/xemu.png
	done
	install -Dm644 ui/icons/xemu.svg "${D}"/usr/share/icons/hicolor/scalable/apps/xemu.svg
	install -Dm644 XEMU_LICENSE "${D}"/usr/share/licenses/xemu/LICENSE.txt

}
