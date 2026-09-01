package cloudsmith_test

_input(format, name, version) := {"v0": {"package": {
	"format": format,
	"name": name,
	"version": version,
}}}

test_match_below_minimum if {
	data.cloudsmith.match with input as _input("python", "h11", "0.15.0")
}

test_no_match_at_minimum if {
	not data.cloudsmith.match with input as _input("python", "h11", "0.16.0")
}

test_no_match_above_minimum if {
	not data.cloudsmith.match with input as _input("python", "h11", "1.0.0")
}

test_no_match_package_not_in_map if {
	not data.cloudsmith.match with input as _input("python", "requests", "0.0.1")
}

test_no_match_same_name_different_format if {
	not data.cloudsmith.match with input as _input("npm", "h11", "0.0.1")
}

# Valid PEP 440, not valid SemVer.
test_match_pep440_post_release if {
	data.cloudsmith.match with input as _input("python", "h11", "1.2.3.post1")
}

test_match_pep440_release_candidate if {
	data.cloudsmith.match with input as _input("python", "h11", "1.2.3rc1")
}

test_match_two_component_version if {
	data.cloudsmith.match with input as _input("python", "h11", "1.2")
}

# The SemVer spelling parses, and is above the floor.
test_no_match_semver_prerelease if {
	not data.cloudsmith.match with input as _input("python", "h11", "1.2.3-rc1")
}

test_reason_message_unparseable_version if {
	r := data.cloudsmith.reason with input as _input("python", "h11", "1.2.3.post1")
	count(r) == 1
	r["Version cannot be checked against the minimum permitted 0.16.0"]
}

test_match_null_version if {
	data.cloudsmith.match with input as _input("python", "h11", null)
}

test_match_missing_version if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "h11",
	}}}
}

test_reason_message_missing_version if {
	r := data.cloudsmith.reason with input as {"v0": {"package": {
		"format": "python",
		"name": "h11",
	}}}
	count(r) == 1
	r["Version cannot be checked against the minimum permitted 0.16.0"]
}

test_no_match_missing_name if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"version": "0.15.0",
	}}}
}

test_reason_message_below_minimum if {
	r := data.cloudsmith.reason with input as _input("python", "h11", "0.15.0")
	count(r) == 1
	r["Version 0.15.0 is older than the minimum permitted 0.16.0"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("python", "h11", "1.0.0")
	count(r) == 0
}
