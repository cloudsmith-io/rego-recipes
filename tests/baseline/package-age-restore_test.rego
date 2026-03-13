package cloudsmith_test

_input(published_at) := {"v0": {"package": {"upstream_metadata": {"published_at": published_at}}}}

# "2020-01-01" is well in the past, so always older than 3 days
test_match_old_package if {
	data.cloudsmith.match with input as _input("2020-01-01T00:00:00Z")
}

# "2099-01-01" is always in the future, so always within the past 3 days relative to now
test_no_match_recently_published if {
	not data.cloudsmith.match with input as _input("2099-01-01T00:00:00Z")
}

test_no_match_null_upstream_metadata if {
	not data.cloudsmith.match with input as {"v0": {"package": {"upstream_metadata": null}}}
}

test_no_match_null_published_at if {
	not data.cloudsmith.match with input as {"v0": {"package": {"upstream_metadata": {"published_at": null}}}}
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input("2020-01-01T00:00:00Z")
	count(r) > 0
}
