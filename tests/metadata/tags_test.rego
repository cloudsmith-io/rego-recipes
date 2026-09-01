package cloudsmith_test

_input(tags) := {"v0": {"package": {"tags": tags}}}

_tags(n) := [tag |
	some i in numbers.range(1, n)
	tag := {"name": sprintf("tag-%d", [i])}
]

test_match_deprecated_tag if {
	data.cloudsmith.match with input as _input([{"name": "deprecated"}])
}

test_match_deprecated_alongside_other_tags if {
	data.cloudsmith.match with input as _input([{"name": "stable"}, {"name": "deprecated"}])
}

test_no_match_untagged_package if {
	not data.cloudsmith.match with input as _input([{"name": "stable"}])
}

test_no_match_at_tag_limit if {
	not data.cloudsmith.match with input as _input(_tags(5))
}

test_match_over_tag_limit if {
	data.cloudsmith.match with input as _input(_tags(6))
}

test_no_match_empty_tags if {
	not data.cloudsmith.match with input as _input([])
}

test_no_match_missing_tags if {
	not data.cloudsmith.match with input as {"v0": {"package": {}}}
}

test_no_match_tag_entry_without_name if {
	not data.cloudsmith.match with input as _input([{"id": 1}])
}

test_reason_message_deprecated if {
	r := data.cloudsmith.reason with input as _input([{"name": "deprecated"}])
	count(r) == 1
	r["Package is tagged 'deprecated'"]
}

test_reason_message_too_many_tags if {
	r := data.cloudsmith.reason with input as _input(_tags(6))
	count(r) == 1
	r["Package has 6 tags, exceeding the limit of 5"]
}

test_reason_messages_both_conditions if {
	tags := array.concat(_tags(6), [{"name": "deprecated"}])
	r := data.cloudsmith.reason with input as _input(tags)
	count(r) == 2
}

test_no_reason_when_no_match if {
	r := data.cloudsmith.reason with input as _input([{"name": "stable"}])
	count(r) == 0
}
