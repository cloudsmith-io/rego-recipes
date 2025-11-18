package cloudsmith

import rego.v1

default match := false

pkg := input.v0.package

hf_pkg if "huggingface" == pkg.format

is_upstream_pkg if input.v0.package.uploader.slug == "cloudsmith-KY3"

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

risky_file_extensions := {".h5", ".hdf5", ".pdparams", ".keras", ".bin", ".pkl", ".dat", "pt", ".pth", ".ckpt", ".npy", ".joblib", ".dill", ".pb", ".gguf", ".zip",}

match if {
    hf_pkg
    is_upstream_pkg
    some file in pkg.files
    file.file_extension in risky_file_extensions 
} 