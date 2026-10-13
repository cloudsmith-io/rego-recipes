# METADATA
# title: Change freeze
# description: Match packages uploaded during a change freeze period.
package cloudsmith

default match := false

pkg := input.v0.package

freeze_start := "2026-12-20T00:00:00Z"
freeze_end := "2027-01-05T00:00:00Z"

uploaded_at := time.parse_rfc3339_ns(pkg.uploaded_at)

match if {
	uploaded_at >= time.parse_rfc3339_ns(freeze_start)
	uploaded_at < time.parse_rfc3339_ns(freeze_end)
}

reason contains $"Uploaded during the change freeze from {freeze_start} to {freeze_end}" if match
