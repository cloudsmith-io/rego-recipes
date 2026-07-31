# METADATA
# title: Debug artifacts in release repositories
# description: Match debug build artifacts published to a release repository.
package cloudsmith

default match := false

pkg := input.v0.package

debug_markers := {"debug", "test", "tmp"}

filename := lower(pkg.filename)

release_repository if endswith(input.v0.repository.name, "-releases")

match if {
	release_repository
	some marker in debug_markers
	contains(filename, marker)
}

reason contains sprintf("Debug artifact published to a release repository: %s", [filename]) if match
