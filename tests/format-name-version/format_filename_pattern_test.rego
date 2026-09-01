package cloudsmith_test

_input(format, filename) := {"v0": {"package": {"format": format, "filename": filename}}}

test_no_match_conforming_sdist if {
	not data.cloudsmith.match with input as _input("python", "example-lib-1.2.3.tar.gz")
}

test_no_match_conforming_wheel if {
	not data.cloudsmith.match with input as _input("python", "example_lib-1.2.3.whl")
}

test_match_uppercase_name if {
	data.cloudsmith.match with input as _input("python", "Example-Lib-1.2.3.tar.gz")
}

test_match_two_component_version if {
	data.cloudsmith.match with input as _input("python", "example-lib-1.2.tar.gz")
}

test_match_wrong_extension if {
	data.cloudsmith.match with input as _input("python", "example-lib-1.2.3.zip")
}

test_no_match_other_format if {
	not data.cloudsmith.match with input as _input("npm", "Not-A-Valid-Name.tgz")
}

test_no_match_missing_filename if {
	not data.cloudsmith.match with input as {"v0": {"package": {"format": "python"}}}
}

test_no_match_missing_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {"filename": "BAD.tar.gz"}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input("python", "Example-Lib-1.2.3.tar.gz")
	count(r) == 1
	r["Filename does not follow the required convention: Example-Lib-1.2.3.tar.gz"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("python", "example-lib-1.2.3.tar.gz")
	count(r) == 0
}
