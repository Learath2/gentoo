# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A Teeworlds modification with a unique cooperative gameplay"
HOMEPAGE="https://ddnet.tw"
SRC_URI="https://github.com/ddnet/ddnet/archive/${PV}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug dedicated mysql"

PYTHON_COMPAT=( python{2_7,3_4} )

inherit eutils cmake-utils python-any-r1

DEPEND="
	!dedicated? (
		app-arch/bzip2
		media-libs/freetype
		media-libs/libsdl2[X,sound,opengl,video]
		virtual/glu
		virtual/opengl
		x11-libs/libX11
		net-misc/curl[ssl]
		media-libs/opus
		media-libs/opusfile )
	mysql? (
		virtual/libmysqlclient
		dev-db/mysql-connector-c++ )"

RDEPEND="${DEPEND}"

PATCHES="${FILESDIR}/01-create-generated-directory.patch"

src_configure() {
	local mycmakeargs=(
		-DMYSQL="$(usex mysql ON OFF)"
		-DCLIENT="$(usex dedicated OFF ON)"
	)

	use debug && CMAKE_BUILD_TYPE=Debug

	sed -i -e "s/teeworlds/ddnet/" src/engine/shared/storage.cpp

	cmake-utils_src_configure
}

src_install() {
	use dedicated || dobin "${BUILD_DIR}/DDNet"
	dobin "${BUILD_DIR}/DDNet-Server"

	insinto /usr/share/${PN}
	doins -r data

	make_desktop_entry DDNet DDNet "" Game
}
