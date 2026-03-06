# METADATA
# title: Exact Allowlist Exemption
# description: Approve packages that are explicitly allowlisted by format, name, and version
package cloudsmith

default match := false

pkg := input.v0.package

allowlist := {
	"python:example-lib:1.2.3",
	"npm:example-ui:4.5.6",
}

pkg_key := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if {
	pkg.format != null
	pkg.name != null
	pkg.version != null
	pkg_key in allowlist
}

reason[msg] if {
	match
	msg := sprintf(
		"Explicit exemption approved: %s",
		[pkg_key],
	)
}
