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
| Copy-Left licensing         | This policy is designed to detect a broad range of copyleft licenses, including free-text and SPDX variants     |  Link  |
| [Quarantine Debug Builds](https://github.com/cloudsmith-io/rego-recipes/blob/main/README.md#recipe-4---restricting-package-based-on-tags)     | Identify and quarantine packages that look like debug/test artifacts based on filename or metadata patterns     |  Link  |
| [Limit Tag Sprawl](https://github.com/cloudsmith-io/rego-recipes/blob/main/README.md#recipe-5---restricting-package-based-on-tags)            | Flag any packages that have more than a threshold number of tags to avoid ungoverned tagging behaviours         |  Link  |
| Limit Package Size          | The goal of this policy is to prevent packages larger than 30MB from being accepted during the sync process     |  Link  |
| Time-Based CVSS Policy      | Evaluate CVEs older than 30 days. Checks CVSS threshold ≥ 7. Filters for a specific repo. Ignores certain CVE   |  [Link](https://play.openpolicyagent.org/p/dHSTerY2jn)  |
| CVSS with EPSS context      | Combines High scoring CVSS vulnerability with EPSS scoring context that go above a specific threshold.          |  Link  |
| Enforce Upload Time Window  | Allow uploads during business hours (9 AM – 5 PM UTC), to catch anomalous behaviour like late-night uploads     |  Link  |
| Enforce Consistent Filename | Validate whether the filename convention matches a semantic or naming pattern via Regular Expressions           |  Link  |


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

***

### Recipe 4 - Restricting Package Based on Tags
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
&& cloudsmith push python acme-corporation/acme-repo-one debugpy-1.8.14-cp310-cp310-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl -k "$CLOUDSMITH_API_KEY"
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
  "precedence": 2
}
EOF
```

Once ready, download ```transformers``` Python and assign it ```5 tags``` during the Cloudsmith push process to cause the policy violation:
```
pip download transformers --no-deps
cloudsmith push python acme-corporation/acme-repo-one transformers-4.53.1-py3-none-any.whl -k "$CLOUDSMITH_API_KEY" --tags TAG1,TAG2,TAG3,TAG4,TAG5
```
***
