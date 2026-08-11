# METADATA
# title: Model training datasets
# description: Match Hugging Face models whose card lists a blocked training dataset.
package cloudsmith

default match := false

pkg := input.v0.package

blocked_datasets := {"HuggingFaceTB/smollm-corpus"}

blocked_found contains dataset if {
	pkg.format == "huggingface"
	some dataset in pkg.card.datasets
	dataset in blocked_datasets
}

match if count(blocked_found) > 0

reason contains sprintf("Model is trained on blocked datasets: %v", [blocked_found]) if match
