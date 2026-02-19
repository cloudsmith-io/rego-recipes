package cloudsmith

default match := false

pkg := input.v0.package

within_past_days := 4
required_tag := "cooldown"

match if restored

restored if {
	pkg.upstream_metadata != null
	pkg.upstream_metadata.published_at != null

	some t in pkg.tags
	t.name == required_tag

	publish_date := time.parse_rfc3339_ns(pkg.upstream_metadata.published_at)

	days_ago := 0 - within_past_days
	cutoff := time.add_date(time.now_ns(), 0, 0, days_ago)

	publish_date < cutoff
}

reason[msg] if {
	restored
	msg := sprintf(
		"Package older than %v days and tagged '%s' — restoring availability",
		[within_past_days, required_tag],
	)
}
