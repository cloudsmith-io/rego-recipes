package cloudsmith_test

_upstream_hf := {"format": "huggingface", "uploader": {"slug": "cloudsmith-o6v"}}

test_match_incomplete_scan if {
	data.cloudsmith.match with input as {"v0": {
		"package": _upstream_hf,
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}

test_match_unsafe_scan if {
	data.cloudsmith.match with input as {"v0": {
		"package": _upstream_hf,
		"model_security": {"availability": "COMPLETE", "scan_summary": "UNSAFE"},
	}}
}

test_match_incomplete_and_unsafe if {
	data.cloudsmith.match with input as {"v0": {
		"package": _upstream_hf,
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "UNSAFE"},
	}}
}

test_no_match_complete_and_safe if {
	not data.cloudsmith.match with input as {"v0": {
		"package": _upstream_hf,
		"model_security": {"availability": "COMPLETE", "scan_summary": "SAFE"},
	}}
}

test_no_match_not_upstream if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "huggingface", "uploader": {"slug": "other-user"}},
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "python", "uploader": {"slug": "cloudsmith-o6v"}},
		"model_security": {"availability": "INCOMPLETE", "scan_summary": "SAFE"},
	}}
}
