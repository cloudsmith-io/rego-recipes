# Cloudsmith Huggingface EPM Recipes
A curated collection of Enterprise Policy Management (EPM) recipes for Cloudsmith Huggingface models/datasets.
<br/><br/>

These recipes are designed to be modular, auditable, and production-ready - with a strong emphasis on policy-as-code best practices.

***

### Table of Rego Samples

|           Name              |                                        Description                                                              |  Rego Playground |
|         --------            |                                          -------                                                                |      -------     |
| [Enforcing Signed Packages](https://github.com/cloudsmith-io/rego-recipes?tab=readme-ov-file#recipe-1---enforcing-signed-packages)   | This policy enforces mandatory ```GPG/DSA signature``` checks on packages during their sync/import into Cloudsmith    |  Link  |

***

### A whitelist of Trusted Publishers

If the package comes from an upstream, block it unless it's on the approved publishers list.
Setup as the policy with an action to QUARANTINE and tag 'untrusted-publisher'.

Download the ```upstream_verified.rego``` and create the associated ```payload.json``` with the below command:
```
TODO
```

***

### Block models that have copyleft licenses or have no license.

Download the ```unknown_or_copyleft_licenses.rego``` and create the associated ```payload.json``` with the below command:
```
TODO
```

***

### Block models with risky file types in it

Block any upstream huggingface package that has risky files in it, particularly pickle or other
risky files like zips, pytorch, keras, and tensorflow h5 models.
Setup with an action to QUARANTINE if the policy matches.
Potentially combine with the whitelist policy to add exceptions to packages as your team see's fit.
package cloudsmith 

Download the ```risky_files.rego``` and create the associated ```payload.json``` with the below command:
```
TODO
```

***

### A whitelist for particular models - as an override to prior policies.

A final policy that acts as a whitelist or exception-based policy. The prior policies
might have quarantined the package but you want to encode some known exceptions.
Setup this policy with as terminal and with the action ALLOW and an action to tag the
package as 'whitelisted'

Download the ```whitelisted_pkgs.rego``` and create the associated ```payload.json``` with the below command:
```
TODO
```

***
