package cloudsmith
default match := false

match if count(malicious_packages) > 0

malicious_packages := [vulnerability.id |
	some vulnerability in input.v0.osv
	startswith(vulnerability.id, "MAL-")
]