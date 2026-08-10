# METADATA
# title: Permitted architectures
# description: Match packages built for an architecture that is not permitted.
package cloudsmith

default match := false

pkg := input.v0.package

permitted_architectures := {"amd64"}

disallowed_architectures contains arch.name if {
	some arch in pkg.architectures
	not arch.name in permitted_architectures
}

match if count(disallowed_architectures) > 0

reason contains sprintf("Architecture not permitted: %v. Permitted: %v", [disallowed_architectures, permitted_architectures]) if match
