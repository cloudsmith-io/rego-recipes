package cloudsmith

default match := false

# Upstream packages are fetched by a system user
is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-o6v"

# Ensure the security scans have been completed and none of the scans
# find any problematic content.
# Users an incremental rule to express OR.
incomplete_or_unsafe if {
	input.v0.model_security.availability != "COMPLETE"
}

incomplete_or_unsafe if {
	input.v0.model_security.scan_summary != "SAFE"
}

match if {
	input.v0.package.format == "huggingface"
	is_upstream_pkg
	incomplete_or_unsafe
}
