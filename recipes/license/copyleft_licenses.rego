# METADATA
# title: Copyleft licenses
# description: Match packages whose declared license, or any SBOM component license, is copyleft.
package cloudsmith

default match := false

pkg := input.v0.package

copyleft := {
	# GNU General Public License (GPL)
	"GPL-1.0-only",
	"GPL-1.0-or-later",
	"GPL-2.0",
	"GPL-2.0-only",
	"GPL-2.0-or-later",
	"GPL-3.0",
	"GPL-3.0-only",
	"GPL-3.0-or-later",

	# GNU Lesser General Public License (LGPL)
	"LGPL-2.0",
	"LGPL-2.0-only",
	"LGPL-2.0-or-later",
	"LGPL-2.1",
	"LGPL-2.1-only",
	"LGPL-2.1-or-later",
	"LGPL-3.0",
	"LGPL-3.0-only",
	"LGPL-3.0-or-later",

	# GNU Affero General Public License (AGPL)
	"AGPL-1.0",
	"AGPL-1.0-only",
	"AGPL-1.0-or-later",
	"AGPL-3.0",
	"AGPL-3.0-only",
	"AGPL-3.0-or-later",

	# GNU Free Documentation License (GFDL)
	"GFDL-1.1-only",
	"GFDL-1.1-or-later",
	"GFDL-1.2-only",
	"GFDL-1.2-or-later",
	"GFDL-1.3-only",
	"GFDL-1.3-or-later",

	# Mozilla Public License (MPL)
	"MPL-1.0",
	"MPL-1.1",
	"MPL-2.0",

	# Common Development and Distribution License (CDDL)
	"CDDL-1.0",
	"CDDL-1.1",

	# Eclipse Public License (EPL)
	"EPL-1.0",
	"EPL-2.0",

	# Open Software License (OSL)
	"OSL-1.0",
	"OSL-2.0",
	"OSL-3.0",

	# Creative Commons Share Alike (CC-BY-SA)
	"CC-BY-SA-1.0",
	"CC-BY-SA-2.0",
	"CC-BY-SA-2.5",
	"CC-BY-SA-3.0",
	"CC-BY-SA-4.0",

	# Other
	"QPL-1.0",
	"Sleepycat",
	"SSPL-1.0",
	"copyleft-next-0.3.0",
}

license := pkg.license.oss_license.spdx_identifier

copyleft_found contains license if license in copyleft

copyleft_found contains entry.license.id if {
	some component in input.v0.sbom.components
	some entry in component.licenses
	entry.license.id in copyleft
}

match if count(copyleft_found) > 0

reason contains sprintf("Copyleft licenses detected: %v", [copyleft_found]) if match