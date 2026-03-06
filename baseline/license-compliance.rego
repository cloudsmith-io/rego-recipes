# METADATA
# title: License compliance
# description: Flag packages with copyleft licenses (GPL, LGPL, AGPL, MPL, etc.)
package cloudsmith

default match := false

copyleft := {
	"GPL-1.0-only", "GPL-1.0-or-later", "GPL-2.0", "GPL-2.0-only",
	"GPL-2.0-or-later", "GPL-3.0", "GPL-3.0-only", "GPL-3.0-or-later",
	"LGPL-2.0", "LGPL-2.0-only", "LGPL-2.0-or-later",
	"LGPL-2.1", "LGPL-2.1-only", "LGPL-2.1-or-later",
	"LGPL-3.0", "LGPL-3.0-only", "LGPL-3.0-or-later",
	"AGPL-3.0", "AGPL-3.0-only", "AGPL-3.0-or-later",
	"MPL-1.0", "MPL-1.1", "MPL-2.0",
	"CDDL-1.0", "CDDL-1.1",
	"EPL-1.0", "EPL-2.0",
	"OSL-1.0", "OSL-2.0", "OSL-3.0",
	"SSPL-1.0",
}

match if {
	input.v0.package.license != null
	input.v0.package.license.oss_license != null

	lic := input.v0.package.license.oss_license.spdx_identifier
	lic != null
	lic in copyleft
}

reason[msg] if {
	match
	lic := input.v0.package.license.oss_license.spdx_identifier
	msg := sprintf(
		"Copyleft license detected (%s). Package blocked/quarantined per license policy.",
		[lic],
	)
}
