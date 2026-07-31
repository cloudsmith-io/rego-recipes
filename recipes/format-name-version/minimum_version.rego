# METADATA
# title: Minimum version
# description: Flag packages older than the minimum permitted version, or whose version cannot be compared.
package cloudsmith

default match := false

pkg := input.v0.package

minimum_versions := {
	"python:h11": "0.16.0",
	"npm:example-ui": "4.5.0",
}

format_name := sprintf("%s:%s", [pkg.format, pkg.name])

minimum_version := minimum_versions[format_name]

below_minimum if {
	semver.is_valid(pkg.version)
	semver.compare(pkg.version, minimum_version) < 0
}

unparseable_version if {
	minimum_version
	not semver.is_valid(pkg.version)
}

match if below_minimum
match if unparseable_version

reason contains sprintf("Version %s is older than the minimum permitted %s", [pkg.version, minimum_version]) if below_minimum
reason contains sprintf("Version %s is not valid SemVer and cannot be checked against the minimum permitted %s", [pkg.version, minimum_version]) if unparseable_version
