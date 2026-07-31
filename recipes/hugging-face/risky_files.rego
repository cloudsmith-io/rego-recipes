package cloudsmith

default match := false

pkg := input.v0.package

hf_pkg if pkg.format == "huggingface"

# Upstream packages are fetched by a system user
is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-o6v"

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

match if {
	hf_pkg
	is_upstream_pkg
	some file in pkg.files
	file.file_extension in risky_file_extensions
}
