# rego-recipes
Cloudsmith EPM Rego samples

### Table of Rego Samples

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


### Recipe 2 - Restricting Package Based on Tags
This policy checks whether a package includes a specific ```deprecated``` tag and marks it as a match if it does.
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
