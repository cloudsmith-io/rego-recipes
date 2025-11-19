package cloudsmith

import rego.v1

default match := false

is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-o6v"

verified_publishers := {"amazon", "apple", "facebook", "FacebookAI", "google", "Intel", "microsoft", "openai"}

publisher := split(input.v0.package.name, "/")[0]

match if {
    "huggingface" == input.v0.package.format
    is_upstream_pkg
    publisher in verified_publishers
}
