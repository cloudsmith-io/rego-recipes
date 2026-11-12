# METADATA
# title: Chainguard Athena – Wave 2 coordinated disclosure (12 Nov 2026)
# description: >
#   Flags Maven packages, and Docker/OCI images that bundle them, affected by the
#   12 Wave 2 vulnerabilities in Chainguard's Athena disclosure (12 Nov 2026).
#   Chainguard rebuilds (versions containing ".cgp." or ".cgb.") are skipped.
package cloudsmith

default match := false

# ===========================================================================
# 1. SETTINGS
# ===========================================================================

# Check SBOM components. Cloudsmith only provides an SBOM for Docker/OCI images.
check_sbom := true

# Use the hardcoded advisory data below. Once the records are public and in
# Cloudsmith's OSV data, set to false so only the OSV rule (section 6) applies.
use_deny_list := true

# IDs to switch off, e.g. {"CGP-9x7f-cpwh-f59q"}
disabled_ids := set()

# Extra IDs to look for in OSV data once assigned, e.g. {"CVE-2026-XXXXX"}
extra_osv_ids := set()

# ===========================================================================
# 2. ADVISORY DATA (from the Wave 2 CGP OSV records)
#
# versions:  every upstream version the record lists as affected.
# open_from: when set, any version at or above it also counts as affected.
# ===========================================================================
advisories := [
	{
		"id": "CGP-29c2-rpxq-q9xm",
		"group": "com.github.tomakehurst", "artifact": "wiremock-standalone",
		"cvss": 4.8, "cwe": "CWE-22",
		"title": "AbstractFileSource path containment check uses startsWith() without a separator, allowing sibling-directory escape in Wi",
		"open_from": "",
		"versions": {
			"2.16.0", "2.17.0", "2.18.0", "2.19.0", "2.20.0", "2.21.0", "2.22.0", "2.23.0", "2.23.1", "2.23.2",
			"2.24.0", "2.24.1", "2.25.0", "2.25.1", "2.26.0", "2.26.1", "2.26.2", "2.26.3", "2.27.0", "2.27.1",
			"2.27.2",
		},
	},
	{
		"id": "CGP-3x2p-3qw2-2ghh",
		"group": "org.apache.kerby", "artifact": "kerb-server",
		"cvss": 10.0, "cwe": "CWE-347",
		"title": "TokenPreauth in kerb-server 2.0.2 skips JWT signature verification when the request arrives over HTTPS, allowing forged ",
		"open_from": "",
		"versions": {"1.0.0", "1.0.1", "1.1.0", "1.1.1", "2.0.0", "2.0.1", "2.0.2", "2.0.3"},
	},
	{
		"id": "CGP-48gv-xfgw-w4hc",
		"group": "com.github.tomakehurst", "artifact": "wiremock-standalone",
		"cvss": 6.5, "cwe": "CWE-22",
		"title": "WireMock DeleteStubFileTask deletes files via user-supplied path with no root-containment check, enabling path traversal",
		"open_from": "",
		"versions": {
			"2.14.0", "2.15.0", "2.16.0", "2.17.0", "2.18.0", "2.19.0", "2.20.0", "2.21.0", "2.22.0", "2.23.0",
			"2.23.1", "2.23.2", "2.24.0", "2.24.1", "2.25.0", "2.25.1", "2.26.0", "2.26.1", "2.26.2", "2.26.3",
			"2.27.0", "2.27.1", "2.27.2",
		},
	},
	{
		"id": "CGP-69ph-rh6g-rg3p",
		"group": "org.apache.qpid", "artifact": "qpid-broker-core",
		"cvss": 3.7, "cwe": "CWE-208",
		"title": "Non-constant-time password comparison in AbstractPasswordFilePrincipalDatabase enables timing side-channel credential re",
		"open_from": "",
		"versions": {
			"0.26", "0.28", "0.30", "0.32", "6.0.0", "6.0.1", "6.0.2", "6.0.3", "6.0.4", "6.0.5", "6.0.6",
			"6.0.7", "6.0.8", "6.1.0", "6.1.1", "6.1.2", "6.1.3", "6.1.4", "6.1.5", "6.1.6", "6.1.7", "7.0.0",
			"7.0.1", "7.0.2", "7.0.3", "7.0.4", "7.0.5", "7.0.6", "7.0.7", "7.0.8", "7.0.9", "7.1.0", "7.1.1",
			"7.1.2", "7.1.3", "7.1.4", "7.1.5", "7.1.6", "7.1.7", "7.1.8", "7.1.9", "7.1.10", "7.1.11",
			"7.1.12", "8.0.0", "8.0.1", "8.0.2", "8.0.3", "8.0.4", "8.0.5", "8.0.6", "9.0.0", "9.1.0", "9.2.0",
			"9.2.1",
		},
	},
	{
		"id": "CGP-753c-3hg7-j33f",
		"group": "io.jsonwebtoken", "artifact": "jjwt",
		"cvss": 6.2, "cwe": "CWE-400",
		"title": "io.jsonwebtoken:jjwt 0.9.1 decompresses attacker-controlled JWT payloads before signature verification, enabling zip-bom",
		"open_from": "",
		"versions": {"0.6.0", "0.7.0", "0.8.0", "0.9.0", "0.9.1"},
	},
	{
		"id": "CGP-76vm-gg49-hx7p",
		"group": "com.sun.xml.messaging.saaj", "artifact": "saaj-impl",
		"cvss": 6.7, "cwe": "CWE-611",
		"title": "Unhardened XMLInputFactory in lazy StAX SOAP body path enables XXE file read, SSRF, and DoS when saaj.lazy.soap.body is ",
		"open_from": "3.0.6",
		"versions": {
			"1.3", "1.3.1", "1.3.2", "1.3.3", "1.3.4", "1.3.5", "1.3.6", "1.3.7", "1.3.8", "1.3.9", "1.3.10",
			"1.3.12", "1.3.13", "1.3.14", "1.3.15", "1.3.16", "1.3.17", "1.3.18", "1.3.19", "1.3.20", "1.3.21",
			"1.3.23", "1.3.24", "1.3.25", "1.3.26", "1.3.27", "1.3.28", "1.4.0-b01", "1.4.0-b02", "1.4.0-b03",
			"1.4.0", "1.5.0", "1.5.1", "1.5.2-b01", "1.5.2", "1.5.3", "2.0.0-M1", "2.0.0", "2.0.1", "3.0.0-M1",
			"3.0.0-M2", "3.0.0-M3", "3.0.2", "3.0.3", "3.0.4", "3.0.5", "3.0.6",
		},
	},
	{
		"id": "CGP-8339-r3p5-6gh4",
		"group": "org.javassist", "artifact": "javassist",
		"cvss": 7.5, "cwe": "CWE-36",
		"title": "Webserver.doReply() allows reading arbitrary files via a double-slash HTTP request that bypasses the docroot containment",
		"open_from": "",
		"versions": {
			"3.13.0-GA", "3.14.0-GA", "3.15.0-GA", "3.16.1-GA", "3.17.0-GA", "3.17.1-GA", "3.18.0-GA",
			"3.18.1-Beta1", "3.18.1-GA", "3.18.2-GA", "3.19.0-GA", "3.20.0-GA", "3.21.0-GA", "3.22.0-CR1",
			"3.22.0-CR2", "3.22.0-GA", "3.23.0-GA", "3.23.1-GA", "3.23.2-GA", "3.24.0-GA", "3.24.1-GA",
			"3.25.0-GA", "3.26.0-GA", "3.27.0-GA", "3.28.0-GA", "3.29.0-GA", "3.29.1-GA", "3.29.2-GA",
			"3.30.0-GA", "3.30.1-GA", "3.30.2-GA", "3.31.0-GA",
		},
	},
	{
		"id": "CGP-9x7f-cpwh-f59q",
		"group": "org.javassist", "artifact": "javassist",
		"cvss": 5.3, "cwe": "CWE-404",
		"title": "Webserver.process() does not close the client socket on exception, leaking file descriptors; a malformed request line al",
		"open_from": "",
		"versions": {
			"3.13.0-GA", "3.14.0-GA", "3.15.0-GA", "3.16.1-GA", "3.17.0-GA", "3.17.1-GA", "3.18.0-GA",
			"3.18.1-Beta1", "3.18.1-GA", "3.18.2-GA", "3.19.0-GA", "3.20.0-GA", "3.21.0-GA", "3.22.0-CR1",
			"3.22.0-CR2", "3.22.0-GA", "3.23.0-GA", "3.23.1-GA", "3.23.2-GA", "3.24.0-GA", "3.24.1-GA",
			"3.25.0-GA", "3.26.0-GA", "3.27.0-GA", "3.28.0-GA", "3.29.0-GA", "3.29.1-GA", "3.29.2-GA",
			"3.30.0-GA", "3.30.1-GA", "3.30.2-GA", "3.31.0-GA",
		},
	},
	{
		"id": "CGP-gcrw-87qp-x4c3",
		"group": "com.googlecode.libphonenumber", "artifact": "libphonenumber",
		"cvss": 6.2, "cwe": "CWE-1333",
		"title": "PhoneNumberUtil.isAlphaNumber() bypasses the MAX_INPUT_STRING_LENGTH guard, enabling O(n\u00b2) ReDoS via VALID_PHONE_NUMBER_",
		"open_from": "",
		"versions": {
			"3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4.0", "4.1", "4.2", "4.3", "4.4",
			"4.5", "4.6", "4.7", "4.8", "4.9", "5.0", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8",
			"5.9", "6.0", "6.1", "6.2", "6.2.2", "6.3", "6.3.1", "7.0", "7.0.1", "7.0.2", "7.0.3", "7.0.4",
			"7.0.5", "7.0.6", "7.0.7", "7.0.8", "7.0.9", "7.0.10", "7.0.11", "7.1.0", "7.1.1", "7.2.0", "7.2.1",
			"7.2.2", "7.2.3", "7.2.4", "7.2.5", "7.2.6", "7.2.7", "7.2.8", "7.3.0", "7.3.1", "7.3.2", "7.4.0",
			"7.4.1", "7.4.2", "7.4.3", "7.4.4", "7.4.5", "7.5.0", "7.5.1", "7.5.2", "7.6.0", "7.6.1", "7.7.0",
			"7.7.1", "7.7.2", "7.7.3", "7.7.4", "7.7.5", "8.0.0", "8.0.1", "8.1.0", "8.2.0", "8.3.0", "8.3.1",
			"8.3.2", "8.3.3", "8.4.0", "8.4.1", "8.4.2", "8.4.3", "8.5.0", "8.5.1", "8.5.2", "8.6.0", "8.7.0",
			"8.7.1", "8.8.0", "8.8.1", "8.8.2", "8.8.3", "8.8.4", "8.8.5", "8.8.6", "8.8.7", "8.8.8", "8.8.9",
			"8.8.10", "8.8.11", "8.9.0", "8.9.1", "8.9.2", "8.9.3", "8.9.4", "8.9.5", "8.9.6", "8.9.7", "8.9.8",
			"8.9.9", "8.9.10", "8.9.11", "8.9.12", "8.9.13", "8.9.14", "8.9.15", "8.9.16", "8.10.0", "8.10.1",
			"8.10.2", "8.10.3", "8.10.4", "8.10.5", "8.10.6", "8.10.7", "8.10.8", "8.10.9", "8.10.10",
			"8.10.11", "8.10.12", "8.10.13", "8.10.14", "8.10.15", "8.10.16", "8.10.17", "8.10.18", "8.10.19",
			"8.10.20", "8.10.21", "8.10.22", "8.10.23", "8.11.0", "8.11.1", "8.11.2", "8.11.3", "8.11.4",
			"8.11.5", "8.12.0", "8.12.1", "8.12.2", "8.12.3", "8.12.4", "8.12.5", "8.12.6", "8.12.7", "8.12.8",
			"8.12.9", "8.12.10", "8.12.11", "8.12.12", "8.12.13", "8.12.14", "8.12.15", "8.12.16", "8.12.17",
			"8.12.18", "8.12.19", "8.12.20", "8.12.21", "8.12.22", "8.12.23", "8.12.24", "8.12.25", "8.12.26",
			"8.12.27", "8.12.28", "8.12.29", "8.12.30", "8.12.31", "8.12.32", "8.12.33", "8.12.34", "8.12.35",
			"8.12.36", "8.12.37", "8.12.38", "8.12.39", "8.12.40", "8.12.41", "8.12.42", "8.12.43", "8.12.44",
			"8.12.45", "8.12.46", "8.12.47", "8.12.48", "8.12.49", "8.12.50", "8.12.51", "8.12.52", "8.12.53",
			"8.12.54", "8.12.55", "8.12.56", "8.12.57", "8.13.0", "8.13.1", "8.13.2", "8.13.3", "8.13.4",
			"8.13.5", "8.13.6", "8.13.7", "8.13.8", "8.13.9", "8.13.10", "8.13.11", "8.13.12", "8.13.13",
			"8.13.14", "8.13.15", "8.13.16", "8.13.17", "8.13.18", "8.13.19", "8.13.20", "8.13.21", "8.13.22",
			"8.13.23", "8.13.24", "8.13.25", "8.13.26", "8.13.27", "8.13.28", "8.13.29", "8.13.30", "8.13.31",
			"8.13.32", "8.13.33", "8.13.34", "8.13.35", "8.13.36", "8.13.37", "8.13.38", "8.13.39", "8.13.40",
			"8.13.41", "8.13.42", "8.13.43", "8.13.44", "8.13.45", "8.13.46", "8.13.47", "8.13.48", "8.13.49",
			"8.13.50", "8.13.51", "8.13.52", "8.13.53", "8.13.54", "8.13.55", "9.0.0", "9.0.1", "9.0.2",
			"9.0.3", "9.0.4", "9.0.5", "9.0.6", "9.0.7", "9.0.8", "9.0.9", "9.0.10", "9.0.11", "9.0.12",
			"9.0.13", "9.0.14", "9.0.15", "9.0.16", "9.0.17", "9.0.18", "9.0.19", "9.0.20", "9.0.21", "9.0.22",
			"9.0.23", "9.0.24", "9.0.25", "9.0.26", "9.0.27", "9.0.28", "9.0.29", "9.0.30", "9.0.31", "9.0.32",
			"9.0.33", "9.0.34", "9.0.35", "9.0.36", "9.0.37", "9.0.38", "9.0.39", "9.0.40",
		},
	},
	{
		"id": "CGP-grwg-42x8-w9x7",
		"group": "com.auth0", "artifact": "java-jwt",
		"cvss": 4.0, "cwe": "CWE-125",
		"title": "ECDSAAlgorithm.countPadding reads one byte past the array end when the S-half of a JOSE signature is all zeros, causing ",
		"open_from": "",
		"versions": {
			"3.0.1", "3.0.2", "3.1.0", "3.2.0", "3.3.0", "3.4.0", "3.4.1", "3.5.0", "3.6.0", "3.7.0", "3.8.0",
			"3.8.1", "3.8.2", "3.8.3", "3.9.0", "3.10.0", "3.10.1", "3.10.2", "3.10.3", "3.11.0", "3.12.0",
			"3.12.1", "3.13.0", "3.14.0", "3.15.0", "3.16.0", "3.17.0", "3.18.0", "3.18.1", "3.18.2", "3.18.3",
			"3.19.0", "3.19.1",
		},
	},
	{
		"id": "CGP-pqgh-898g-975x",
		"group": "org.mock-server", "artifact": "mockserver-core",
		"cvss": 9.3, "cwe": "CWE-611",
		"title": "XmlSchemaValidator explicitly sets ACCESS_EXTERNAL_DTD and ACCESS_EXTERNAL_SCHEMA to 'all', enabling XXE and SSRF via bo",
		"open_from": "",
		"versions": {
			"5.5.4", "5.6.0", "5.6.1", "5.7.0", "5.7.1", "5.7.2", "5.8.0", "5.8.1", "5.9.0", "5.10", "5.10.0",
			"5.11.0", "5.11.1", "5.11.2", "5.12.0", "5.13.0", "5.13.1", "5.13.2", "5.14.0", "5.15.0",
		},
	},
	{
		"id": "CGP-qfvj-qrwj-6c8w",
		"group": "io.jsonwebtoken", "artifact": "jjwt-impl",
		"cvss": 6.7, "cwe": "CWE-347",
		"title": "DefaultJwtParser.parse(String) skips all signature verification when the JWT signature segment is empty, bypassing confi",
		"open_from": "",
		"versions": {
			"0.10.0", "0.10.1", "0.10.2", "0.10.3", "0.10.4", "0.10.5", "0.10.6", "0.10.7", "0.10.8", "0.11.0",
			"0.11.1", "0.11.2", "0.11.3", "0.11.4", "0.11.5",
		},
	},
]

