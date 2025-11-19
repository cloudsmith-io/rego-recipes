# Cloudsmith Hugging Face EPM Recipes
A curated collection of Enterprise Policy Management (EPM) recipes for Hugging Face models/datasets.
<br/><br/>

Cloudsmith provides a customized data model for Hugging Face models and datasets. This means we can write policies that target attributes particular to this package type.

***

### Table of Rego Samples

|           Name              |                                        Description                                                              |  Rego Playground |
|         --------            |                                          -------                                                                |      -------     |
| [A whitelist of trusted publishers](https://github.com/cloudsmith-io/rego-recipes/tree/main/huggingface-recipes/README.md?#a-whitelist-of-trusted-publishers)   | This policy quarantines upstream models from untrusted publishers.    |  Link  |
| [Block models with unsafe files found via a security scan](https://github.com/cloudsmith-io/rego-recipes/tree/main/huggingface-recipes/README.md?#block-models-with-unsafe-files-found-via-a-security-scan)   | Use Hugging FaceHub security scan data to block unsafe models. |  Link  |
| [Policy based on model card data](https://github.com/cloudsmith-io/rego-recipes/tree/main/huggingface-recipes/README.md?#policy-based-on-model-card-data)   | A policy that makes use of model card data. |  Link  |
| [Block models with risky file formats](https://github.com/cloudsmith-io/rego-recipes/tree/main/huggingface-recipes/README.md?#block-models-with-risky-file-formats)   | This policy quarantines models with risky file types.  |  Link  |

***

### A whitelist of trusted publishers

On [Hugging Face Hub](https://huggingface.co) you will find many of the models/datasets are published by well-known companies such as Microsoft, Nvidia, Apple etc. As an organization you might decide that these packages are safe for your teams to use without further vetting. (Provided they meet your licensing requirements.)

One way to achieve this is to create a **terminal** policy that runs before any other policy (e.g. with a precedence of 0), sets the package state to 'AVAILABLE', and tags the package with 'trusted-publisher'.

Download the ```trusted_publishers.rego``` and create the associated ```payload.json``` with the below command:

```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/huggingface-recipes/trusted_publishers.rego
escaped_policy=$(jq -Rs . < trusted_publishers.rego)
cat <<EOF > payload.json
{
  "name": "Huggingface Trusted Publishers",
  "description": "A whitelist for models & datasets from trusted publishers on Hugging Face Hub.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": true,
  "precedence": 0
}
EOF
```

After the policy has been created, associate an action to SetPackageState to AVAILABLE and another action to tag the model with 'trusted-publisher'. Documentation on how to create an action programmatically can be found at: [Getting Started with Enterprise Policy Manager - Adding actions to a policy](https://docs.cloudsmith.com/supply-chain-security/epm/getting-started#step-3-adding-actions-to-a-policy).

Note, the policy in `trusted_publishers.rego` targets packages pulled via a Hugging Face upstream and ignores packages that are pushed directly into Cloudsmith. Packages pulled via a Cloudsmith upstream provide a reliable way to determine who published the model on Hugging Face Hub. Locally pushed packages do not have the same traceability. 

***

### Block models with unsafe files found via a security scan

For models that are pulled via a Hugging Face Hub upstream, Cloudsmith will fetch the public [security data](https://huggingface.co/docs/hub/security) that is available from the upstream.  Hugging Face Hub provides scan results from Clam AV, Pickle Scan, Protect AI and Jfrog. You can setup a policy that quarantines a model if any of the security data indicates the model is unsafe.

Download the ```security_scan.rego``` and create the associated ```payload.json``` with the below command:

```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/huggingface-recipes/security_scan.rego
escaped_policy=$(jq -Rs . < security_scan.rego)
cat <<EOF > payload.json
{
  "name": "Huggingface Hub Security Scan",
  "description": "Match models & datasets where the security scan data from Hugging Face Hub indicates unsafe content.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF
```

After the policy has been created, associate an Action with the Policy to SetPackageState to QUARANTINE.

If a package matches the policy, you can use the decision logs to view the detailed results of security scan for the package. The decision log will contain the full output of each scanner from Hugging Face.

***

### Policy based on Model Card data

Hugging Face models and datasets come with [Model Cards](https://huggingface.co/docs/hub/model-cards). Model Cards are metadata created by the publisher of a model to provide documentation and transparency about the characteristics of the model. Cloudsmith parses this information and exposes to EPM so you can write policies with this data.

Model Cards currently come in two forms. One for datasets and one for models. In EPM's [Open Api specification](https://api.cloudsmith.io/v2/swagger/#/workspaces), the types `PolicyHuggingfaceModelCard` and `PolicyHuggingfaceDatasetCard` describe what data these can contain.

As an example, Hugging Face publish a language model called [SmolLM-135M](https://huggingface.co/HuggingFaceTB/SmolLM-135M). If you visit the [README.md of the model](https://huggingface.co/HuggingFaceTB/SmolLM-135M/blob/main/README.md), you will see a 'metadata' section encoded in YAML that states the model was trained on the dataset 'HuggingFaceTB/smollm-corpus'. Perhaps you wish to block models that use this training set.

Download the ```model_card.rego``` and create the associated ```payload.json``` with the below command:

```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/huggingface-recipes/model_card.rego
escaped_policy=$(jq -Rs . < model_card.rego)
cat <<EOF > payload.json
{
  "name": "Huggingface Hub Model Card Training Set",
  "description": "Prohibit models trained with a smollm-corpus dataset.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF
```

***

### Block models with risky file formats

Many of the file formats used by models and datasets suffer from serialization attacks. For example, [Pickle](https://docs.python.org/3/library/pickle.html) is a popular file format used in Hugging Face models that has well-known exploits. Further, some formats, such as Keras can be securely deserialized but can come with embedded code extensions (e.g. keras lambda layer) that allow for arbitrary code execution. Alternative, safer model file-formats have been developed, such as [safetensors](https://github.com/huggingface/safetensors) from Hugging Face and [ONNX](https://onnx.ai) that do not suffer from these attacks. For background on these attack vectors [see here](https://github.com/protectai/modelscan/blob/main/docs/model_serialization_attacks.md).

The following policy will match models coming from Hugging Face Hub that contain risky formats, such as pickle-based formats or other files such as zips, pytorch, keras, and tensorflow h5 models. After the policy has been created, associate an Action with the Policy to SetPackageState to QUARANTINE.

Download the ```risky_files.rego``` and create the associated ```payload.json``` with the below command:

```
wget https://raw.githubusercontent.com/cloudsmith-io/rego-recipes/refs/heads/main/huggingface-recipes/risky_files.rego
escaped_policy=$(jq -Rs . < risky_files.rego)
cat <<EOF > payload.json
{
  "name": "Huggingface Hub Prohibited Formats",
  "description": "Prohibit models with risky file formats.",
  "rego": $escaped_policy,
  "enabled": true,
  "is_terminal": false,
  "precedence": 1
}
EOF
```

***
