# Quarto Manual

**Status:** early prototype / private coauthor review  
**Audience:** potential coauthors, research software engineers, data managers, scientific programmers, and collaborators interested in reproducible research computing workflows.

This repository introduces **Quarto Manuals**: interactive, executable software manuals for setting up and operating research computing projects.

A Quarto Manual is a structured, multi-document Quarto template. It contains ordered, executable `.qmd` pages, workflow-specific helper libraries, page-level tests, and a final readiness checklist.

The framework is general. The examples in this repository are concrete implementations of the framework:

1. a manual for staging input data with symlinks;
2. a manual for preparing an ERA5 data processing workflow;
3. a manual for creating a reproducible Singularity/Apptainer environment.

Each example demonstrates a different level of complexity.

The goal is not to replace READMEs, CLIs, package managers, workflow engines, or containers. The goal is to provide a structured manual layer that helps users assemble those tools into a working project.

A README explains a procedure.  
A wrapper hides a procedure.  
A Quarto Manual walks the user through a procedure, lets them modify it, exports the necessary setup files, and tests whether each step is complete.

---

## Current status

This project is not stable yet.

The repository is currently intended for coauthor review. It is deliberately plain text so that reviewers can open the folders, read the `.qmd` pages, and see how the proposed framework works.

At this stage, please do not evaluate the repository as a finished tool. Evaluate it as a prototype of a pattern:

> Can interactive, executable software manuals improve how we set up, teach, inspect, and hand off research computing projects?

Folder names, page names, CLI commands, helper libraries, and export mechanics may change.

---

## The central idea

A Quarto Manual is a **multi-page executable template**.

