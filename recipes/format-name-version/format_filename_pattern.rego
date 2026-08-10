# METADATA
# title: Format filename pattern
# description: Match packages whose filename does not follow the required naming convention.
package cloudsmith

default match := false

pkg := input.v0.package

format := "python"

filename_pattern := `^[a-z0-9_\-]+-\d+\.\d+\.\d+\.(tar\.gz|whl)$`

match if {
	pkg.format == format
	not regex.match(filename_pattern, pkg.filename)
}

reason contains sprintf("Filename does not follow the required convention: %s", [pkg.filename]) if match
