AGENTS.md — Quarto Manual Lua Architecture

Purpose

Quarto Manual is a semantic extension of Quarto for writing structured, executable software operations manuals.

The source document expresses meaning, not presentation.

Current semantic fragment classes include:

* .manual-prereq
* .manual-procedure
* .manual-check

Additional Manual semantics may be introduced later. In particular, future versions may support interactive or agent-assisted workflows in which a fragment can expose actions such as evaluating, proposing, validating, or executing work.

The current task is to add visual treatment to existing Manual fragments using Quarto callouts.

Implement this without coupling Manual semantics to the current visual treatment.

The architecture must make it possible to add future interactive behavior without destructively rewriting the existing filter.

⸻

Architectural rule

Treat these as separate layers:

Manual source semantics
        ↓
semantic recognition / normalization
        ↓
Manual internal representation
        ↓
presentation transformation
        ↓
Quarto AST nodes
        ↓
format renderer

Do not collapse these into:

.manual-check → .callout-tip

A Manual fragment is not a callout.

A callout is one possible presentation of a Manual fragment.

This distinction is mandatory.

⸻

Current source contract

Authors should continue writing semantic Manual markup such as:

::: {.manual-prereq}
Required software and input files must exist.
:::
::: {.manual-procedure}
Run the analysis.
:::
::: {.manual-check}
Confirm that the expected output exists.
:::

These classes are the stable author-facing API.

Do not require authors to write Quarto callout classes.

Do not replace the semantic classes in source files with presentation classes.

Do not encode presentation choices into the authoring syntax unless explicitly required by the Manual specification.

⸻

Current presentation goal

For the present implementation, render the three existing fragment types with distinct Quarto-native visual treatments.

Use Quarto callouts where practical.

The initial mapping should live in one declarative configuration table rather than scattered conditional logic.

Conceptually:

local fragment_types = {
  prereq = {
    class = "manual-prereq",
    presentation = {
      kind = "callout",
      type = "...",
      title = "Prerequisites"
    }
  },
  procedure = {
    class = "manual-procedure",
    presentation = {
      kind = "callout",
      type = "...",
      title = "Procedure"
    }
  },
  check = {
    class = "manual-check",
    presentation = {
      kind = "callout",
      type = "...",
      title = "Check"
    }
  }
}

Choose the exact callout types, titles, icons, and appearance according to the current Manual design.

The important requirement is structural: changing the visual mapping later should require editing configuration or a renderer, not rewriting semantic recognition.

⸻

Use Quarto’s AST, not generated HTML

Prefer transformations at the Pandoc/Quarto AST level.

Quarto has a first-class Callout AST node and a quarto.Callout(...) constructor. Use that API where compatible with the supported Quarto version.

Do not generate Bootstrap callout HTML manually.

Do not depend on the current HTML DOM produced by Quarto.

Do not inject raw HTML solely to simulate a Quarto callout.

The Manual extension should remain capable of targeting formats other than HTML.

If a feature genuinely requires HTML-only behavior in the future, isolate that behavior behind a format-specific renderer or dependency rather than contaminating the semantic transformation.

⸻

Separate recognition from rendering

Implement fragment recognition independently of fragment presentation.

A useful structure would be conceptually similar to:

manual.lua
  ├── fragment recognition
  ├── semantic normalization
  └── dispatch
manual/
  ├── fragments.lua
  ├── presentation.lua
  ├── callouts.lua
  └── utilities.lua

The exact file organization can differ if the repository already has a clear convention.

The important separation is:

Recognition

Answers:

Is this AST node a Manual fragment, and what kind is it?

For example:

fragment.kind == "prereq"
fragment.kind == "procedure"
fragment.kind == "check"

Semantic representation

Carries information that describes the Manual fragment independently of how it will look.

Conceptually:

{
  kind = "check",
  content = ...,
  identifier = ...,
  classes = ...,
  attributes = ...
}

This does not need to become an elaborate class hierarchy.

