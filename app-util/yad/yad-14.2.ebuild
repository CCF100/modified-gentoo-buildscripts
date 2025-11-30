# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3 autotools xdg

DESCRIPTION="A fork of zenity - display graphical dialogs from shell scripts or command line"
HOMEPAGE="https://github.com/v1cont/yad"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~loong ~ppc ~ppc64 ~riscv x86 ~amd64-linux ~x86-linux"
IUSE="+gtksourceview +gspell +webkit"
EGIT_REPO_URI="$HOMEPAGE.git"
EGIT_COMMIT="v${PV}"

# TODO: X11 dependency is automagically enabled
RDEPEND="
	>=x11-libs/gtk+-3.24.34-r1
	webkit? ( >=net-libs/webkit-gtk-2.40.1:6 )
	gspell? ( app-text/gspell )
	gtksourceview? ( x11-libs/gtksourceview )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/itstool
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
"

src_configure() {
	eautoreconf
	#TODO: determine why binary crashes without --enable-standalone
	local myeconfargs=(
	--enable-standalone
	--enable-icon-browser
	)
	myconfargs+=$(use_enable webkit html)
	myconfargs+=$(use_enable gspell spell)
	myconfargs+=$(use_enable gtksourceview sourceview)
	econf ${myeconfargs[@]}
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}


