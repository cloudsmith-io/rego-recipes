package cloudsmith

import rego.v1

default match := false

is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-KY3"

match if {
    "huggingface" == input.v0.package.format
    is_upstream_pkg
    # Ensure the security scans have been completed and none of the scans
    # find any problematic content.
    input.v0.model_security.availability != "COMPLETE"
    input.v0.model_security.scan_summary != "SAFE"
}
