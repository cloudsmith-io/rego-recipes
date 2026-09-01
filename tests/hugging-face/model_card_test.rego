package cloudsmith_test

_input(datasets) := {"v0": {"package": {
	"format": "huggingface",
	"card": {"datasets": datasets},
}}}

test_match_blocked_dataset if {
	data.cloudsmith.match with input as _input(["HuggingFaceTB/smollm-corpus"])
}

test_match_blocked_among_multiple if {
	data.cloudsmith.match with input as _input(["other/dataset", "HuggingFaceTB/smollm-corpus"])
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"card": {"datasets": ["HuggingFaceTB/smollm-corpus"]},
	}}}
}

test_no_match_different_dataset if {
	not data.cloudsmith.match with input as _input(["some/other-dataset"])
}

test_no_match_empty_datasets if {
	not data.cloudsmith.match with input as _input([])
}

test_no_match_missing_datasets if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"card": {},
	}}}
}

test_no_match_missing_card if {
	not data.cloudsmith.match with input as {"v0": {"package": {"format": "huggingface"}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input(["HuggingFaceTB/smollm-corpus"])
	count(r) == 1
	r["Model is trained on blocked datasets: {\"HuggingFaceTB/smollm-corpus\"}"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input(["some/other-dataset"])
	count(r) == 0
}