It is similar to a normal Quarto starter template, but with a stricter internal structure. Quarto starter templates already provide a way to give users initial project content, and they can be used to provide the starting content for custom project types. Quarto project types can also bundle project-level behavior through an extension. This makes Quarto a natural home for this pattern. ([Quarto](https://quarto.org/docs/extensions/starter-templates.html?utm_source=chatgpt.com))

A normal template gives a user a starting project skeleton.

A Quarto Manual gives a user an interactive manual that helps them generate, modify, and verify a project skeleton.

In other words:

```text
quarto use template frontier/rse-workbench
```

would create a manual instance. The user then steps through the manual pages. Those pages generate or check the files needed for a concrete research project, such as an ERA5 data processing workflow.

This is a two-stage generator model:

```text
Quarto starter template
  -> creates an editable manual instance
      -> manual pages generate and check a research project
```

The manual is not the final scientific project. The manual is the operating procedure that prepares the project to run.

---

## Why this project exists

Many research computing projects stall not because the scientific question is unclear, but because setup knowledge is scattered across:

- individual memory;
- READMEs;
- shell history;
- notebooks;
- informal handoff conversations;
- cluster-specific assumptions;
- package manager state;
- Slurm scripts;
- container recipes;
- data access conventions;
- configuration files.

Typical questions include:

- Where should the project live?
- Which files and software libraries are project-owned?
- Which data are inputs versus generated artifacts?
- Which dependencies belong in Python, R, modules, conda, Spack, or a container?
- Which setup steps must happen before others?
- Which scripts should run locally versus on Slurm?
- How do we know the project is ready to run?
- How does a second person reproduce the setup later?

Good documentation is still essential. A README works well when setup is short, linear, stable, and mostly copy-pasteable.

But once setup becomes order-dependent, project-specific, and testable, prose documentation alone has diminishing returns. As documentation grows into a long handbook, readers are more likely to skip ahead, miss prerequisites, or silently adapt steps in ways that break later assumptions.

A Quarto Manual treats setup more like assembling a complex object. Each page is a bounded assembly step. It begins by discovering the current project state, guides the user through a setup task, exports or modifies files, and ends by running a test that checks whether the step is complete.

---

## The flight manual analogy

The desired output of a Quarto Manual is not the final scientific result.

A flight manual does not fly the plane from A to B. It checks that the aircraft, instruments, route, fuel, communications, and safety procedures are ready. The pilot still flies the plane.

Similarly, a Quarto Manual does not replace the scientific project. It checks that the project’s setup and execution tools are ready:

- inputs are declared;
- paths are correct;
- dependencies are explicit;
- scripts exist;
- environments activate;
- runtime assumptions are visible;
- tests pass;
- the final checklist is complete.

The researcher still does the science.

---

## How to read this repository

If you are reviewing this as a potential coauthor, start by reading the repository as a prototype of a framework.

Suggested reading order:

1. Read this `README.md`.
2. Open `templates/01_stagecoach_symlink_input/`.
3. Read the `.qmd` pages in order.
4. Look at the matching `tests/` files.
5. Look at the workflow-specific `src/` or helper library folder.
6. Repeat for `templates/02_era5_pipeline/`.
7. Repeat for `templates/03_reproducible_singularity_environment/`.
8. Inspect `_extensions/quarto-manual/` to see how rendering and export behavior are intended to work.
9. Open `examples/` last. That folder represents what a completed project might look like after a user operates a manual.

As you read, ask:

- Does each page have a clear purpose?
- Does each page begin by discovering project state?
- Does each page end with a concrete inspection?
- Are the generated artifacts understandable?
- Could a user modify this page safely?
- What assumptions should be made explicit?
- What should remain site-specific?
- What should become reusable library code?

---

## Repository tour

The planned structure is:

```text
quarto-manual/
├── README.md
├── _quarto.yml
├── _extensions/
│   └── quarto-manual/
├── src/
│   └── quarto_manual/
├── templates/
│   ├── 01_stagecoach_symlink_input/
│   ├── 02_era5_pipeline/
│   └── 03_reproducible_singularity_environment/
└── examples/
    ├── stagecoach_input_project/
    ├── era5_processing_project/
    └── singularity_environment_project/
```

Each folder has a distinct role.

---

## `_quarto.yml`

This defines the root Quarto project for the repository.

The rendered site or book is useful for review, but the `.qmd` files remain the source of truth. The main value of this repository is not the rendered website. The main value is that the same `.qmd` pages can explain, execute, export, and test setup behavior.

---

## `_extensions/quarto-manual/`

This folder contains the planned Quarto extension machinery.

```text
_extensions/quarto-manual/
├── _extension.yml
├── manual.lua
├── manual-export.lua
└── theme.scss
```

### `_extension.yml`

Defines the Quarto extension.

The long-term goal is for a Quarto Manual to behave like a custom Quarto project type or starter template pattern: a project designed specifically for guided, testable workflow assembly.

### `manual.lua`

A rendering filter.

This should eventually style manual blocks such as:

- What you need
- Assemble
- Inspect
- Do not proceed
- Completed checklist

This filter is for presentation. It should not own project state.

### `manual-export.lua`

An export filter.

This is where the manual becomes more than documentation. The export filter should read structured blocks from `.qmd` pages and write conventional files into the target project, such as:

- Python modules;
- R scripts;
- shell scripts;
- Slurm scripts;
- YAML/TOML configs;
- pytest/testthat files.

The important design decision is that export should rely on Quarto/Pandoc parsing rather than a custom Markdown parser. Quarto filters operate by transforming the Pandoc abstract syntax tree, and Quarto supports Lua filters as part of its extension system. ([Quarto](https://quarto.org/docs/extensions/filters.html?utm_source=chatgpt.com))

### `theme.scss`

Manual-specific styling.

This should make rendered pages feel like an instruction booklet rather than a generic documentation site.

---

## `src/quarto_manual/`

This folder contains shared framework machinery.

```text
src/quarto_manual/
├── project.py
├── checks.py
└── export.py
```

### `project.py`

Defines the central project object.

The project object should be a small dataclass that can discover the current project state from the filesystem and `manual.yml`.

Its job is to answer questions such as:

- What is the project root?
- What is the project name?
- Where are the pages?
- Where are the tests?
- Where are the data folders?
- Which template created this project?
- Which variables have been declared?

It should stay boring, explicit, and inspectable.

It should not become a hidden workflow engine or private progress database.

### `checks.py`

Shared inspection helpers.

Examples:

```python
expect_file(path)
expect_dir(path)
expect_symlink(path)
expect_command_succeeds(command)
expect_yaml_key(path, key)
```

These helpers are not the workflow. They are reusable inspection tools that page-level tests can call.

### `export.py`

A thin Python layer around the manual export behavior.

This may eventually support commands such as:

```bash
quarto-manual export .
quarto-manual test .
quarto-manual render .
```

The CLI should remain small. It should coordinate Quarto, export behavior, and tests rather than becoming a large custom workflow engine.

---

## `templates/`

This is the most important folder conceptually.

Each folder in `templates/` is an example Quarto Manual implementation.

```text
templates/
├── 01_stagecoach_symlink_input/
├── 02_era5_pipeline/
└── 03_reproducible_singularity_environment/
```

Each template is a multi-page manual. It contains ordered `.qmd` pages, helper code, tests, and a final checklist.

The three templates are arranged by increasing complexity.

---

## Template 1: `01_stagecoach_symlink_input/`

This is the smallest manual.

Purpose:

> Connect an existing registered input dataset into a project workspace using a controlled symlink workflow.

This manual demonstrates the minimum useful pattern:

- discover project state;
- declare input;
- create symlink;
- test symlink;
- complete checklist.

Expected pages:

```text
pages/
├── 00_before_you_start.qmd
├── 01_declare_input.qmd
├── 02_create_symlink.qmd
└── 03_completed_checklist.qmd
```

This manual should produce setup evidence, not derived scientific results.

The final checklist should say:

```text
[x] input declared
[x] symlink created
[x] symlink target exists
[x] project can read input
```

The desired output is:

> This project is correctly wired to its input data.

Not:

> The analysis is complete.

This is an appropriate first example because it is small, concrete, and easy to inspect.

---

## Template 2: `02_era5_pipeline/`

This is a medium-complexity manual.

Purpose:

> Assemble the setup and execution tools needed to run an ERA5 data acquisition or processing pipeline.

Expected pages:

```text
pages/
├── 00_before_you_start.qmd
├── 01_project_contract.qmd
├── 02_request_spec.qmd
├── 03_pipeline_skeleton.qmd
├── 04_slurm_submission.qmd
├── 05_dry_run.qmd
└── 06_completed_checklist.qmd
```

This manual may generate or check:

- an ERA5 request specification;
- project configuration;
- pipeline skeleton;
- raw/interim/processed data paths;
- small dry-run behavior;
- Slurm submission scripts;
- expected logs;
- validation tests.

The final checklist should say:

```text
[x] request declared
[x] pipeline skeleton exists
[x] Slurm scripts exist
[x] dry run passes
[x] project is ready to run ERA5 pipeline
```

The desired output is not the final climate analysis.

The desired output is:

> The ERA5 pipeline cockpit is ready.

The end user can then implement and run the actual pipeline code as needed.

---

## Template 3: `03_reproducible_singularity_environment/`

This is the most complex manual.

Purpose:

> Assemble a reproducible Singularity/Apptainer environment for scientific data work.

Expected pages:

```text
pages/
├── 00_before_you_start.qmd
├── 01_project_contract.qmd
├── 02_platform_recipe.qmd
├── 03_runtime_boundaries.qmd
├── 04_system_dependencies.qmd
├── 05_language_packages.qmd
├── 06_activation.qmd
├── 07_validate_runtime.qmd
├── 08_slurm_launch.qmd
├── 09_final_sif.qmd
└── 10_completed_checklist.qmd
```

This manual may generate or check:

- project contract;
- platform recipe;
- Spack configuration;
- Python project files;
- R project files;
- activation scripts;
- container launch scripts;
- runtime bind paths;
- cache/temp directory behavior;
- Slurm launch scripts;
- final `.sif` image behavior;
- runtime validation tests.

The final checklist should say:

```text
[x] project contract exists
[x] platform recipe declared
[x] runtime boundaries checked
[x] system dependencies installed before language packages
[x] Python/R package state declared
[x] activation works
[x] Slurm launch works
[x] final SIF launches
```

The desired output is:

> The research aircraft is ready for flight.

Not:

> The scientific work is done.

---

## `examples/`

The `examples/` folder is different from `templates/`.

Templates are manuals.  
Examples are what a completed project might look like after a user operates a manual.

```text
examples/
├── stagecoach_input_project/
├── era5_processing_project/
└── singularity_environment_project/
```

This distinction is important.

A user should not start by copying an example project and treating it as the tool. The example project is a destination. The manual is the process that gets them there.

In other words:

```text
templates/02_era5_pipeline/
  -> the manual the user reads and executes

examples/era5_processing_project/
  -> one possible project produced by using that manual
```

The examples should help reviewers understand the intended end state. They are not the framework itself.

---

## Workflow-specific helper libraries

Each manual can have its own attached helper library.

For example:

```text
templates/01_stagecoach_symlink_input/src/
└── stagecoach_symlink.py

templates/02_era5_pipeline/src/
├── era5_requests.py
├── era5_paths.py
└── era5_checks.py

templates/03_reproducible_singularity_environment/src/
├── platform_contract.py
├── spack_helpers.py
├── container_helpers.py
└── activation_checks.py
```

This is important because manuals should not become monolithic `.qmd` files full of repeated helper code.

The `.qmd` page should teach and orchestrate. The helper library should hold reusable implementation.

A page can remain readable:

```python
from quarto_manual.project import Project
from era5_requests import write_request_spec
from era5_checks import expect_valid_request

project = Project.discover()

write_request_spec(project)
expect_valid_request(project)
```

This keeps the manual understandable while still allowing conventional software engineering practices.

---

## Manual page structure

Each `.qmd` page should be readable as an instruction page.

A typical page looks like this:

````markdown
# 02 Request Specification

## What this page does

This page creates the ERA5 request specification for this project.

## Start from current project state

```python
from quarto_manual.project import Project

project = Project.discover()
```

## What you need

- CDS credentials
- target country
- years
- variables
- output format

## Assemble

```python
from era5_requests import write_request_spec

write_request_spec(
    project=project,
    country="MDG",
    years=[2010, 2011],
    variables=["2m_temperature"],
)
```

## Inspect

```python
from era5_checks import test_request_spec_is_valid

test_request_spec_is_valid(project)
```

## Do not proceed unless

- `config/era5_request.yml` exists
- request variables are valid
- dry-run validation passes
````

The `.qmd` file is both readable documentation and executable setup logic.

Reviewers are encouraged to open the manual pages directly. They are plain text by design.

---

## Page-level tests

Each page ends with a test because a manual step should have an observable completion condition.

This is the software equivalent of checking a LEGO subassembly against the picture before moving to the next page.

For the Python prototype, the natural test runner is `pytest`. Pytest fixtures are useful here because tests can request shared setup objects by name, which fits the idea of a page test asking for the current `project` object. ([pytest](https://docs.pytest.org/en/7.1.x/how-to/fixtures.html?utm_source=chatgpt.com))

A page test might check:

```python
def test_input_symlink_exists(project):
    assert project.raw_data.exists()
    assert project.raw_data.is_symlink()
```

Or:

```python
def test_runtime_has_expected_tools(project):
    assert project.command_succeeds("python --version")
    assert project.command_succeeds("R --version")
    assert project.command_succeeds("quarto --version")
```

The test is the manual’s inspection step. It answers:

> Did this page actually assemble the thing it claimed to assemble?

---

## Exportable manual blocks

Eventually, pages should contain exportable blocks.

For example:

````markdown
::: {.manual-project-source file="src/{{ project_package }}/contract.py"}
```python
from dataclasses import dataclass
from pathlib import Path

@dataclass(frozen=True)
class ProjectContract:
    project_name: str
    project_dir: Path
```
:::
````

This block says:

> When the manual is exported, write this code to `src/{{ project_package }}/contract.py`.

Other block types may include:

```text
.manual-lib-source
.manual-project-source
.manual-project-test
.manual-project-script
.manual-project-config
.manual-run
.manual-explain
```

The goal is to make the `.qmd` page the source of truth for both explanation and generated setup artifacts.

---

## Potential CLI

A CLI is not the main intellectual contribution, but there may be a thin convenience layer.

Possible commands:

```bash
quarto-manual export projects/myproj
quarto-manual test projects/myproj
quarto-manual render projects/myproj
```

The CLI should not become the primary workflow engine. It should coordinate:

- Quarto rendering;
- export behavior;
- page-level tests;
- project inspection.

A Quarto Manual should remain inspectable as plain text. The `.qmd` pages are the important artifact.

---

## What this is not

This project is not trying to replace existing tools.

It is not a replacement for:

- READMEs;
- Quarto documentation;
- package documentation;
- uv;
- R package managers;
- Spack;
- Singularity/Apptainer;
- Slurm;
- Make;
- targets;
- Snakemake;
- Nextflow;
- DataLad;
- GitHub Actions;
- pytest;
- testthat.

A Quarto Manual is a coordination layer between those tools. It helps a user assemble the correct combination of tools for a specific project and verify that the setup is ready.

---

## Common concern: why not just a README?

A README is the correct baseline comparison.

A README works well when the task is short, linear, stable, and mostly copy-pasteable.

The workflows targeted here have a different shape:

- order matters;
- later steps depend on earlier artifacts;
- users need to edit project-specific variables;
- files are generated along the way;
- runtime context matters;
- completion needs to be verified;
- setup may need to be repeated across many projects.

A README explains what to do.  
A Quarto Manual helps the user do it, modify it, and test whether it worked.

---

## Common concern: why not just a CLI?

A CLI works well when the developer can safely choose the right defaults and hide the workflow.

But in research computing, the right choice often depends on local context:

- Which cluster?
- Which filesystem?
- Which dataset?
- Which data governance rules?
- Which system dependencies?
- Which R and Python packages?
- Which runtime?
- Which scheduler constraints?
- Which outputs need to be shared?

A Quarto Manual keeps these decisions visible. It gives users an editable procedure rather than forcing them into a hidden model.

---

## Common concern: is this overengineering?

It would be overengineering for a four-command setup.

It may not be overengineering for recurring research workflows where setup involves environment files, data conventions, system dependencies, containers, scripts, notebooks, and handoff checks.

The intended users are not people who need a one-line install command. The intended users are people who repeatedly assemble research projects where setup quality affects reproducibility, maintainability, and collaboration.

---

## What kind of feedback would help?

At this stage, design feedback is more valuable than polish.

Helpful feedback includes:

- Which manual examples are compelling?
- Which examples feel too artificial?
- Which page names are unclear?
- Which checks are too strict or too loose?
- Which parts should be README-only?
- Which parts should be CLI-only?
- Which parts belong in helper libraries?
- Which assumptions are too Harvard/FASRC-specific?
- Which ideas could generalize to other labs?
- What would make this useful for CAFE, LEGO, ERA5, RED, or other shared workflows?

Concrete failure cases are especially valuable. For example:

- “This would not work for my pipeline because…”
- “This page assumes the wrong order because…”
- “This check should happen earlier because…”
- “This should be a reusable helper, not page code.”
- “This is too much machinery for the first template.”
- “This is exactly the kind of handoff step people forget.”

---

## Current limitations and next milestones

This project is not yet stable, but its principles are actively being explored across several research computing projects.

Expected changes:

- folder names may change;
- page names may change;
- template names may change;
- CLI names may change;
- export block names may change;
- helper library structure may change;
- tests may be incomplete;
- Quarto extension behavior may change.

The current goal is to make the architecture legible enough for collaborators to review.

Immediate next milestones:

1. Stabilize the repository scaffold.
2. Implement the central `Project` dataclass.
3. Implement one small manual end to end.
4. Implement page-level tests for that manual.
5. Implement minimal export mechanics.
6. Render the manual as a Quarto book.
7. Create a completed example project from one manual.
8. Use the prototype to refine the framework.

The smallest useful demonstration is probably the Stagecoach symlink manual because it can show the full pattern without requiring a full HPC environment build.

---

## Working thesis

Quarto Manual introduces a framework for interactive, executable software manuals.

The framework is intended for workflows that are too complex for prose-only documentation and too variable for rigid automation.

The examples in this repository demonstrate how the framework could support:

- data staging;
- ERA5 data workflow preparation;
- reproducible Singularity environment setup.

The desired output of a manual is not the scientific result. The desired output is a project that is ready to operate.

The researcher still does the science.  
The manual checks that the aircraft is ready to fly.