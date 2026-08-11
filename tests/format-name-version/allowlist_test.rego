package cloudsmith_test

_input(format, name, version) := {"v0": {"package": {
	"format": format,
	"name": name,
	"version": version,
}}}

test_match_allowlisted_python_package if {
	data.cloudsmith.match with input as _input("python", "example-lib", "1.2.3")
}

test_match_allowlisted_npm_package if {
	data.cloudsmith.match with input as _input("npm", "example-ui", "4.5.6")
}

test_no_match_wrong_version if {
	not data.cloudsmith.match with input as _input("python", "example-lib", "9.9.9")
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as _input("ruby", "example-lib", "1.2.3")
}

test_no_match_unlisted_name if {
	not data.cloudsmith.match with input as _input("python", "other-lib", "1.2.3")
}

test_no_match_missing_version if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "example-lib",
	}}}
}

test_no_match_missing_name if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"version": "1.2.3",
	}}}
}

test_no_match_missing_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"name": "example-lib",
		"version": "1.2.3",
	}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input("python", "example-lib", "1.2.3")
	count(r) == 1
	r["Matched by allowlist: python:example-lib:1.2.3"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("python", "example-lib", "9.9.9")
	count(r) == 0
}
