package cloudsmith_test

_upstream_hf := {"format": "huggingface", "uploader": {"slug": "cloudsmith-o6v"}}

_input(model_security) := {"v0": {"package": _upstream_hf, "model_security": model_security}}

test_match_incomplete_scan if {
	data.cloudsmith.match with input as _input({"availability": "INCOMPLETE", "scan_summary": "SAFE"})
}

test_match_unsafe_scan if {
	data.cloudsmith.match with input as _input({"availability": "COMPLETE", "scan_summary": "UNSAFE"})
}

test_match_incomplete_and_unsafe if {
	data.cloudsmith.match with input as _input({"availability": "INCOMPLETE", "scan_summary": "UNSAFE"})
}

test_no_match_complete_and_safe if {
	not data.cloudsmith.match with input as _input({"availability": "COMPLETE", "scan_summary": "SAFE"})
}

test_match_missing_model_security if {
	data.cloudsmith.match with input as {"v0": {"package": _upstream_hf}}
}

test_match_missing_availability if {
	data.cloudsmith.match with input as _input({"scan_summary": "SAFE"})
}

test_match_missing_scan_summary if {
	data.cloudsmith.match with input as _input({"availability": "COMPLETE"})
}

test_match_empty_model_security if {
	data.cloudsmith.match with input as _input({})
}

test_no_match_not_upstream if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "huggingface", "uploader": {"slug": "other-user"}},
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}

test_no_match_missing_uploader if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "huggingface"},
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "python", "uploader": {"slug": "cloudsmith-o6v"}},
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as {"v0": {"package": _upstream_hf}}
	count(r) == 1
	r["Model security scan is missing, incomplete or unsafe"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input({"availability": "COMPLETE", "scan_summary": "SAFE"})
	count(r) == 0
}
