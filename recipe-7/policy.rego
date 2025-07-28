package cloudsmith

import rego.v1

default match := false

approved := "approved"
upstream := "upstream"
#allowed_repos := {"test-repo"}  # Define your set of allowed repositories

match if {
    not has_approved_tag
    has_upstream_tag
#    is_in_allowed_repo
}

has_upstream_tag if {
    some _, type in input.v0["package"].tags
    some tag in type
    tag = upstream
}

has_approved_tag if {
    some _, type in input.v0["package"].tags
    some tag in type
    tag = approved
}

#is_in_allowed_repo if {
#    input.v0["repository"].slug in allowed_repos
#}package cloudsmith

import rego.v1

default match := false

approved := "approved"
upstream := "upstream"
#allowed_repos := {"test-repo"}  # Define your set of allowed repositories

match if {
    not has_approved_tag
    has_upstream_tag
#    is_in_allowed_repo
}

has_upstream_tag if {
    some _, type in input.v0["package"].tags
    some tag in type
    tag = upstream
}

has_approved_tag if {
    some _, type in input.v0["package"].tags
    some tag in type
    tag = approved
}

#is_in_allowed_repo if {
#    input.v0["repository"].slug in allowed_repos
#}
