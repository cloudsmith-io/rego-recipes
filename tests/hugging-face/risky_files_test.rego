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

test_no_match_missing_uploader if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
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

test_no_match_missing_files if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "huggingface",
		"uploader": {"slug": "cloudsmith-o6v"},
	}}}
}

test_no_match_file_without_extension if {
	not data.cloudsmith.match with input as _upstream_hf_pkg([{"filename": "README.md"}])
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _upstream_hf_pkg([{"file_extension": ".bin"}])
	count(r) == 1
	r["Model contains risky file formats: {\".bin\"}"]
}

test_reason_lists_extensions_once if {
	r := data.cloudsmith.reason with input as _upstream_hf_pkg([
		{"file_extension": ".bin"},
		{"file_extension": ".bin"},
		{"file_extension": ".pkl"},
	])
	count(r) == 1
	r["Model contains risky file formats: {\".bin\", \".pkl\"}"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _upstream_hf_pkg([{"file_extension": ".txt"}])
	count(r) == 0
}
