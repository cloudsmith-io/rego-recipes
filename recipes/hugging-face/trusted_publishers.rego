# METADATA
# title: Verified publishers
# description: Match upstream Hugging Face models published by a verified organisation.
package cloudsmith

default match := false

pkg := input.v0.package

# Upstream packages are fetched by a system user.
is_upstream_pkg if pkg.uploader.slug == "cloudsmith-o6v"

verified_publishers := {"amazon", "apple", "facebook", "FacebookAI", "google", "Intel", "microsoft", "openai"}

publisher := split(pkg.name, "/")[0]

match if {
	pkg.format == "huggingface"
	is_upstream_pkg
	publisher in verified_publishers
}

reason contains sprintf("Published by verified organisation %s", [publisher]) if match