A small Lua table is sufficient.

Presentation

Answers:

Given a recognized Manual fragment, how should it currently appear?

Today the answer may be a Quarto Callout.

Tomorrow the answer could additionally involve:

* an action button;
* execution status;
* agent controls;
* provenance information;
* collapsible execution history;
* validation state;
* an interactive widget;
* a custom Quarto AST node.

Those additions should not require changing how .manual-check is recognized.

⸻

Preserve semantic identity

Rendering a Manual fragment must not erase its Manual identity unnecessarily.

Where Quarto’s AST permits it, retain sufficient metadata for later processing to know that a rendered element originated as:

manual-prereq
manual-procedure
manual-check

Do not assume that a later filter should have to reverse-engineer this from the chosen callout color or type.

For example, never create a dependency like:

callout-note means prerequisite

That is presentation inference and is prohibited.

If a downstream stage needs the semantic type, preserve or attach explicit machine-readable metadata.

Examples could include a retained class or namespaced attribute, depending on what is safe at the relevant AST stage:

manual-prereq
data-manual-kind="prereq"

Prefer the smallest mechanism that survives the required Quarto processing stages.

Do not duplicate metadata without a reason.

⸻

Preserve author metadata

Manual fragments may acquire additional author-supplied metadata over time.

When transforming a fragment:

* preserve its identifier where possible;
* preserve unrelated classes;
* preserve unrelated attributes;
* preserve its content exactly unless the transformation explicitly concerns that content.

Do not rebuild Div attributes from scratch and silently discard information.

Avoid transformations such as:

div.classes = {"callout-note"}

when doing so destroys existing semantic or user metadata.

Transformation functions should be conservative.

⸻

Future interactive architecture

Assume that future Manual fragments may participate in human-agent workflows.

A future fragment might conceptually look like:

::: {.manual-procedure agent-evaluable="true"}
Implement the operation described here.
:::

or there may eventually be a dedicated semantic fragment such as:

::: {.manual-agent}
...
:::

Do not implement those features now unless explicitly requested.

However, today’s architecture must leave room for them.

Future functionality may need to attach behavior to an existing semantic fragment such as:

manual-procedure
        │
        ├── presentation: Procedure callout
        │
        └── interaction: "Let agent evaluate"

This is another reason that the semantic node must not become synonymous with its callout representation.

Interactive behavior should eventually be implemented as another layer or transformation over Manual semantics, not embedded inside the basic callout conversion.

Conceptually:

             ┌── visual presentation
Manual node ─┼── interaction
             ├── validation
             └── provenance

not:

Manual node → callout → somehow retrofit everything onto callout

⸻

Keep behavior separate from styling

CSS is responsible for appearance.

Lua is responsible for semantic AST transformation.

JavaScript, if eventually required, should be responsible for browser-side interaction.

Do not use Lua to emit large amounts of styling.

Do not use CSS classes as the sole source of semantic truth for runtime behavior.

Do not add JavaScript for the current purely visual task unless it is actually required.

When interactive functionality arrives, add JS dependencies through Quarto’s supported extension/dependency mechanisms.

⸻

Minimize assumptions about future agent systems

Do not currently hard-code:

* Codex-specific behavior;
* Claude-specific behavior;
* MCP server names;
* model names;
* prompt formats;
* tool permissions;
* agent runtimes.

The Manual semantic layer should describe the operation, not the implementation of a particular AI provider.

A future agent integration should be able to consume Manual semantics through a separate adapter.

For example:

Manual semantics
      ↓
agent adapter
      ↓
Codex / Claude / other runner

The callout renderer should know nothing about this.

⸻

Idempotence

The transformation must be safe against accidental repeated application.

A fragment that has already been converted into its presentation form must not acquire nested callouts or duplicated metadata if the filter encounters it again.

Design an explicit way of distinguishing:

unprocessed Manual fragment

from:

Manual fragment whose presentation has already been produced

Prefer structural/semantic detection over fragile string matching.

