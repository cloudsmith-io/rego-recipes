package cloudsmith
import rego.v1

default match := false

match if count(reason) > 0

# Policy blocks packages uploaded between 09:00 and 11:00 *GMT (UTC)*

reason contains msg if {
  pkg := input.v0["package"]
  pkg.uploaded_at

  ts := time.parse_rfc3339_ns(pkg.uploaded_at) / 1000000000
  clock := time.clock(ts)
  hour := clock[0]

  hour >= 9
  hour < 11

  msg := sprintf("Package uploaded between 09:00 and 11:00 UTC: %02d:00", [hour])
}
