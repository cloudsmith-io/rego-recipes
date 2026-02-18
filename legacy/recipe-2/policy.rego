package cloudsmith
import rego.v1
default match := false

required_tag := "deprecated"

match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  some tag in pkg.tags
  tag.name == required_tag
  msg := sprintf("Package has required tag: '%s'", [required_tag])
}
