# METADATA
# title: Tag policy
# description: Match packages tagged as deprecated, or carrying more tags than permitted.
package cloudsmith

default match := false

pkg := input.v0.package

tag_name := "deprecated"
max_tags := 5

tag_count := count(pkg.tags)

has_tag if {
	some tag in pkg.tags
	tag.name == tag_name
}

exceeds_tags if tag_count > max_tags

match if has_tag
match if exceeds_tags

reason contains sprintf("Package is tagged '%s'", [tag_name]) if has_tag
reason contains sprintf("Package has %d tags, exceeding the limit of %d", [tag_count, max_tags]) if exceeds_tags
