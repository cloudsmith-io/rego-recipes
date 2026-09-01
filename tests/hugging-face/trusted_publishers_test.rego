package cloudsmith_test

_upstream_hf_package(name) := {"v0": {"package": {
	"format": "huggingface",
	"uploader": {"slug": "cloudsmith-o6v"},
	"name": name,
}}}

test_match_google_model if {
	data.cloudsmith.match with input as _upstream_hf_package("google/gemma-2")
}

test_match_microsoft_model if {
	data.cloudsmith.match with input as _upstream_hf_package("microsoft/phi-3")
}

test_match_openai_model if {
	data.cloudsmith.match with input as _upstream_hf_package("openai/whisper-large")
}

test_match_mixed_case_publisher if {
	data.cloudsmith.match with input as _upstream_hf_package("FacebookAI/roberta-base")
}

test_no_match_wrong_case_publisher if {
	not data.cloudsmith.match with input as _upstream_hf_package("Google/gemma-2")
}

test_no_match_unknown_publisher if {
	not data.cloudsmith.match with input as _upstream_hf_package("unknown-org/some-model")
}

test_no_match_name_without_publisher if {
	not data.cloudsmith.match with input as _upstream_hf_package("some-model")
}

test_no_match_not_upstream if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"uploader": {"slug": "other-user"},
		"name": "google/gemma-2",
	}}}
}

test_no_match_missing_uploader if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"name": "google/gemma-2",
	}}}
}

test_no_match_missing_name if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"uploader": {"slug": "cloudsmith-o6v"},
	}}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"uploader": {"slug": "cloudsmith-o6v"},
		"name": "google/some-package",
	}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _upstream_hf_package("google/gemma-2")
	count(r) == 1
	r["Published by verified organisation google"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _upstream_hf_package("unknown-org/some-model")
	count(r) == 0
}
