package cloudsmith

default match := false

# high or critical CVSS threshold
max_cvss_score := 7

# targeted repository
target_repository := "acme-repo1"

# CVEs to ignore
ignored_cves := {"CVE-2023-45853"}

# Main match condition
match if {
	input.v0.repository.name == target_repository
	some vulnerability in input.v0.security_scan.Vulnerabilities
	vulnerability.FixedVersion
	vulnerability.Status == "fixed"
	not ignored_cve(vulnerability)
	exceeded_max_cvss(vulnerability)
}

# Rule to check CVSS score exceeding threshold
exceeded_max_cvss(vulnerability) if {
	some key, val in vulnerability.CVSS
	val.V3Score > max_cvss_score
}

# Rule to check if CVE is ignored
ignored_cve(vulnerability) if {
	vulnerability.VulnerabilityID in ignored_cves
}