⸻

Fail conservatively

Unknown Manual classes or future Manual fragment types should not cause rendering to fail.

For example, if a future source contains:

::: {.manual-agent}
...
:::

and the installed extension does not yet understand it, preserve the Div and its contents rather than deleting it, coercing it to an unrelated type, or throwing an avoidable error.

Only transform fragment types that this version explicitly supports.

This is important for forward compatibility.

⸻

Processing phases

Be deliberate about where the filter runs in Quarto’s AST lifecycle.

Quarto provides distinct AST processing phases.

Choose the earliest phase at which Manual semantics can be reliably recognized and transformed into the required Quarto-native representation, while leaving later Quarto processing intact.

Do not depend accidentally on whatever happens to be the default filter ordering.

Document the chosen phase and why it is appropriate.

If recognition and rendering eventually need different phases, split them rather than forcing both into one pass.

⸻

Small functions

Prefer small functions with single responsibilities.

For example, functions conceptually equivalent to:

manual_fragment_kind(div)
normalize_manual_fragment(div, kind)
presentation_for(fragment)
render_callout(fragment, presentation)

are preferable to one large Div() function containing all recognition, configuration, mutation, styling, and format behavior.

Avoid deeply nested chains such as:

if div.classes:includes(...) then
  if FORMAT == ... then
    if attr == ... then
      ...

Use dispatch tables and helpers instead.

⸻

Avoid premature frameworks

Do not build a generalized plugin system merely because future features are anticipated.

We need seams, not speculative infrastructure.

The implementation should remain small.

Good forward-compatible design means:

* semantic recognition is isolated;
* transformations are composable;
* mappings are declarative;
* metadata is preserved;
* presentation is replaceable;
* unknown semantics survive untouched.

It does not mean creating abstractions without a current use.

⸻

Testing requirements

Add focused fixtures/tests for each current fragment type.

At minimum verify:

1. .manual-prereq renders using its intended presentation.
2. .manual-procedure renders using its intended presentation.
3. .manual-check renders using its intended presentation.
4. Fragment body content is preserved.
5. Identifiers survive where supported.
6. Additional classes/attributes are not silently lost.
7. Ordinary Divs are unchanged.
8. Ordinary author-written Quarto callouts are unchanged.
9. Unknown .manual-* fragment types survive unchanged.
10. Reapplying the relevant transformation does not create nested/duplicated presentation.
11. A document containing all supported fragment types renders successfully through Quarto.

Where feasible, test AST structure rather than only doing brittle string comparisons against generated HTML.

Rendered integration tests may additionally verify user-visible behavior.

⸻

Current implementation priority

For this change, work in this order:

1. Inspect the existing Manual extension and understand the present fragment transformation.
2. Establish or preserve a clean semantic-recognition boundary.
3. Implement a centralized presentation specification for:
    * prerequisite;
    * procedure;
    * check.
4. Render those presentations using Quarto-native callout functionality.
5. Preserve Manual semantic identity and author metadata where appropriate.
6. Add tests for transformation and rendering.
7. Render representative Manual pages and inspect the result.
8. Refactor only as much as necessary to establish the boundaries above.

Do not implement agent execution, buttons, MCP integration, or other future interaction in this change.

⸻

Definition of done

This work is complete when:

* the current three Manual fragment types have intentional, distinct visual treatment;
* authors continue to write semantic .manual-* markup;
* the visual mapping is centralized and easily replaceable;
* ordinary Quarto behavior is not disturbed;
* metadata and content are preserved;
* the implementation is small, readable, and tested;
* no current code assumes that a Manual fragment is a callout;
* a future developer can add another behavior to manual-procedure or manual-check without dismantling the callout implementation.

Before finalizing the implementation, explicitly report:

1. where Manual semantics are recognized;
2. where presentation mappings are defined;
3. where Quarto Callout nodes are created;
4. what semantic metadata survives the transformation;
5. which tests protect the extension point for future interactive behavior.
