package cloudsmith_test

_input(architectures) := {"v0": {"package": {"architectures": architectures}}}

test_no_match_allowed_architecture if {
	not data.cloudsmith.match with input as _input([{"name": "amd64"}])
}

test_match_disallowed_architecture if {
	data.cloudsmith.match with input as _input([{"name": "arm64"}])
}

test_match_mixed_architectures if {
	data.cloudsmith.match with input as _input([{"name": "amd64"}, {"name": "arm64"}])
}

test_no_match_empty_architectures if {
	not data.cloudsmith.match with input as _input([])
}

test_no_match_missing_architectures if {
	not data.cloudsmith.match with input as {"v0": {"package": {}}}
}

test_no_match_architecture_entry_without_name if {
	not data.cloudsmith.match with input as _input([{"id": 1}])
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input([{"name": "arm64"}])
	count(r) == 1
	r["Architecture disallowed: {\"arm64\"}. Allowed: {\"amd64\"}"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input([{"name": "amd64"}])
	count(r) == 0
}
