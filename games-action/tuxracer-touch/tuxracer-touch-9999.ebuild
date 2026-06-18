# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools desktop xdg git-r3

DESCRIPTION=" Ubuntu touch tux racer port"
HOMEPAGE="https://sourceforge.net/p/extremetuxracer/wiki/Home/"
#SRC_URI="https://download.sourceforge.net/extremetuxracer/etr-${PV}.tar.xz -> ${P}.tar.xz"
EGIT_REPO_URI="https://github.com/laurie-bradshaw/tuxracer-touch.git"

#S="${WORKDIR}/etr-${PV/_/}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

# <media-libs/libsfml-3: breaking changes
# https://sourceforge.net/p/extremetuxracer/discussion/help/thread/6de9a5beae/
RDEPEND="
	<media-libs/libsfml-3.0
	>=media-libs/libsfml-2.4:0=
	virtual/glu
	virtual/opengl
	media-libs/sdl2-mixer
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	# kind of ugly in there so we'll do it ourselves
	#sed -i -e '/SUBDIRS/s/resources doc//' Makefile.am || die
	#eautoreconf
	sed -i -e 's/CFLAGS = /CFLAGS = -std=c11 /g' Makefile || die
}

src_install() {
	default
	dodoc doc/{code,courses_events,guide,score_algorithm}
	doicon -s 64 resources/etr.png
	doicon -s scalable resources/etr.svg
	domenu resources/net.sourceforge.extremetuxracer.desktop
}
