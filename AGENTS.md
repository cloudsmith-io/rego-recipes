# Guidelines

These build on the [Rego Style Guide](https://www.openpolicyagent.org/docs/style-guide), which also applies.
Where a guideline comes from there, the section title is noted in brackets.

Every policy evaluates one package against `input.v0` and produces two results: `match`, a boolean
saying whether the policy fired, and `reason`, a set of messages explaining why.

## Structure

* Always declare `default match := false`. If `match` ends up undefined, it falls back to false instead of returning nothing.
* Don't have `match` dependent on `reason`, e.g. avoid `match if count(reason) > 0`. A mistake in a message string then stops the policy matching at all. Work `match` out from the conditions themselves and let `reason` depend on `match`.
* Write `reason` with `contains`. `reason[msg] if { ... }` looks similar but produces an object keyed by the message rather than a set of messages.
* Put the value in the rule head: `reason contains sprintf(...) if match`. Only where that pushes the line past 120 characters, assign `msg` in the body instead, which is a departure from the style guide. (Style guide: "Prefer unconditional assignment in rule head over rule body")
* If a policy can fire in more than one way, give each condition its own named rule, and let `match` and `reason` both use it rather than repeating the condition. (Style guide: "Use helper rules and functions")
* Keep the policy self documenting. Comment only what a reader could not work out from the code, such as the units of a threshold.

## Reason message

* Name the value that triggered the policy, and the threshold it crossed if there is one, so a reader can see why it fired without going back through the package data.
* Only name a value if it tells the reader something on its own. A CVSS score does. A list of vulnerability IDs does not, because the reader has to look each one up, and the decision log and web app already have them.
* Never build a message inside an iteration. You get one message per finding, and the decision log grows with them. A policy that fires two different ways can have two messages, because that number does not grow.
* Where the values are ordered, give the highest one rather than everything above the threshold.
* Where they are not ordered, list what matched. Opt for a shorter type of list if it's likely to be long, such as grouping by category.
* Accept reading the whole collection in order to name what matched. Stopping at the first match only saves work on packages that match, and most packages do not.

## Cost

* Use a set and `in` when asking whether something is in a list. That is a hash lookup and the size of the set does not matter. Use a map when each entry needs a value attached, such as a minimum version per package. (Style guide: "Use `in` to check for membership", "Prefer sets over arrays (where applicable)")
* Read a collection from the input once, into a single rule, then take your counts and checks from that rule rather than from the input again. Two rules that both scan `input.v0.osv` read it twice; one rule that collects what you need and two that read the result reads it once.
* If you only need to know whether something exists, do not count, just stop at the first match. The exception is when you need the value for the message.
* Avoid putting one loop inside another when the two are unrelated, because the body then runs once for every combination. Give each its own helper rule so they iterate independently.
* Put the cheapest, most selective check first in a rule body. Rego works down the body in order and abandons it at the first line that fails.

## Undefined

A field that is missing is undefined rather than false, and an undefined line stops the rule where it stands. The rule produces nothing, `match` falls back to its `false` default, and the policy quietly does not fire. Nothing errors, so there is no sign anything went wrong.

* Do not write `!= null` guards to protect against a missing field. Rego already stops the body when a field is absent, so the guard adds nothing.
* Write `not x == y` rather than `x != y` when the field may be missing. `x != y` goes undefined along with the field, so the check never fires. `not x == y` succeeds. (Style guide: "Use negation to handle undefined")
* Move the check into its own rule when it is more than a single comparison, then negate the rule. `not` cannot wrap two conditions inline, and negating a rule that went undefined still succeeds.

  ```rego
  scan_clean if {
      input.availability == "COMPLETE"
      input.summary == "SAFE"
  }

  match if not scan_clean
  ```

  Written as two separate checks against the input, a package missing `availability` entirely would slip through, which is the opposite of what the policy is for.

* Give a builtin call its own rule before negating it. A builtin has to be handed a value, so when the field is absent the call never runs and the line fails before the `not` applies. `not semver.is_valid(pkg.version)` therefore does not catch a missing version, and nor does `not x in y`, since `in` is a builtin call underneath.

  ```rego
  valid_version if semver.is_valid(pkg.version)

  match if not valid_version
  ```

* Watch for missing fields inside an iteration. The item is skipped rather than flagged, so a check over a list can cover fewer items than it appears to.
* For a true "all of these", use `every`, and put `count(...) > 0` on the line above it. Without that guard, a missing list makes the rule undefined and an empty one makes it trivially true. (Style guide: "Use `every` to express FOR ALL")
* Decide what should happen when a builtin cannot read its input. `semver.compare` and `time.parse_rfc3339_ns` go undefined rather than erroring, so a malformed value looks the same as a missing one and the policy does not fire.

## Consistency

* Follow what the existing policies do, using the same names for the same things and the same overall shape.
* No `import rego.v1`. OPA 1.x already evaluates as v1, so the import does nothing.
* snake_case for rule names and variables. (Style guide: "Prefer snake_case for rule names and variables")
* Do not leave a comprehension inside a rule body, give it its own rule. (Style guide: "Consider partial helper rules over comprehensions in rule bodies")
* Prefer `some x in y` over `x[_]` for a single level of iteration. From two levels down, `x[_].y[_]` is clearer than naming every intermediate, and that is where Regal stops flagging it (`prefer-some-in-iteration` defaults to `ignore-nesting-level: 2`). (Style guide: "Prefer `some .. in` for iteration")
* Use `:=` to assign and `==` to compare. `=` can mean either, so it hides which one you meant. (Style guide: "Don't use unification operator for assignment or comparison")
* Backtick raw strings for regex patterns, so you are not double escaping. (Style guide: "Use raw strings for regex patterns")
* Plain string functions (`contains`, `startswith`, `endswith`) when not matching structure. Regex only when position or pattern actually matters.
* Use current builtins. `regex.match`, not the deprecated `re_match`.

## Validation

* Confirm a field exists before writing a policy against it. A field that is not really there is just undefined, so the policy quietly never fires, and the tests will not catch it either, because a test cannot tell a wrong field name from an absent one.
* Check field types and ranges against real data before relying on them. A number that is really a string, or a 0 to 1 value that is really 0 to 100, will make a policy fire on everything or nothing with no visible error.
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
