package cloudsmith
import rego.v1

default match := false

# Block window (UTC)
start_hour := 9   # inclusive
end_hour   := 11  # exclusive

match if count(reason) > 0

reason[msg] if {
  pkg := input.v0["package"]
  ts_ns := time.parse_rfc3339_ns(pkg.uploaded_at)  # ns since epoch

  day_ns := ts_ns % 86400000000000      # ns into UTC day (24*60*60*1e9)
  hour   := floor(day_ns / 3600000000000)   # ns per hour (3.6e12)

  hour >= start_hour
  hour < end_hour

  msg := sprintf(
    "Package uploaded between %02d:00 and %02d:00 UTC (upload hour %02d:00).",
    [start_hour, end_hour, hour],
  )
}
