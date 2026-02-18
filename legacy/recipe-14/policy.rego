package cloudsmith
default match := false
# --- Config ---
target_name := "requests"
target_versions := {"2.6.0"}
# --- Match when the package is the target and version is exactly banned ---
match if {
  pkg := input.v0.package
  pkg.name == target_name
  version_matches(pkg)
}
# Accept either .version or .version_orig (two simple rules = logical OR)
version_matches(pkg) if {
  v := pkg.version
  v in target_versions
}
version_matches(pkg) if {
  pkg.version_orig
  v := pkg.version_orig
  v in target_versions
}
