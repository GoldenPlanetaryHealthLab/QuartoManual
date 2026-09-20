# Quarto Manuals

## Executable operator manuals for reproducible scientific workflows

**Tinashe M. Tapera, Michelle Audirac, Danielle Braun, Christopher Golden**

## The problem

Scientific software workflows are often too complex for a README and too
judgment-heavy to hide behind a single command. They depend on local
platforms, configuration, versions, permissions, and ordered state changes.
Documentation may adequately describe the _intended_ workflow but not show whether the
current state is safe to proceed, what decision was made, or how success can be
verified.

This creates a practical gap between *knowing what a workflow is* and *being
able to operate it reproducibly*.

## Our approach

Quarto Manuals are executable operations manuals built from highly structured and independent Quarto
pages. They are written for competent operators in a relevant domain—not as
general tutorials—and make operational boundaries clearly visible:

- required inputs and preconditions;
- actions and consequential operator choices;
- observable artifacts and state transitions;
- checks that establish whether the next page is allowed to run.

The rendered manual is a readable documentation artifact. The source page
remains the operational record: text, code, decisions, outputs, and checks stay
together and can be edited by the people responsible for the workflow.

## The page contract

Each operational page has three required parts:

### Prerequisite

Prove that the page is allowed to run. Check visible project state such as
files, directories, tools, configuration, or the result of an earlier test.

### Procedure

Perform one bounded operational transformation. Automate mechanical substeps,
but keep meaningful choices and execution boundaries visible to the operator.

### Check

Prove that the intended state or artifact now exists. A successful command is
not, by itself, evidence that the workflow succeeded.

**Design rule:** exactly one prerequisite, one or more procedures, and exactly
one check per page.

`manual.page` plus the Quarto Manual extension renders these blocks as
semantic callouts. An optional `manual-explain` block supplies short context
only when an operation is unusual, easy to misinterpret, or correctness-critical.

## Three examples, one operating model

### Simple: stage data

Move from an external or shared data location to a project-owned working state.
The manual makes paths, links, and resulting files inspectable.

### Intermediate: aggregate environmental data

Coordinate an ERA5 acquisition and aggregation workflow across Python and R.
The manual exposes credentials, job boundaries, generated artifacts, and the
handoff between stages.

### Advanced: build an RSE workbench

Construct and validate a reproducible, containerized geospatial development
environment on an HPC system. The manual makes platform, scheduler, package,
activation, and validation boundaries explicit.

The examples become more operationally complex; they do not become more
explanatory. A mature manual can be concise when reliable automation absorbs
mechanical work without hiding decisions or checks.

## What is implemented in this project

- A Quarto Manual extension that gives pages semantic prerequisite, procedure,
  check, and exceptional-explanation blocks.
- A site with three examples spanning data staging, geospatial aggregation, and
  HPC environment construction.
- Normalized advanced RSE pages: all 15 operational pages satisfy the page
  contract without expanding their underlying scope.
- `quarto-emit` integration for materializing conventional project artifacts
  such as source files, tests, scripts, and configuration when a workflow needs
  them.
- Explicit site rendering and structural auditing so documentation validation
  is separate from claims about physical devices, external services, or
  scientific results.

## Why this matters

Quarto Manuals provide a reproducible handoff: the smallest reliable sequence
of actions that leaves visible artifacts and confirms progress throughout
execution. They preserve the operator’s authority where local constraints and
scientific judgment shape the workflow, while still making repeatable work
mechanical and inspectable.

This makes them useful for research software and climate-smart public health
workflows, where heterogeneous data, changing computing environments, and
collaboration across local settings make operational clarity part of
reproducibility.

## Boundaries and next steps

Quarto Manuals are best for ordered, operator-facing procedures with local
state and visible verification points. When dependencies become highly
non-linear, a workflow orchestrator such as Snakemake or Nextflow may own the
graph, with the Manual providing the operator-facing entry point and checks.

Next steps include improving the user on-ramp, adding a visual overview,
strengthening misuse feedback, and evaluating how transparent manual pages can
support human oversight of AI-assisted software development.

## Find the project

Examples and authoring guidance:

<https://goldenplanetaryhealthlab.github.io/QuartoManual/>

## Suggested poster footer

**Quarto Manuals keep workflow decisions, state transitions, artifacts, and
verification visible—so reproducible execution remains understandable and
human-authoritative.**

---

## Editorial notes for the Quarto source

- Replace the current Typst template/demo blocks with the sections above.
- Use the page contract as the central visual: `prerequisite → procedure →
  check`, with visible artifacts between pages.
- Keep the examples in a three-column progression: simple, intermediate,
  advanced.
- Treat the validation bullets as project evidence, not as claims that the
  poster itself has been rendered or that external scientific workflows have
  been validated.
- Keep accepted publication sources unchanged; integrate this draft manually
  into `pubs/usrse2026/poster.qmd` after deciding on layout and references.
