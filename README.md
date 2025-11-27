# Cloudsmith EPM Recipes
A curated collection of Enterprise Policy Management (EPM) recipes for Cloudsmith - combining practical OPA Rego policy samples, action configurations, and testing guides to help you define, simulate, and enforce package lifecycle rules across your repositories.
<br/><br/>
This repository includes:
- Rego policies tailored for Cloudsmith’s EPM engine, using the supported input schema and policy format.
- Policy action configurations (```SetPackageState```, ```AddPackageTags```, etc.) with examples showing how to order and associate them by precedence.
- Simulation and deployment instructions using Cloudsmith’s API, including how to safely test policies before enforcement.
- Helper scripts and workflows to automate policy testing and promotion.

These recipes are designed to be modular, auditable, and production-ready - with a strong emphasis on policy-as-code best practices.

***

### Table of Rego Samples

|           Name              |                                        Description                                                              |  Rego Playground |
|         --------            |                                          -------                                                                |      -------     |
| [Enforcing Signed Packages](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-1---enforcing-signed-packages)   | This policy enforces mandatory ```GPG/DSA signature``` checks on packages during their sync/import into Cloudsmith    |  Link  |
| [Restriction Based on Tags](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-2---restricting-package-based-on-tags)   | This policy checks whether a package includes specific ```deprecated``` tag and marks it as match if present    |  Link  |
| [Copy-Left licensing](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-3---copyleft-or-restrictive-oss-licenses)         | This policy is designed to detect a broad range of copyleft licenses, including free-text and SPDX variants     |  Link  |
| [Quarantine Debug Builds](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-4---restricting-package-based-on-tags)     | Identify and quarantine packages that look like debug/test artifacts based on filename or metadata patterns     |  Link  |
| [Limit Tag Sprawl](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-5---limit-tag-sprawl)            | Flag any packages that have more than a threshold number of tags to avoid ungoverned tagging behaviours         |  Link  |
| [Enforce Consistent Filename](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-6---enforce-consistent-filename-convention) | Validate whether the filename convention matches a semantic or naming pattern via Regular Expressions           |  [Link](https://play.openpolicyagent.org/p/g_YjIwNzZhMzYwNzU5OGE1NmE5ZTk2OWUwYjYwZjVkZmRfog2dl4QYeaXGZWOE7ZBna4dFC70)  |
| [Approved Upstreams based on Tags](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-7---approved-upstreams-based-on-tags)      | Only packages from explicitly approved upstream sources are permitted, helping to prevent the propagation of unvetted or insecure dependencies.   |  [Link](https://play.openpolicyagent.org/p/1cBxdKbgYb)  |
| [CVSS Policy with Fix Available](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-8---cvss-with-fix-available)      | Match packages in a specific repo that have high/critical fixed vulnerabilities, excluding specific known CVEs.    |  [Link](https://play.openpolicyagent.org/p/aBZ7foSYWR)  |
| [Time-Based CVSS Policy](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-9---time-based-cvss-policy)      | Evaluate CVEs older than 30 days. Checks CVSS threshold ≥ 7. Filters for a specific repo. Ignores certain CVE   |  [Link](https://play.openpolicyagent.org/p/dHSTerY2jn)  |
| CVSS with EPSS context      | Combines High scoring CVSS vulnerability with EPSS scoring context that go above a specific threshold.          |  Link  |
| [Architecture allow list](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-11---architecture-specific-allow-list)      | Policy that only allows ```amd64``` architecture packages and blocks others like arm64.          |  [Link](https://play.openpolicyagent.org/p/bmVtmxYysJ)  |
| [Block package if version over 0.16.0](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-12---block-package-xyz-if-version--0160)  | ```semver.compare(pkg.version, "0.16.0") == -1``` should check if the version is less than ```0.16.0``` using semver-aware comparison.     |  Link  |
| [Block package if version under 1.0.0](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-13---match-versions-less-than-100-such-as-0140)  | Cloudsmith's EPM currently does not support Rego's semver functions because those require a Rego SDK integration, which Cloudsmith doesn't provide at the moment. This means version comparison must be done via string comparison, which only works safely for zero-padded numeric versions or very simple SemVer patterns. If your versions are formatted like "1.2.3" without pre-release/build tags, you can sometimes get away with lexicographical comparisons.     |  Link  |
| [Block specific package and version](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-14---block-specific-package-and-version)  | Blocks a specific package and package version     |  Link  |
| [Block specific CVE numbers](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-15---block-specifically-based-on-cves)  | Blocks a specific package based on known CVE numbers     |  Link  |
| [Enforce Upload Time Window](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-16---suspicious-package-upload-window)  | Allow uploads during business hours (9 AM – 5 PM UTC), to catch anomalous behaviour like late-night uploads     |  Link  |
| [Tag-based bypass Exception](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-17---tag-based-exception-policy)  | This is a simple tag-based exception.     |  Link  |
| [Exact allowlist with CVSS limit exemption](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-18---exact-allowlist-exception-policy-with-cvss-ceiling)  | Use when you want tight control per version, but still prevent exemptions if a CVSS exceeds a ceiling.     |  Link  |
| [Malware advisory](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-19---malware-advisory)  | Match for malware advisory.     |  Link  |
| [npm last published date](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-20---npm-last-published-date)  | Use when you want to tag or stop devs from using the lastest npm package.     |  Link  |
| [Exact blocklist by format/name/version](https://github.com/cloudsmith-io/rego-recipes/tree/main?tab=readme-ov-file#recipe-21---exact-blocklist) | Blocks packages that appear on a known-bad exact list across formats (e.g. npm/python) before your upstream removes them.     |  Link  |
| [Huggingface Recipes](https://github.com/cloudsmith-io/rego-recipes/blob/main/huggingface-recipes/README.md/)  | Policies relating to Hugging Face models/datasets.     |  N/A  |

***

### Recipe 1 - Enforcing Signed Packages
This policy enforces mandatory GPG/DSA signature checks on packages during their sync/import into Cloudsmith <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-1/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Enforcing Signed Packages",
  "description": "This policy enforces mandatory GPG/DSA signature checks on packages during their sync/import into Cloudsmith.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF
```

Once the policy is created, here is how you can perform a controlled test. <br/>
Create a simple dummy python package locally that we know for certain is unsigned. <br/>
Your policy will trigger, since ```input.v0.package.signed``` will not be present or will default to ```false```.

```
mkdir dummy_unsigned
cd dummy_unsigned
echo "from setuptools import setup; setup(name='dummy_unsigned', version='0.0.1')" > setup.py
python3 -m pip install --upgrade build
apt install python3.10-venv
python3 -m build  # produces dist/dummy_unsigned-0.0.1.tar.gz
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO dist/dummy_unsigned-0.0.1.tar.gz -k "$CLOUDSMITH_API_KEY"
```

***

### Recipe 2 - Restricting Package Based on Tags
This policy checks whether a package includes a specific ```deprecated``` tag and marks it as a match if it does. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-2/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Restricting Package Based on Tags",
  "description": "This policy checks whether a package includes a specific DEPRECATED tag.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 2
}
EOF
```

Once ready, download a random package, in this case a python package called ```h11``` and push the package to Cloudsmith with the ```deprecated``` tag to cause the policy violation:
```
pip download h11==0.14.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO h11-0.14.0-py3-none-any.whl -k "$CLOUDSMITH_API_KEY"  --tags deprecated
```

***

### Recipe 3 - Copyleft or restrictive OSS licenses
This policy is designed to flag packages that use ```copyleft``` or ```restrictive``` open-source licenses, particularly those unsuitable for production use <b>without legal review or approval</b>. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-3/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Copyleft licensing policy",
  "description": "This policy checks packages that are unsuitable for production.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 3
}
EOF
```

Once ready, download the Python ```Gitlab v.3.1.1``` package that we know has a ```LGPLv3 license``` that should trigger the policy:
```
pip download python-gitlab==3.1.1
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO python_gitlab-3.1.1-py3-none-any.whl -k "$CLOUDSMITH_API_KEY"  --tags lgplv3license
cloudsmith list packages acme-corporation/acme-repo-one -k "$CLOUDSMITH_API_KEY" -q "format:python AND tag:lgplv3license"
```

Note: If you have a tagging response action attached to your policy, you could tag the package with ```non-compliant-license``` for further review:

<img width="856" height="663" alt="Screenshot 2025-07-30 at 14 21 19" src="https://github.com/user-attachments/assets/8f795b5e-6516-4173-ac94-817574697b04" />

<img width="1494" height="681" alt="Screenshot 2025-07-30 at 14 28 43" src="https://github.com/user-attachments/assets/d123ea4e-2318-46b2-8aab-aa0c408e08c2" />


***

### Recipe 4 - Quarantine Debug Builds
This policy checks whether a package includes specific ```debug```, ```test```, or ```temp``` descriptors in the filename.
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-4/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Quarantine Debug Builds",
  "description": "Identify and quarantine packages that look like debug/test artifacts based on filename or metadata patterns.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 4
}
EOF
```

Once ready, download ```debugpy``` Python package and push it to Cloudsmith to cause the policy violation:
```
pip download --no-deps --dest . debugpy 
&& cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO debugpy-1.8.14-cp310-cp310-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl -k "$CLOUDSMITH_API_KEY"
```

***

### Recipe 5 - Limit Tag Sprawl
This policy checks whether a package already includes ```5``` or more assigned tags - conidered as sprawl by some orgs.
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-5/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Limit Tag Sprawl",
  "description": "Flag packages that have more than a threshold number of tags to avoid ungoverned tagging behaviours.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 5
}
EOF
```

Once ready, download ```transformers``` Python and assign it ```5 tags``` during the Cloudsmith push process to cause the policy violation:
```
pip download transformers --no-deps
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO transformers-4.53.1-py3-none-any.whl -k "$CLOUDSMITH_API_KEY" --tags TAG1,TAG2,TAG3,TAG4,TAG5
```

***

### Recipe 6 - Enforce Consistent Filename Convention
Validate filename matches a semantic or naming pattern where ```MAJOR```.```MINOR```, and ```PATCH``` are all numeric. 
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-6/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Enforce Consistent Filename Convention",
  "description": "Validate filename matches a semantic or naming pattern.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 6
}
EOF
```

A straightforward way to test this policy is to take a package that already has a valid SemVer-compliant filename and rename it by replacing the version number with a placeholder like ```test```:

```
pip download h11==0.14.0
mv h11-0.14.0-py3-none-any.whl h11-test.whl
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO h11-test.whl -k "$CLOUDSMITH_API_KEY"
```

***

### Recipe 7 - Approved Upstreams based on Tags
Simply put, this approves packages based on the specified upstream source. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-7/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Approved Upstreams based on Tags",
  "description": "Only packages from explicitly approved upstream sources are permitted, helping to prevent the propagation of unvetted or insecure dependencies.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 7
}
EOF
```

If a package has ```upstream``` <b>and not</b> ```approved``` --> allowed
<br/><br/>
If a package has ```approved``` --> blocked (<b>even if upstream is present</b>)


***

### Recipe 8 - CVSS with Fix Available
This policy is designed to match packages in a specific repository (```acme-repo-one```) that have ```high``` or ```critical``` with a ```Fixed version available```, excluding specific ```known CVEs```. 
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-8/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "CVSS with Fix Available",
  "description": "Matched packages from a specific repository that have high or critical vulnerabilities that can be patched.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 8
}
EOF
```

To demonstrate this policy, you can use the ```requests``` Python package, which has a known vulnerability with a high CVSS score.
<br/><br/>
<b>Vulnerability Details:</b>
<br/>
- <b>Package:</b>  h11
- <b>Affected Version:</b> 0.14.0
- <b>Fixed In:</b> 0.16.0
- <b>CVE Identifier:</b>  [CVE-2025-43859](https://access.redhat.com/security/cve/cve-2025-43859)
- <b>CVSS Context:</b> This CVE record has been marked for NVD enrichment efforts.
- <b>Description:</b> An HTTP request smuggling vulnerability in python-h11.

```
pip download h11==0.14.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO h11-0.14.0-py3-none-any.whl -k "$CLOUDSMITH_API_KEY"
```

You'll probably want to enable a [Quarantine](https://help.cloudsmith.io/docs/package-quarantine) action for policies dealing with critical vulnerabilities that can be fixed:

<img width="965" height="202" alt="Screenshot 2025-07-28 at 10 28 21" src="https://github.com/user-attachments/assets/85f34bd8-247f-4cef-b7e0-93507b60cf48" />


***

### Recipe 9 - Time-based CVSS Policy
This policy is designed to detect and flag packages in a specific repo that contain serious, outdated, but fixed vulnerabilities.
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-9/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Time-based CVSS policy",
  "description": "Only matches if the vulnerability was published more than 30 days ago.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 9
}
EOF
```

This CVE was published on <b>24 April 2025</b> - much older than the 30 day threshold specified in the policy.

```
pip download h11==0.14.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO h11-0.14.0-py3-none-any.whl -k "$CLOUDSMITH_API_KEY"
```

***


### Recipe 11 - Architecture-specific allow list
This policy only allows ```amd64``` architecture packages and blocks others like ```arm64```.
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-11/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Architecture-specific allow list",
  "description": "Policy that only allows amd64 architecture packages and blocks others like arm64",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 11
}
EOF
```

To trigger the above policy (which blocks all architectures <b>except</b> ```amd64```), you'd want to upload or sync a Python package that is built for a ```non-amd64``` architecture - like ```arm64```.
<br/><br/>
However, pip by default fetches packages built for your local system architecture, so you typically won't download architecture-specific wheels unless they're explicitly tagged.
<br/><br/>
Here's a command to download a known Python package with an ARM-specific wheel using pip download:
```
pip download numpy --platform manylinux2014_aarch64 --only-binary=:all: --python-version 38 --implementation cp --abi cp38
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO numpy-1.24.4-cp38-cp38-manylinux_2_17_aarch64.manylinux2014_aarch64.whl -k "$CLOUDSMITH_API_KEY"
```

- ```--platform manylinux2014_aarch64```: targets ```arm64``` (```aarch64```)
- ```--only-binary=:all:```: avoid source dist, force binary wheel
- ```--python-version 38``` and ```--abi cp38```: simulate Python 3.8 CPython ABI

<img width="995" height="696" alt="Screenshot 2025-07-28 at 11 26 50" src="https://github.com/user-attachments/assets/cd654f84-3fc9-4cfd-a222-3c4d0f13e22e" />


***


### Recipe 12 - Block Package XYZ if version < 0.16.0
This policy matches any ```h11``` packages with a version older than ```0.16.0```: <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-12/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Forced Upgrade of Package Versions",
  "description": "Forces teams to periodically upgrade versions of certain package dependencies, so they don't fall too far behind.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 12
}
EOF
```

***


### Recipe 13 - Match versions less than 1.0.0, such as 0.14.0
If you want to match versions less than ```1.0.0```, such as ```0.14.0```: <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-13/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "match versions less than 1.0.0",
  "description": "match versions less than 1.0.0, such as 0.14.0",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 13
}
EOF
```

```
pip download h11==0.14.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO h11-0.14.0-py3-none-any.whl -k "$CLOUDSMITH_API_KEY"
```

<img width="1492" height="433" alt="Screenshot 2025-07-28 at 13 57 54" src="https://github.com/user-attachments/assets/ff3e5776-6d2c-47d9-b561-1da9c45bf59c" />


Alternatively, here’s a simple (but fragile) example using string comparison:

```
package cloudsmith
default match := false
match if count(reason) > 0

reason contains msg if {
  pkg := input.v0["package"]
  startswith(pkg.version, "1.")
  msg := sprintf("Package version '%s' is less than 2.0.0", [pkg.version])
}
```

This will match versions like "```1.9.9```" or "```1.0.0```", <b>but not</b> "```1.10.0```" being greater than "```1.2.```0" — since it's string-based. <br/>

### Limitations
- "```1.10.0```" < "```1.2.0```" is <b>true</b> in string comparison, but <b>false</b> semantically.
- Pre-release versions like "```2.0.0-beta```" may confuse logic unless handled explicitly.
- Multi-digit segments break string comparisons unless you zero-pad them ("```01.02.003```").

### Recommendation
If version control is essential:
- Add <b>strict prefix/regex filters</b> (example: ```startswith(pkg.version, "2.")```)
- Combine with file naming conventions or upload context
- Enforce via CI before publishing, if possible

### Safer Rego Pattern
```
package cloudsmith
default match := false
match if count(reason) > 0
reason contains msg if {
  pkg := input.v0["package"]
  pkg.version < "2.0.0"
  msg := sprintf("Package version '%s' is below required threshold of 2.0.0", [pkg.version])
}
```

So: this works in simple cases, but not trustworthy for tight numeric ranges unless all version segments are zero-padded (for example: "```01.09.000```").

***

### Recipe 14 - Block specific package and version
This policy will specifically block the Python package ```requests``` on version ```2.6.0```: <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-14/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Block specific package and version",
  "description": "match requests python package o v.2.6.0",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 14
}
EOF
```

```
pip download requests==2.6.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO requests-2.6.0-py2.py3-none-any.whl -k "$CLOUDSMITH_API_KEY"
```

<img width="988" height="738" alt="Screenshot 2025-07-29 at 13 06 05" src="https://github.com/user-attachments/assets/f3bed11b-be80-43af-8f16-4910f1576787" />

***

### Recipe 15 - Block specifically based on CVEs
Again, the Python package ```requests``` version ```2.6.0``` has the known vulnerability ```CVE-2018-18074```: <br/>
We have commented out the other CVEs in this policy, but feel free remove those comments and add additional CVEs as a list. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-15/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Block specific CVE numbers",
  "description": "This policy is only blocking CVE-2018-18074 specifically",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 15
}
EOF
```

```
pip download requests==2.6.0
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO requests-2.6.0-py2.py3-none-any.whl -k "$CLOUDSMITH_API_KEY"
```

<img width="987" height="742" alt="Screenshot 2025-07-29 at 13 43 39" src="https://github.com/user-attachments/assets/28f44055-8986-4304-a7e7-ad6bb17b47aa" />


***


### Recipe 16 - Suspicious Package Upload Window
Assuming your organisation don't expect packages to be uploaded or modified at specific times, the below policy can detect package uploads at ```9am-11am UTC``` - regardless of the package name. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-16/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Package Upload Window",
  "description": "Flag any package uploaded outside of working hours",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 16
}
EOF
```

```
pip download <package-name>
cloudsmith push python $CLOUDSMITH_ORG/$CLOUDSMITH_REPO <package-name>.whl -k "$CLOUDSMITH_API_KEY"
```

***


### Recipe 17 - Tag-Based Exception Policy
Use this policy when you need a quick, time-boxed exception. For example, policy can quarantine by severity; where a separate terminal exemption policy matches if a package has an exempt tag and stops further evaluation.<br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-17/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Tag based exception",
  "description": "Exception policy based on basic tagging",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 17
}
EOF
```

**Trade-off:** While the tag remains, new CVEs on that package won’t trigger quarantine. You'll need to review those tags regularly.

***

### Recipe 18 - Exact allowlist exception policy with CVSS ceiling
Use when you want tight control per version, but still prevent exemptions if a CVSS exceeds a ceiling. <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-18/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Specific allowlist exception",
  "description": "Controls based on exact version but still prevent exemptions if a CVSS exceeds a ceiling.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 18
}
EOF
```

**Trade-off:** While the tag remains, new CVEs on that package won’t trigger quarantine. You'll need to review those tags regularly.

***

### Recipe 19 - Malware advisory
Use when you want to match based on malware advisory <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-19/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "Malware",
  "description": "Control malware ingestion.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": true,
  "precedence": 1
}
EOF
```
***

