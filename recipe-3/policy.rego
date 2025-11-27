package cloudsmith

default match := false

# GNU General Public License (GPL) variants
gpl_licenses := {
    "GPL-1.0-only",
    "GPL-1.0-or-later",
    "GPL-2.0",
    "GPL-2.0-only",
    "GPL-2.0-or-later",
    "GPL-3.0",
    "GPL-3.0-only",
    "GPL-3.0-or-later",
}

# GNU Lesser General Public License (LGPL) variants
lgpl_licenses := {
    "LGPL-2.0",
    "LGPL-2.0-only",
    "LGPL-2.0-or-later",
    "LGPL-2.1",
    "LGPL-2.1-only",
    "LGPL-2.1-or-later",
    "LGPL-3.0",
    "LGPL-3.0-only",
    "LGPL-3.0-or-later",
}

# GNU Affero General Public License (AGPL) variants
agpl_licenses := {
    "AGPL-1.0",
    "AGPL-1.0-only",
    "AGPL-1.0-or-later",
    "AGPL-3.0",
    "AGPL-3.0-only",
    "AGPL-3.0-or-later",
}

# Mozilla Public License (MPL) variants
mpl_licenses := {
    "MPL-1.0",
    "MPL-1.1",
    "MPL-2.0",
}

# Common Development and Distribution License (CDDL) variants
cddl_licenses := {
    "CDDL-1.0",
    "CDDL-1.1",
}

# Eclipse Public License (EPL) variants
epl_licenses := {
    "EPL-1.0",
    "EPL-2.0",
}

# Open Software License (OSL) variants
osl_licenses := {
    "OSL-1.0",
    "OSL-2.0",
    "OSL-3.0",
}

# GNU Free Documentation License (GFDL) variants
gfdl_licenses := {
    "GFDL-1.1-only",
    "GFDL-1.1-or-later",
    "GFDL-1.2-only",
    "GFDL-1.2-or-later",
    "GFDL-1.3-only",
    "GFDL-1.3-or-later",
}

# Creative Commons Share Alike (CC-BY-SA) variants
cc_by_sa_licenses := {
    "CC-BY-SA-1.0",
    "CC-BY-SA-2.0",
    "CC-BY-SA-2.5",
    "CC-BY-SA-3.0",
    "CC-BY-SA-4.0",
}

# Other copyleft licenses
other_copyleft_licenses := {
    "QPL-1.0",
    "Sleepycat",
    "SSPL-1.0",
    "copyleft-next-0.3.0",
}

# Combined copyleft license set
copyleft := gpl_licenses | lgpl_licenses | agpl_licenses | mpl_licenses | cddl_licenses | epl_licenses | osl_licenses | gfdl_licenses | cc_by_sa_licenses | other_copyleft_licenses

# Main policy rule
match if {
    input.v0.package.license.oss_license.spdx_identifier in copyleft
} else {
    # Also check raw_license for copyleft identifiers (case-insensitive substring match)
    some l in copyleft
    lower(input.v0.package.license.oss_license.raw_license) contains lower(l)
}

# Provide a reason for blocking the package
reason[msg] {
    input.v0.package.license.oss_license.spdx_identifier in copyleft
    msg := sprintf("Blocked: SPDX license identifier '%v' is a copyleft license.", [input.v0.package.license.oss_license.spdx_identifier])
}
reason[msg] {
    some l in copyleft
    lower(input.v0.package.license.oss_license.raw_license) contains lower(l)
    msg := sprintf("Blocked: Raw license field contains copyleft license identifier '%v'.", [l])
}
