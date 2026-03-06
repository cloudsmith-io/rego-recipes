# METADATA
# title: Exact blocklist
# description: Block packages that are explicitly denylisted by format, name, and version
package cloudsmith

default match := false

pkg := input.v0.package

blocklist := {
	"python:malicious-lib:0.1.0",
	"npm:compromised-ui:9.9.9",
}

pkg_key := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if {
	pkg.format != null
	pkg.name != null
	pkg.version != null
	pkg_key in blocklist
}

reason[msg] if {
	match
	msg := sprintf(
		"Blocked by explicit deny list: %s",
		[pkg_key],
	)
}
