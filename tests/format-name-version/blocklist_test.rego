package cloudsmith_test

_input(format, name, version) := {"v0": {"package": {
	"format": format,
	"name": name,
	"version": version,
}}}

test_match_blocked_by_format_name_version if {
	data.cloudsmith.match with input as _input("python", "malicious-lib", "0.1.0")
}

# Listed without a version, so every version is blocked.
test_match_blocked_by_format_name if {
	data.cloudsmith.match with input as _input("npm", "compromised-ui", "9.9.9")
}

test_no_match_unlisted_package if {
	not data.cloudsmith.match with input as _input("python", "safe-lib", "1.0.0")
}

test_no_match_wrong_version if {
	not data.cloudsmith.match with input as _input("python", "malicious-lib", "9.9.9")
}

test_match_format_name_entry_when_version_missing if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "npm",
		"name": "compromised-ui",
	}}}
}

test_no_match_versioned_entry_when_version_missing if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "malicious-lib",
	}}}
}

test_no_match_missing_name if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "npm",
		"version": "9.9.9",
	}}}
}

test_reason_message_versioned_entry if {
	r := data.cloudsmith.reason with input as _input("python", "malicious-lib", "0.1.0")
	count(r) == 1
	r["Matched by blocklist: {\"python:malicious-lib:0.1.0\"}"]
}

test_reason_message_format_name_entry if {
	r := data.cloudsmith.reason with input as _input("npm", "compromised-ui", "9.9.9")
	count(r) == 1
	r["Matched by blocklist: {\"npm:compromised-ui\"}"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("python", "safe-lib", "1.0.0")
	count(r) == 0
}
