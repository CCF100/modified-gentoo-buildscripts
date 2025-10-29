EAPI=8

inherit desktop git-r3

DESCRIPTION="Equibop is a fork of Vesktop."
HOMEPAGE="https://github.com/Equicord/Equibop"
EGIT_REPO_URI="https://github.com/Equicord/Equibop.git"
EGIT_COMMIT="v${PV}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=network-sandbox

BDEPEND="sys-apps/pnpm net-libs/nodejs[npm] dev-lang/bun-bin"

#S="${WORKDIR}/Equibop-${PV}"

src_compile() {
	#export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
	pnpm i
	pnpm package:dir
}

src_install() {
	insinto /opt/equibop
	doins -r dist/linux-unpacked
	newicon static/icon.png equibop.png

	fperms +x /opt/equibop/linux-unpacked/equibop

	make_desktop_entry /opt/equibop/linux-unpacked/equibop Equibop
	dosym /opt/equibop/linux-unpacked/equibop /usr/bin/equibop
}
