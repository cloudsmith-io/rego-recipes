# METADATA
# title: Allowed architectures
# description: Match packages built for a disallowed architecture.
package cloudsmith

default match := false

pkg := input.v0.package

allowed_architectures := {"amd64"}

disallowed_architectures contains arch.name if {
	some arch in pkg.architectures
	not arch.name in allowed_architectures
}

match if count(disallowed_architectures) > 0

reason contains msg if {
	match
	msg := sprintf("Architecture disallowed: %v. Allowed: %v", [disallowed_architectures, allowed_architectures])
}
