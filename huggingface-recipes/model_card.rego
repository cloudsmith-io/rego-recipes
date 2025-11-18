package cloudsmith

import rego.v1

default match := false

pkg := input.v0.package

hf_pkg if "huggingface" == pkg.format

match if {
    hf_pkg
    "HuggingFaceTB/smollm-corpus" in pkg.card.datasets
} 
