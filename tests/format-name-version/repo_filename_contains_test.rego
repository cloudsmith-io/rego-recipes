package cloudsmith_test

_input(repo_name, filename) := {"v0": {
	"repository": {"name": repo_name, "slug": repo_name},
	"package": {"filename": filename},
}}

test_match_debug_marker if {
	data.cloudsmith.match with input as _input("prod-releases", "app-debug.tar.gz")
}

test_match_test_marker if {
	data.cloudsmith.match with input as _input("prod-releases", "app-test.tar.gz")
}

test_match_tmp_marker if {
	data.cloudsmith.match with input as _input("prod-releases", "app-tmp.tar.gz")
}

test_match_uppercase_marker if {
	data.cloudsmith.match with input as _input("prod-releases", "app-DEBUG.tar.gz")
}

test_no_match_clean_filename if {
	not data.cloudsmith.match with input as _input("prod-releases", "app-1.0.0.tar.gz")
}

test_no_match_non_release_repository if {
	not data.cloudsmith.match with input as _input("prod-staging", "app-debug.tar.gz")
}

test_no_match_missing_filename if {
	not data.cloudsmith.match with input as {"v0": {
		"repository": {"name": "prod-releases", "slug": "prod-releases"},
		"package": {},
	}}
}

test_no_match_missing_repository if {
	not data.cloudsmith.match with input as {"v0": {"package": {"filename": "app-debug.tar.gz"}}}
}

test_no_match_missing_repository_name if {
	not data.cloudsmith.match with input as {"v0": {
		"repository": {"slug": "prod-releases"},
		"package": {"filename": "app-debug.tar.gz"},
	}}
}

test_reason_names_the_repository if {
	r := data.cloudsmith.reason with input as _input("prod-releases", "app-debug.tar.gz")
	count(r) == 1
	r["Debug artifact published to release repository: app-debug.tar.gz in prod-releases"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("prod-releases", "app-1.0.0.tar.gz")
	count(r) == 0
}