active_advisories contains adv if {
	some adv in advisories
	not adv.id in disabled_ids
}

# ===========================================================================
# 3. SHARED HELPERS
# ===========================================================================

# Chainguard's patched rebuilds carry a "-0.cgp.N" or "-0.cgb.N" suffix and are safe.
is_chainguard_build(version) if contains(version, ".cgp.")

is_chainguard_build(version) if contains(version, ".cgb.")

# Numeric parts of a version, e.g. "3.31.0-GA" -> [3, 31, 0]. Used only for open_from.
# Uses plain string built-ins only (no regex), so it works in Cloudsmith's policy engine.
version_key(v) := [to_number(p) |
	some p in split(replace(v, "-", "."), ".")
	p != ""
	trim(p, "0123456789") == ""
]

# Is this version affected by this advisory?
version_affected(adv, version) if version in adv.versions

version_affected(adv, version) if {
	adv.open_from != ""
	version_key(version) >= version_key(adv.open_from)
}

# Turn null/missing values into an empty list so iteration never fails.
as_list(x) := x if is_array(x)

as_list(x) := [] if not is_array(x)

# ===========================================================================
# 4. RULE A: THE PACKAGE ITSELF (Maven coordinates from "summary")
#
# For Maven, Cloudsmith's "name" is the artifactId only. The groupId is only in
# "summary", which Cloudsmith always sets as "groupId:artifactId:version".
# ===========================================================================
pkg := input.v0["package"]

