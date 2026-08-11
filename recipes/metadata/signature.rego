# METADATA
# title: Unsigned packages
# description: Match packages that are not signed.
package cloudsmith

default match := false

pkg := input.v0.package

match if not pkg.signed

reason contains "Package is not signed" if match
