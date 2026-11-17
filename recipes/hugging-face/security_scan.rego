# METADATA
# title: Hugging Face Hub scan — malicious model files
# description: Quarantine Hugging Face models where the Hub's scanners found malware or
#   code-executing pickle imports. Ignores incomplete scans and low-confidence findings.
package cloudsmith

default match := false

pkg := input.v0.package
ms := input.v0.model_security

# Only these count as a definite finding. "suspicious" and "caution" are left for review,
# and "unscanned"/"queued" never match, so an incomplete scan cannot trigger this policy.
definite(scan) if scan.status == "unsafe"

# picklescan: an import it classes as dangerous (builtins.eval, os.system, subprocess, ...).
dangerous_import(d) if {
	some imp in object.get(d, ["pickle", "pickleImports"], [])
	imp.safety == "dangerous"
}

# A file is malicious when the Hub marks it UNSAFE and at least one scanner is definite,
# or picklescan found a dangerous import.
malicious(d) if {
	d.status == "UNSAFE"
	some s in ["clamav", "jfrog", "protect_ai", "pickle"]
	definite(d[s])
}

malicious(d) if {
	d.status == "UNSAFE"
	dangerous_import(d)
}

# Evidence per file: "path [scanner: message; ...]"
evidence(d) := [e |
	some s in ["clamav", "jfrog", "protect_ai", "pickle"]
	definite(d[s])
	e := sprintf("%s: %s", [s, object.get(d[s], "message", "unsafe")])
]

malicious_files contains sprintf("%s [%s]", [d.path, concat("; ", evidence(d))]) if {
	some d in object.get(ms, "scan_details", [])
	malicious(d)
}

match if {
	pkg.format == "huggingface"
	ms.scan_summary == "UNSAFE"
	count(malicious_files) > 0
}

reason contains sprintf("Hugging Face Hub scanners found malicious content in %d file(s): %v", [count(malicious_files), sort(malicious_files)]) if match