### Recipe 20 - npm last published date
Use when you want to match based on the npm last published date on npm upstream <br/>
Download the ```policy.rego``` and create the associated ```payload.json``` with the below command:
```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-20/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)

cat <<EOF > payload.json
{
  "name": "npm last published date on npm upstream",
  "description": "Match if the publish date comes after the date of the set number of days ago..",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": true,
  "precedence": 1
}
EOF
```
***

### Recipe 21 - Exact blocklist

This policy lets you maintain an **exact deny list** of suspicious or malicious packages across formats using the key pattern:

`<format>:<name>:<version>` (for example: `npm:@alloc/quick-lru:5.2.0`, `python:requests:2.6.0`).

It’s especially useful for incident response scenarios like Shai-Hulud-style attacks, where you receive a CSV or text list of impacted packages and need to block them immediately — even before upstream registries have removed them.

Download the `policy.rego` and create the associated `payload.json` with:

```bash
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/recipe-21/policy.rego
escaped_policy=$(jq -Rs . < policy.rego)
cat <<EOF > payload.json
{
  "name": "Exact blocklist by format/name/version",
  "description": "Blocks packages that appear on an external suspicious or malicious list, using exact format:name:version matches.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": true,
  "precedence": 1
}
EOF

### Hugging Face recipes

For policies relating to Hugging Face models and datasets, see [Hugging Face Recipes](https://github.com/cloudsmith-io/rego-recipes/blob/main/huggingface-recipes/README.md/).
