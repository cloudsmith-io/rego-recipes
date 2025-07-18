package cloudsmith
import rego.v1
default match := false

max_tags := 5

match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  count(pkg.tags) > max_tags
  msg := sprintf("Package has too many tags (%d)", [count(pkg.tags)])
}
