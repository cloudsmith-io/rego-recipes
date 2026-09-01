# METADATA
# title: Risky model file formats
# description: Match upstream Hugging Face models carrying file formats that can execute code on load.
package cloudsmith

default match := false

pkg := input.v0.package

# Upstream packages are fetched by a system user.
is_upstream_pkg if pkg.uploader.slug == "cloudsmith-o6v"

# Formats and their extensions
# H5 (.h5, .hdf5)
# Paddle (.pdparams)
# PyTorch (.bin, .pt, .pth, .ckpt)
# Pickle (.pkl, .dat)
# Numpy (.npy)
# JobLib (.joblib)
# Dill (.dill)
# SavedModel (.pb)
# GGUF (.gguf)
risky_file_extensions := {
	".bin", ".ckpt", ".dat", ".dill",
	".gguf", ".h5", ".hdf5", ".joblib",
	".keras", ".npy", ".pb", ".pdparams",
	".pkl", ".pt", ".pth", ".zip",
}

risky_found contains file.file_extension if {
	pkg.format == "huggingface"
	is_upstream_pkg
	some file in pkg.files
	file.file_extension in risky_file_extensions
}

match if count(risky_found) > 0

reason contains sprintf("Model contains risky file formats: %v", [risky_found]) if match
