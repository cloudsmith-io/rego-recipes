package cloudsmith

default match := false

# A package is matched if its upstream publish date is within the past N days.
within_past_days := 14
supported_formats := {"npm"}

match if count(reason) != 0

reason contains msg if {
    pkg := input.v0["package"]
    within_past_days_date := time.add_date(time.now_ns(), 0, 0, 0 - within_past_days)
    publish_date := time.parse_rfc3339_ns(pkg.upstream_metadata.published_at)

    # Match if the publish date comes after the date of the set number of days ago.
    publish_date >= within_past_days_date
    pkg.format in supported_formats

    msg := sprintf("Package upstream publish date is %v (falls within the past %v days)", [pkg.upstream_metadata.published_at, within_past_days])
}