package cloudsmith

default match := false

#
# Explicit blocklist
# Format: "<format>:<name>:<version>"
#

blocklist := {
	"python:malicious-lib:0.1.0",
	"npm:compromised-ui:9.9.9",
}

pkg := input.v0.package

pkg_key := sprintf("%s:%s:%s", [pkg.format, pkg.name, pkg.version])

match if {
	pkg_key in blocklist
}

reason[msg] if {
	match
	msg := sprintf(
		"Blocked by explicit deny list: %s",
		[pkg_key],
	)
}