summary_parts := split(object.get(pkg, "summary", ""), ":")

pkg_group := summary_parts[0] if count(summary_parts) >= 3

pkg_artifact := summary_parts[1] if count(summary_parts) >= 3

package_hits contains adv if {
	use_deny_list
	lower(pkg.format) == "maven"
	not is_chainguard_build(pkg.version)
	some adv in active_advisories
	pkg_group == adv.group
	pkg_artifact == adv.artifact
	version_affected(adv, pkg.version)
}

# ===========================================================================
# 5. RULE B: SBOM COMPONENTS (Docker/OCI images that bundle an affected library)
#
# Components carry a purl like "pkg:maven/<groupId>/<artifactId>@<version>".
# ===========================================================================
# Reference input.v0.sbom directly: Cloudsmith only sends input fields whose path
# appears literally in the Rego (object.get(input.v0, "sbom", ...) is not detected).
default sbom_components := []

sbom_components := input.v0.sbom.components if is_array(input.v0.sbom.components)

parse_maven_purl(purl) := coords if {
	startswith(purl, "pkg:maven/")
	rest := split(split(trim_prefix(purl, "pkg:maven/"), "#")[0], "?")[0]
	at := split(rest, "@")
	count(at) == 2
	path := split(at[0], "/")
	count(path) == 2
	coords := {"group": path[0], "artifact": path[1], "version": at[1]}
}

