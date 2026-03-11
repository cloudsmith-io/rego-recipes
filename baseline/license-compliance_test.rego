package cloudsmith_test

_input(spdx) := {"v0": {"package": {"license": {"oss_license": {"spdx_identifier": spdx}}}}}

test_match_gpl3 if {
	data.cloudsmith.match with input as _input("GPL-3.0-only")
}

test_match_agpl if {
	data.cloudsmith.match with input as _input("AGPL-3.0-only")
}

test_match_lgpl if {
	data.cloudsmith.match with input as _input("LGPL-2.1-only")
}

test_no_match_mit if {
	not data.cloudsmith.match with input as _input("MIT")
}

test_no_match_apache if {
	not data.cloudsmith.match with input as _input("Apache-2.0")
}

test_no_match_null_license if {
	not data.cloudsmith.match with input as {"v0": {"package": {"license": null}}}
}

test_no_match_null_oss_license if {
	not data.cloudsmith.match with input as {"v0": {"package": {"license": {"oss_license": null}}}}
}

test_reason_message if {
	expected := "Copyleft license detected (GPL-3.0-only). Package blocked/quarantined per license policy."
	data.cloudsmith.reason[expected] with input as _input("GPL-3.0-only")
}
