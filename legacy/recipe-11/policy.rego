package cloudsmith

default match := false

match if count(reason) > 0

reason contains msg if {
  some arch in input.v0.package.architectures
  arch.name != "amd64"
  msg := sprintf("Architecture '%s' is not permitted. Only 'amd64' is allowed.", [arch.name])
}
