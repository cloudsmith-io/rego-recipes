# Guidelines

These build on the [Rego Style Guide](https://www.openpolicyagent.org/docs/style-guide), which also applies.
Where a guideline comes from there, the section title is noted in brackets.

Every policy evaluates one package against `input.v0` and produces two results: `match`, a boolean
saying whether the policy actions apply, and `reason`, a set of messages explaining why.

## Structure

* Always declare `default match := false`. If `match` ends up undefined, it falls back to false instead of returning nothing.
* Don't have `match` dependent on `reason`, e.g. avoid `match if count(reason) > 0`. An undefined message string would stop the policy matching. Work `match` out from the conditions themselves and let `reason` depend on `match`.
* Write `reason` with `contains` (a partial set). `reason[msg] if { ... }` produces an object keyed by the message rather than a set of messages.
* Put the value in the rule head: `reason contains sprintf(...) if match`. Only where that pushes the line past 120 characters, assign `msg` in the body instead. (Style guide: "Prefer unconditional assignment in rule head over rule body", "Keep line length `<=` 120 characters")
* If a policy can match in more than one way, give each condition its own named rule, and let `match` and `reason` both use it rather than repeating the condition. (Style guide: "Use helper rules and functions")
* Keep the policy self-documenting. Comment only what a reader could not work out from the code, such as the units of a threshold.

## Reason message

* Name the value that triggered the policy, and the threshold it crossed if there is one, so a reader can see why it matched without going back through the input data.
* Only name a value if it tells the reader something on its own. A CVSS score does, but a list of vulnerability IDs does not, because the reader has to look each one up, and the decision log and web app already have them.
* Do not build a message per result inside an iteration, so that the decision log does not grow large. Output a top-level message instead. A fixed number of messages is fine where the policy can match in more than one way.
* Opt for a shorter type of list if it's likely to be long. For example, where the values are ordered, give the highest one rather than everything above the threshold. Where they are not ordered, list what matched, perhaps summarizing by a category to reduce the length.
* Accept reading the whole collection in order to name what matched. Stopping at the first match only saves work on packages that match, and most packages do not.

## Cost

Generally, write for readability first and only reach for these when a policy is actually slow.
(Style guide: "Optimize for readability, not performance")

* Use a set and `in` to ask whether something is in a list. This is an O(1) hash lookup, compared to an O(n) scan. Use a map when each entry needs a value attached, such as a minimum version per package. (Style guide: "Use `in` to check for membership", "Prefer sets over arrays (where applicable)")
* To match on several fields at once, join them into one string with `sprintf` and look that up, rather than comparing field by field. `allowlist.rego` builds `python:example-lib:1.2.3` and checks it against a set written the same way.
* Do not iterate two unrelated collections in the same rule body, because Rego runs the body once for every pair of items and the cost is the two lengths multiplied rather than added. Give each collection its own helper rule so they iterate separately.
* Put the cheapest, most selective check first in a rule body. Rego runs the lines in order and stops at the first one that fails, so anything below it never runs.
* If you only need to know whether something exists, let the rule stop at the first match rather than collecting everything and counting it. The exception is when you need the value for the reason message, which most policies do.

## Undefined

A missing field is undefined, as is a builtin that cannot parse what it is given, such as `semver.compare` on an invalid version. A rule reading an undefined value becomes undefined too, so `match` never gets a value and falls back to the `default match := false`.

A rule that matches on a field holding a particular value is fine, since a missing field leaves nothing to match. The risk is a rule that uses `not`, where a missing field is often the case it most needs to catch. Silently missing it is a fail open wherever matching blocks the package. Whether the missing field is caught depends on the form:

| written as                              | when the field is missing |
|-----------------------------------------| --- |
| `not pkg.foo`                           | true |
| `not pkg.foo == "bar"`                  | true |
| `not foo_bar`, a rule                   | true |
| `pkg.foo != "bar"`                      | undefined |
| `not pkg.foo > 5`, and `<`, `>=`, `<=`  | undefined |
| `not pkg.foo in bar`                    | undefined |
| `not count(pkg.foo) == 0`               | undefined |
| `not foo(pkg.bar)`, builtin or your own | undefined |

* Where the field is optional, use one of the forms that comes out true. Give anything else its own rule and negate the rule, since an undefined rule negates to true. (Style guide: "Use negation to handle undefined")
* Do not write `!= null` guards against a missing field. A missing field already makes the line undefined, so the guard adds nothing.
* Use a form that comes out true when collecting the items that violate something. In a partial rule or a comprehension, an undefined form excludes only that item and the rest of the set is still built. That works fine if you're only gathering all the values that exist, but can silently omit an item with an undefined value if you're checking for those that do not match something particular.
* Use `every` for "all of these", and guard it with `count(...) > 0` on the line above where an empty list should not count as all, since `every` is true over one. Where an undefined list should count as satisfying the check, use a negated helper rule instead. (Style guide: "Use `every` to express FOR ALL")

## Consistency

* Follow what the existing policies do, using the same names for the same things and the same overall shape.
* No `import rego.v1`. OPA 1.x already evaluates as v1, so the import does nothing.
* Use snake_case for rule names and variables. (Style guide: "Prefer snake_case for rule names and variables")
* Do not leave a comprehension inside a rule body, give it its own rule. (Style guide: "Consider partial helper rules over comprehensions in rule bodies")
* Prefer `some x in y` over `x[_]` for a single level of iteration. From two levels down, `x[_].y[_]` is clearer than naming every intermediate, and that is where Regal stops flagging it (`prefer-some-in-iteration` defaults to `ignore-nesting-level: 2`). (Style guide: "Prefer `some .. in` for iteration")
* Use `:=` to assign and `==` to compare. `=` can mean either, so it hides which one you meant. (Style guide: "Don't use unification operator for assignment or comparison")
* Backtick raw strings for regex patterns, so you are not double escaping. (Style guide: "Use raw strings for regex patterns")
* Use plain string functions (`contains`, `startswith`, `endswith`) when not matching structure, and regex only when position or pattern actually matters.
* Use current builtins, such as `regex.match` rather than the deprecated `re_match`.

## Validation

* Confirm a field exists before writing a policy against it. A missing field can lead to `match` becoming undefined.
* Check field types and ranges against real data before relying on them. A number that is really a string, or a 0 to 1 value that is really 0 to 100, will make a policy match everything or nothing with no visible error.
* Write test cases where optional fields are missing. Nothing errors when one is, so a test is the only way to find out what the policy actually does.
* Run `opa fmt --write`, `opa check --strict` and `regal lint` before opening a PR. (Style guide: "Use strict mode")

---

# Policy METADATA
(Style guide: "Use metadata annotations")

- All new policies (and any existing policies you modify) should include METADATA comments at the top of the file
- Place METADATA before the `package` declaration

```rego
# METADATA
# title: <Display Title>
# description: <Brief description of what the policy does>
package cloudsmith
```

- `title`: short, human-readable display name in sentence case (e.g. "Malware block")
- `description`: one-line summary of policy behaviour (e.g. "Block packages with detected malware vulnerabilities")
- Follow the OPA METADATA annotations format: https://www.openpolicyagent.org/docs/policy-language#metadata

# Running the tests

Each test file mirrors the policy it covers: `tests/<group>/<name>_test.rego` tests
`recipes/<group>/<name>.rego`. Every policy uses `package cloudsmith`, so they cannot be
compiled together. Load one policy at a time alongside its test:

```bash
opa test recipes/vulnerability/malware.rego tests/vulnerability/malware_test.rego
```
