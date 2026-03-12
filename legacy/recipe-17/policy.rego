package cloudsmith
import rego.v1
default match := false

exempt_tag := "exempt"

match if {
  pkg := input.v0["package"]
  some t in pkg.tags
  t.name == exempt_tag
}
