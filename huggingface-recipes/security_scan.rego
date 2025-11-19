package cloudsmith

import rego.v1

default match := false

is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-o6v"

# Ensure the security scans have been completed and none of the scans
# find any problematic content.
# Users an incremental rule to express OR.
incomplete_or_unsafe {
    input.v0.model_security.availability != "COMPLETE"
}

incomplete_or_unsafe {
    input.v0.model_security.scan_summary != "SAFE"
}

match if {
    "huggingface" == input.v0.package.format
    is_upstream_pkg
    incomplete_or_unsafe
}
