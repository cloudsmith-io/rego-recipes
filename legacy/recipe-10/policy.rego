package cloudsmith
default match := false

max_epss := 0.0001
target_repository := "acme-corporation"
ignored_cves := {"CVE-2023-45853"}
match if count(reason) > 0

reason contains msg if {
    input.v0["repository"]["name"] == target_repository
    some vuln in input.v0["vulnerabilities"]

    vuln["patched_versions"]
    vuln["severity"] == "HIGH"
    not ignored_cve(vuln)

    # EPSS score exceeds threshold
    vuln["epss_score"]
    vuln["epss_score"] > max_epss

    msg := sprintf(
        "High severity vulnerability %s has EPSS score %.6f (threshold %.6f)",
        [vuln["VulnerabilityID"], vuln["epss_score"], max_epss]
    )
}

ignored_cve(vuln) if {
    vuln["VulnerabilityID"] in ignored_cves
}
