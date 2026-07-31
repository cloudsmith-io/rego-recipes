# METADATA
# title: Blocklist
# description: Match packages that are blocklisted by format and name, or by format, name, and version.
package cloudsmith

default match := false

pkg := input.v0.package

blocklist := {
	"npm:compromised-ui",
	"python:malicious-lib:0.1.0",
}

format_name := sprintf("%s:%s", [pkg.format, pkg.name])
format_name_version := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

matched contains format_name if format_name in blocklist
matched contains format_name_version if format_name_version in blocklist

match if count(matched) > 0

reason contains sprintf("Matched by blocklist: %v", [matched]) if match
