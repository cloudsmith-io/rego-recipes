package cloudsmith
import rego.v1
default match := false

match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  not pkg.signed
  msg := "The package must be signed to be published to this repository."
}
