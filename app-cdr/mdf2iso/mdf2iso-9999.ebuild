EAPI=8
inherit autotools git-r3
DESCRIPTION="Converts Alcohol 120% .mdf files to .iso files"
HOMEPAGE="https://salsa.debian.org/debian/mdf2iso"
EGIT_SRC_URI="https://salsa.debian.org/debian/mdf2iso.git"
LICENSE="GPL"
SLOT="0"
KEYWORDS=""
IUSE=""

#RESTRICT="strip"
#RDEPEND=""
#DEPEND="${RDEPEND}"
#BDEPEND="virtual/pkgconfig"

src_configure() {
	econf
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}
