# METADATA
# title: Cooldown period
# description: Hide newly published versions of packages from your repository index until they reach a minimum age
package cloudsmith

import rego.v1

default match := false

# Cooldown window in days. Packages whose upstream publish date is more recent than this are filtered out.
within_past_days := 3

# A cooldown policy is currently restricted to npm, Python, Go, NuGet, and Maven.
supported_formats := {"npm", "python", "go", "nuget", "maven"}

# Repo allow-list, by repo slug, scoped to this policy's org.
# Empty set = policy applies to every repo in the org.
# If a repo slug is in both 'included_repositories' and 'excluded_repositories', the repo is excluded.
included_repositories := {}

# Repo deny-list, by repo slug, scoped to this policy's org.
# Repos listed here always bypass the policy, regardless of `included_repositories`.
excluded_repositories := {}

# When false, only upstream/proxied packages are evaluated and locally uploaded packages are always allowed. Set true to apply the cooldown to local uploads as well.
include_local_packages := true

match if count(reason) != 0

# Whether to evaluate this package at all. Skips local packages unless `include_local_packages` is enabled.
_should_evaluate if {
    not input.v0.package.is_local
}

_should_evaluate if {
    include_local_packages == true
}

_repo_allowed if {
    count(included_repositories) == 0
    not input.v0.repository.slug in excluded_repositories
}

_repo_allowed if {
    input.v0.repository.slug in included_repositories
    not input.v0.repository.slug in excluded_repositories
}

# Produce a reason when the package is in scope, and was published within the cooldown window.
reason contains msg if {
    _should_evaluate
    _repo_allowed
    pkg := input.v0.package
    within_past_days_date := time.add_date(time.now_ns(), 0, 0, 0 - within_past_days)
    publish_date := time.parse_rfc3339_ns(pkg.upstream_metadata.published_at)
    publish_date >= within_past_days_date
    pkg.format in supported_formats
    msg := sprintf(
        "Package %v/%v (%v) is within the %v-day cooldown period: published %v",
        [pkg.name, pkg.version, pkg.format, within_past_days, pkg.upstream_metadata.published_at],
    )
}
