# METADATA
# title: Model security scan
# description: Match upstream Hugging Face models whose security scan is missing, incomplete or unsafe.
package cloudsmith

default match := false

pkg := input.v0.package

# Upstream packages are fetched from upstream
is_upstream_pkg if {
	some tag in pkg.tags
	tag.name == "upstream"
	tag.source == "AUTOMATIC"
}

scan_clean if {
	input.v0.model_security.availability == "COMPLETE"
	input.v0.model_security.scan_summary == "SAFE"
}

match if {
	pkg.format == "huggingface"
	is_upstream_pkg
	not scan_clean
}

reason contains "Model security scan is missing, incomplete or unsafe" if match
