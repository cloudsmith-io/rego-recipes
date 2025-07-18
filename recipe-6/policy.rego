package cloudsmith
default match := false  # Assume the package is fine unless we find a problem
match if count(reason) > 0  # Match the policy only if we generate at least one reason

reason contains msg if {
  pkg := input.v0["package"]

  # Focus only on files that start with 'h11-'
  startswith(pkg.filename, "h11-")

  # Ensure they match semantic versioning pattern
  not regex.match("^h11-[0-9]+\\.[0-9]+\\.[0-9]+\\.(tar\\.gz|whl)$", pkg.filename)

  # Give a descriptive reason if not
  msg := sprintf("Filename '%s' does not match required SemVer pattern", [pkg.filename])
}
