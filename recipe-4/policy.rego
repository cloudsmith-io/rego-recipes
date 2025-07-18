package cloudsmith
import rego.v1
default match := false

match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  re_match(".*(debug|test|tmp).*", pkg.filename)
  msg := sprintf("Debug/test artifact detected in filename: %s", [pkg.filename])
}
