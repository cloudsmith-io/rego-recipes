package cloudsmith
default match := false
match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  startswith(pkg.version, "0.")
  msg := sprintf("Package version '%s' is considered pre-1.0 and disallowed", [pkg.version])
}
