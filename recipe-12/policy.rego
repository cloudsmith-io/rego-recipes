package cloudsmith

default match := false

match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  pkg.name == "h11"

  # Parse versions using Cloudsmith's semantic version comparator
  semver.compare(pkg.version, "0.16.0") == -1

  msg := sprintf("Package 'h11' version '%s' is older than 0.16.0", [pkg.version])
}
