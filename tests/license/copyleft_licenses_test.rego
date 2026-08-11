package cloudsmith_test

_input(spdx) := {"v0": {"package": {"license": {"oss_license": {"spdx_identifier": spdx}}}}}

_sbom(ids) := {"v0": {
	"package": {},
	"sbom": {"components": [{"licenses": [{"license": {"id": id}} | some id in ids]}]},
}}

test_match_gpl3 if {
	data.cloudsmith.match with input as _input("GPL-3.0-only")
}

test_match_agpl if {
	data.cloudsmith.match with input as _input("AGPL-3.0-only")
}

test_match_lgpl if {
	data.cloudsmith.match with input as _input("LGPL-2.1-only")
}

test_match_mpl if {
	data.cloudsmith.match with input as _input("MPL-2.0")
}

test_no_match_mit if {
	not data.cloudsmith.match with input as _input("MIT")
}

test_no_match_apache if {
	not data.cloudsmith.match with input as _input("Apache-2.0")
}

test_match_copyleft_in_sbom_component if {
	data.cloudsmith.match with input as _sbom(["MIT", "GPL-2.0-only"])
}

test_no_match_permissive_sbom_components if {
	not data.cloudsmith.match with input as _sbom(["MIT", "Apache-2.0"])
}

test_match_permissive_declared_copyleft_component if {
	data.cloudsmith.match with input as {"v0": {
		"package": {"license": {"oss_license": {"spdx_identifier": "MIT"}}},
		"sbom": {"components": [{"licenses": [{"license": {"id": "GPL-3.0-only"}}]}]},
	}}
}

test_no_match_missing_license_and_sbom if {
	not data.cloudsmith.match with input as {"v0": {"package": {}}}
}

test_no_match_missing_oss_license if {
	not data.cloudsmith.match with input as {"v0": {"package": {"license": {}}}}
}

test_no_match_missing_spdx_identifier if {
	not data.cloudsmith.match with input as {"v0": {"package": {"license": {"oss_license": {}}}}}
}

test_no_match_empty_sbom_components if {
	not data.cloudsmith.match with input as {"v0": {"package": {}, "sbom": {"components": []}}}
}

test_no_match_sbom_component_without_licenses if {
	not data.cloudsmith.match with input as {"v0": {"package": {}, "sbom": {"components": [{"name": "x"}]}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input("GPL-3.0-only")
	count(r) == 1
	r["Copyleft licenses detected: {\"GPL-3.0-only\"}"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("MIT")
	count(r) == 0
}
