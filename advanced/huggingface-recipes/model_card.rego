package cloudsmith

default match := false

pkg := input.v0.package

hf_pkg if pkg.format == "huggingface"

match if {
	hf_pkg
	"HuggingFaceTB/smollm-corpus" in pkg.card.datasets
}
