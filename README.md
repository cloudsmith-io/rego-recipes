# rego-recipes
Cloudsmith EPM Rego samples

|           Name              |                                        Description                                                              |
|         --------            |                                          -------                                                                |
| Enforcing Signed Packages   | This policy enforces mandatory GPG/DSA signature checks on packages during their sync/import into Cloudsmith    |
| Restriction Based on Tags   | This policy checks whether a package includes specific "maven-central" tags and marks it as match if present    |
| Copy-Left licensing Match   | This policy is designed to detect a broad range of copyleft licenses, including free-text and SPDX variants     |
| Limiting Package Size - WIP | The goal of this policy is to prevent packages larger than 30MB from being accepted during the sync process     |
| Time-Based CVSS Policy      | Evaluate CVEs older than 30 days. Checks CVSS threshold ≥ 7. Filters for a specific repo. Ignores certain CVE   |
| CVSS with EPSS context      | Combines High scoring CVSS vulnerability with EPSS scoring context that go above a specific threshold.          |
| Enforce Upload Time Window  | Allow uploads during business hours (9 AM – 5 PM UTC), to catch anomalous behaviour like late-night uploads     |
| Quarantine Debug Builds     | Identify and quarantine packages that look like debug/test artifacts based on filename or metadata patterns     |
| Limit Tag Sprawl            | Flag any packages that have more than a threshold number of tags to avoid ungoverned tagging behaviours         |
| Enforce Consistent Filename | Validate whether the filename convention matches a semantic or naming pattern via Regular Expressions           |
| Enforce Consistent Filename | Validate whether the filename convention matches a semantic or naming pattern via Regular Expressions           |
