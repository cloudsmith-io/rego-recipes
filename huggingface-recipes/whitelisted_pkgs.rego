package cloudsmith

import rego.v1

default match := false

white_listed_pkgs := {"jinaai/jina-embeddings-v3", "Qwen/Qwen3-0.6B"}

match if {
    "huggingface" == input.v0.package.format
    input.v0.package.name in white_listed_pkgs
}
