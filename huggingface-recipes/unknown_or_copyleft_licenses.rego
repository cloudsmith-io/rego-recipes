package cloudsmith

default match := false

# A list of copy-left SPDX identifiers.
copyleft_ids := {
    "lgpl-3.0",
    "agpl-3.0-only",
    "qpl-1.0",
    "gpl-2.0-or-later",
    "cpol-1.02",
    "lgpl-2.1",
    "agpl-3.0-or-later",
    "gpl-2.0",
    "ngpl",
    "agpl-3.0",
    "gpl-3.0",
    "gpl-3.0-or-later",
    "sleepycat",
    "gpl-3.0-only",
    "osl-3.0",
    "gpl-2.0-only",
    "apache-1.1",
}

pkg := input.v0.package
hf_pkg if "huggingface" == pkg.format

copy_left_msg contains msg if {
    some id in copyleft_ids
    id == pkg.license.oss_license.spdx_identifier
    msg := sprintf("License '%s' is considered copyleft", [pkg.license.oss_license.spdx_identifier])
}

missing_license contains msg if {
    not pkg.license.oss_license.spdx_identifier
    msg := "No license specified"
}


# Or statement, if the license is copy-left or missing an identified license.
match if {
    hf_pkg
    count(copy_left_msg) > 0
}

match if {
    hf_pkg
    count(missing_license) > 0
}
