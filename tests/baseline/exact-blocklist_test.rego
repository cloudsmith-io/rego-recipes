package cloudsmith_test

test_match_blocked_python_package if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "malicious-lib",
		"version": "0.1.0",
	}}}
}

test_match_blocked_npm_package if {
	data.cloudsmith.match with input as {"v0": {"package": {
		"format": "npm",
		"name": "compromised-ui",
		"version": "9.9.9",
	}}}
}

test_no_match_unlisted_package if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "safe-lib",
		"version": "1.0.0",
	}}}
}

test_no_match_wrong_version if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "python",
		"name": "malicious-lib",
		"version": "9.9.9",
	}}}
}

test_reason_message if {
	data.cloudsmith.reason["Blocked by explicit deny list: python:malicious-lib:0.1.0"] with input as {"v0": {"package": {
		"format": "python",
		"name": "malicious-lib",
		"version": "0.1.0",
	}}}
}
