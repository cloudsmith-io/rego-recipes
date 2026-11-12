package cloudsmith_test

_maven(group, artifact, version) := {"v0": {"package": {
	"format": "maven",
	"name": artifact,
	"version": version,
	"summary": sprintf("%s:%s:%s", [group, artifact, version]),
}}}

_sbom(purls) := {"v0": {
	"package": {"format": "docker", "version": "1.0.0"},
	"sbom": {"components": [{"purl": purl} | some purl in purls]},
}}

_osv(records) := {"v0": {
	"package": {"format": "maven", "version": "1.0.0"},
	"osv": records,
}}

_mentions(reasons, id) if {
	some msg in reasons
	contains(msg, id)
}

# Advisory data

test_every_advisory_reported_for_its_listed_versions if {
	count(data.cloudsmith.advisories) == 12
	every adv in data.cloudsmith.advisories {
		every version in adv.versions {
			package_reasons := data.cloudsmith.reason with input as _maven(adv.group, adv.artifact, version)
			_mentions(package_reasons, adv.id)
			purl := sprintf("pkg:maven/%s/%s@%s", [adv.group, adv.artifact, version])
			sbom_reasons := data.cloudsmith.reason with input as _sbom([purl])
			_mentions(sbom_reasons, adv.id)
		}
	}
}

# Package itself

test_match_maven_package if {
	data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1")
}

test_reason_maven_package if {
	msg := concat("", [
		"CGP-753c-3hg7-j33f (CVSS 6.2, CWE-400): io.jsonwebtoken:jjwt 0.9.1 decompresses attacker-controlled ",
		"JWT payloads before signature verification, enabling zip-bom io.jsonwebtoken:jjwt 0.9.1 is affected.",
	])
	data.cloudsmith.reason == {msg} with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1")
}

test_match_open_ended_range if {
	data.cloudsmith.match with input as _maven("com.sun.xml.messaging.saaj", "saaj-impl", "3.0.10")
}

test_no_match_chainguard_build if {
	not data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1-0.cgp.1")
	not data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1-0.cgb.1")
}

test_no_match_safe_version if {
	not data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.12.6")
}

test_no_match_unlisted_version_below_open_range if {
	not data.cloudsmith.match with input as _maven("com.sun.xml.messaging.saaj", "saaj-impl", "1.3.11")
}

test_no_match_other_format if {
	not data.cloudsmith.match with input as {"v0": {"package": {
		"format": "npm",
		"version": "0.9.1",
		"summary": "io.jsonwebtoken:jjwt:0.9.1",
	}}}
}

test_no_match_missing_summary if {
	not data.cloudsmith.match with input as {"v0": {"package": {"format": "maven", "name": "jjwt", "version": "0.9.1"}}}
}

# SBOM components

test_match_sbom_component_with_qualifiers if {
	data.cloudsmith.match with input as _sbom(["pkg:maven/io.jsonwebtoken/jjwt@0.9.1?type=jar"])
}

test_reasons_for_each_advisory_on_one_library if {
	count(data.cloudsmith.reason) == 2 with input as _sbom(["pkg:maven/org.javassist/javassist@3.29.2-GA"])
}

test_no_match_sbom_chainguard_build if {
	not data.cloudsmith.match with input as _sbom(["pkg:maven/org.javassist/javassist@3.29.2-GA-0.cgp.1"])
}

test_no_match_sbom_non_maven if {
	not data.cloudsmith.match with input as _sbom(["pkg:deb/debian/openssl@3.0.11", "pkg:npm/jjwt@0.9.1"])
}

test_no_match_sbom_component_without_purl if {
	not data.cloudsmith.match with input as {"v0": {
		"package": {"format": "docker", "version": "1.0.0"},
		"sbom": {"components": [{"group": "io.jsonwebtoken", "name": "jjwt", "version": "0.9.1"}]},
	}}
}

test_no_match_null_sbom if {
	not data.cloudsmith.match with input as {"v0": {"package": {"format": "docker", "version": "1.0.0"}, "sbom": null}}
}

# OSV records

test_match_osv_id if {
	data.cloudsmith.match with input as _osv([{"id": "CGP-753c-3hg7-j33f"}])
}

test_match_osv_alias if {
	data.cloudsmith.match with input as _osv([{"id": "GHSA-xxxx", "aliases": ["CGP-753c-3hg7-j33f"]}])
}

test_match_osv_upstream if {
	data.cloudsmith.match with input as _osv([{"id": "GHSA-xxxx", "aliases": null, "upstream": ["CGP-753c-3hg7-j33f"]}])
}

test_no_match_osv_related_only if {
	not data.cloudsmith.match with input as _osv([{"id": "GHSA-xxxx", "related": ["CGP-753c-3hg7-j33f"]}])
}

test_no_match_empty_input if {
	not data.cloudsmith.match with input as {"v0": {}}
}

# Settings

test_no_match_disabled_id if {
	not data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1")
		with data.cloudsmith.disabled_ids as {"CGP-753c-3hg7-j33f"}
}

test_no_match_deny_list_off if {
	not data.cloudsmith.match with input as _maven("io.jsonwebtoken", "jjwt", "0.9.1")
		with data.cloudsmith.use_deny_list as false
}

test_match_osv_with_deny_list_off if {
	data.cloudsmith.match with input as _osv([{"id": "CGP-753c-3hg7-j33f"}])
		with data.cloudsmith.use_deny_list as false
}

test_no_match_sbom_check_off if {
	not data.cloudsmith.match with input as _sbom(["pkg:maven/io.jsonwebtoken/jjwt@0.9.1"])
		with data.cloudsmith.check_sbom as false
}

test_match_extra_osv_id if {
	data.cloudsmith.match with input as _osv([{"id": "CVE-2026-0001"}])
		with data.cloudsmith.extra_osv_ids as {"CVE-2026-0001"}
}
