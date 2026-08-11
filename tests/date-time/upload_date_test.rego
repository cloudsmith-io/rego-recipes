package cloudsmith_test

_input(uploaded_at) := {"v0": {"package": {"uploaded_at": uploaded_at}}}

test_match_inside_freeze if {
	data.cloudsmith.match with input as _input("2026-12-25T12:00:00Z")
}

test_match_on_freeze_start if {
	data.cloudsmith.match with input as _input("2026-12-20T00:00:00Z")
}

test_no_match_on_freeze_end if {
	not data.cloudsmith.match with input as _input("2027-01-05T00:00:00Z")
}

test_no_match_before_freeze if {
	not data.cloudsmith.match with input as _input("2026-12-19T23:59:59Z")
}

test_no_match_after_freeze if {
	not data.cloudsmith.match with input as _input("2027-02-01T00:00:00Z")
}

test_no_match_missing_uploaded_at if {
	not data.cloudsmith.match with input as {"v0": {"package": {}}}
}

test_no_match_unparseable_uploaded_at if {
	not data.cloudsmith.match with input as _input("not-a-date")
}

test_reason_message if {
	r := data.cloudsmith.reason with input as _input("2026-12-25T12:00:00Z")
	count(r) == 1
	r["Uploaded during the change freeze from 2026-12-20T00:00:00Z to 2027-01-05T00:00:00Z"]
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input("2027-02-01T00:00:00Z")
	count(r) == 0
}
