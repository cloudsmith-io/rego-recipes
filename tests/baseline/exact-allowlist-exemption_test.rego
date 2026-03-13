package cloudsmith_test

test_match_allowlisted_python_package if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "example-lib",
		"version": "1.2.3",
	}}}
}

test_match_allowlisted_npm_package if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "npm",
		"name": "example-ui",
		"version": "4.5.6",
	}}}
}

test_no_match_wrong_version if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "example-lib",
		"version": "9.9.9",
	}}}
}

test_no_match_wrong_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "ruby",
		"name": "example-lib",
		"version": "1.2.3",
	}}}
}

test_reason_message if {
	data.cloudsmith.reason["Explicit exemption approved: python:example-lib:1.2.3"] with input as {"v0": {"package": {
		"format": "python",
		"name": "example-lib",
		"version": "1.2.3",
	}}}
}
