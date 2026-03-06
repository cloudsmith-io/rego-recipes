# METADATA
# title: Package age quarantine
# description: Quarantine packages published within the last N days (default: 3 days)
package cloudsmith

default match := false

pkg := input.v0.package

within_past_days := 3

match if below_minimum_release_age

below_minimum_release_age if {
	pkg.upstream_metadata != null
	pkg.upstream_metadata.published_at != null

	publish_date := time.parse_rfc3339_ns(pkg.upstream_metadata.published_at)

	days_ago := 0 - within_past_days
	cutoff := time.add_date(time.now_ns(), 0, 0, days_ago)

	publish_date >= cutoff
}

reason[msg] if {
	below_minimum_release_age
	msg := sprintf(
		"Package published within last %v days — below minimum release age",
		[within_past_days],
	)
}