# Advisories looked up by "groupId:artifactId", so each component is one lookup.
advisory_key(adv) := concat(":", [adv.group, adv.artifact])

advisories_by_key[key] contains adv if {
	some adv in active_advisories
	key := advisory_key(adv)
}

sbom_hits contains msg if {
	use_deny_list
	check_sbom
	some c in sbom_components
	coords := parse_maven_purl(c.purl)
	some adv in advisories_by_key[concat(":", [coords.group, coords.artifact])]
	not is_chainguard_build(coords.version)
	version_affected(adv, coords.version)
	msg := sprintf(
		"Bundles %s:%s %s, affected by %s (CVSS %.1f, %s): %s",
		[adv.group, adv.artifact, coords.version, adv.id, adv.cvss, adv.cwe, adv.title],
	)
}

# ===========================================================================
# 6. RULE C: OSV DATA (after disclosure, once records are ingested)
#
# Cloudsmith only attaches OSV records whose version ranges cover this package.
# These IDs may appear as the record id, in "aliases" or in "upstream".
# ===========================================================================
tracked_ids := {adv.id | some adv in active_advisories} | extra_osv_ids

record_ids(v) := ({v.id} | {a | some a in as_list(object.get(v, "aliases", []))}) | {u | some u in as_list(object.get(v, "upstream", []))}

# Reference input.v0.osv directly so Cloudsmith includes OSV data in the input.
default osv_records := []

osv_records := input.v0.osv if is_array(input.v0.osv)

osv_hits contains msg if {
	some v in osv_records
	some id in record_ids(v)
	id in tracked_ids
	msg := sprintf("OSV record %s references Athena Wave 2 ID %s", [v.id, id])
}

# ===========================================================================
# 7. RESULT
# ===========================================================================
match if count(package_hits) > 0

match if count(sbom_hits) > 0

match if count(osv_hits) > 0

reason contains msg if {
	some adv in package_hits
	msg := sprintf(
		"%s (CVSS %.1f, %s): %s %s:%s %s is affected.",
		[adv.id, adv.cvss, adv.cwe, adv.title, adv.group, adv.artifact, pkg.version],
	)
}

reason contains msg if some msg in sbom_hits

reason contains msg if some msg in osv_hits
