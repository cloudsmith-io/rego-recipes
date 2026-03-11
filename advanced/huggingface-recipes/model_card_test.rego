package cloudsmith_test

test_match_target_dataset if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"card": {"datasets": ["HuggingFaceTB/smollm-corpus"]},
	}}}
}

test_match_dataset_among_multiple if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"card": {"datasets": ["other/dataset", "HuggingFaceTB/smollm-corpus"]},
	}}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"card": {"datasets": ["HuggingFaceTB/smollm-corpus"]},
	}}}
}

test_no_match_different_dataset if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"card": {"datasets": ["some/other-dataset"]},
	}}}
}

test_no_match_empty_datasets if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"card": {"datasets": []},
	}}}
}
