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

test_no_match_unknown_publisher if {
	not data.cloudsmith.match with input as _upstream_hf_package("unknown-org/some-model")
}

test_no_match_not_upstream if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"uploader": {"slug": "other-user"},
		"name": "google/gemma-2",
	}}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"uploader": {"slug": "cloudsmith-o6v"},
		"name": "google/some-package",
	}}}
}
