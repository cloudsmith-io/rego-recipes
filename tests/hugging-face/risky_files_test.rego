package cloudsmith_test

_upstream_hf_pkg(files) := {"v0": {"package": {
	"format": "huggingface",
	"uploader": {"slug": "cloudsmith-o6v"},
	"files": files,
}}}

test_match_bin_file if {
	data.cloudsmith.match with input as _upstream_hf_pkg([{"file_extension": ".bin"}])
}

test_match_pkl_file if {
	data.cloudsmith.match with input as _upstream_hf_pkg([{"file_extension": ".pkl"}])
}

test_match_gguf_file if {
	data.cloudsmith.match with input as _upstream_hf_pkg([{"file_extension": ".gguf"}])
}

test_match_risky_among_safe_files if {
	data.cloudsmith.match with input as _upstream_hf_pkg([
		{"file_extension": ".txt"},
		{"file_extension": ".bin"},
	])
}

test_no_match_safe_file_extension if {
	not data.cloudsmith.match with input as _upstream_hf_pkg([{"file_extension": ".txt"}])
}

test_no_match_not_upstream if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"uploader": {"slug": "other-user"},
		"files": [{"file_extension": ".bin"}],
	}}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"uploader": {"slug": "cloudsmith-o6v"},
		"files": [{"file_extension": ".bin"}],
	}}}
}

test_no_match_empty_files if {
	not data.cloudsmith.match with input as _upstream_hf_pkg([])
}
