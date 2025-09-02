package cloudsmith

import rego.v1

default match := false

pkg := input.v0.package

hf_pkg if "huggingface" == pkg.format

is_upstream_pkg if pkg.uploader.slug_perm == "Cloudsmith"

risky_file_extensions := {".bin", ".h5", ".keras", ".pkl", "pt", ".zip",}

match if {
    hf_pkg
    is_upstream_pkg
    some file in pkg.files
    file.file_extension in risky_file_extensions 
} 