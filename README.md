# Quarto Manual

A Quarto Manual is a cloneable, editable, executable instruction booklet for setting up and operating a research computing project. It is not simply a README, and it is not a rigid command-line wrapper. It sits between those two approaches.

A README explains a procedure.
A wrapper hides a procedure.
A Quarto Manual walks the user through a procedure, lets them modify it, exports the necessary setup files, and tests whether each step is complete.

The current examples in this repo focus on research software engineering workflows for geospatial data projects, especially those that need reproducible environments, shared HPC filesystem conventions, R/Python dependencies, Quarto notebooks, containers, Slurm scripts, and project-specific setup checks.

This repository is intentionally plain text at the moment. The best way to understand it is to open the folders, read the .qmd pages, and learn how each page contributes to the whole.

⸻

## How to read this repository

If you are reviewing this as a potential coauthor, please do not start by looking for a finished tool.

Start by reading the repository as a prototype of a pattern.

Suggested reading order:

1. Read this README.md.
2. Open templates/01_stagecoach_symlink_input/.
3. Read the .qmd pages in order.
4. Look at the matching tests/ files.
5. Look at the workflow-specific src/ folder.
6. Then repeat for 02_era5_pipeline/.
7. Then repeat for 03_reproducible_singularity_environment/.
8. Finally, inspect _extensions/quarto-manual/ to see how export and rendering are intended to work.

As you read, ask:

* Does each page have a clear purpose?
* Does each page begin by discovering project state?
* Does each page end with a concrete inspection?
* Are the generated artifacts understandable?
* Could a user modify this page safely?
* What assumptions should be made explicit?
* What should remain site-specific?
* What should become reusable library code?

⸻

## Why this project exists

Many research computing projects stall or delay not because the scientific question is unclear, but because the setup process is scattered across individual memory, READMEs, shell history, cluster-specific assumptions, notebooks, config files, and informal handoff conversations.

Typical questions include:

* Where should the project live?
* Which files and software libraries are project-owned?
* Which data are inputs versus generated artifacts?
* Which dependencies belong in Python, R, modules, conda, Spack, or a container?
* Which setup steps must happen before others?
* Which scripts should run locally versus on Slurm?
* How do we know the project is ready to run?
* How does a second person reproduce the setup later?

A README can document these steps, and **that is still important**. But READMEs work best when setup is short, linear, stable, and mostly copy-pasteable. Once setup becomes order-dependent, project-specific, and testable, prose documentation alone has diminishing returns. As you add more content to your docs (e.g., a handbook), it becomes more likely that the reader will stray from your instructions, either by mistake, or due to limitations they encounter along the way.

A Quarto Manual treats project setup more like assembling a complex LEGO set. Each page of the manual is a bounded assembly step. It begins by discovering the current project state, guides the user through a setup task, exports any required files, and ends by running a test that checks whether the step is complete.

⸻

## Why Quarto?

Quarto is useful here because it already supports executable documents, books, websites, project configuration, and extensions. Quarto project type extensions are specifically intended to tailor projects for a particular purpose, including organization-level standards for documentation or analysis. Quarto also supports functionality that operates on code blocks inside .qmd files, meaning the content of blocks can be exported source files, tests, scripts, or configuration, without writing a fragile custom Markdown parser.

The core idea is to let Quarto do what it is good at:

* readable prose
* executable code
* rendered documentation
* project structure
* notebook-like interaction
* extension-based behavior

Then we add a thin manual layer:

* page-level project checks
* exportable code/config/test blocks
* a stable project object
* workflow-specific helper libraries
* final readiness checklists

⸻

## The basic mental model

Each manual can have several templates. Once a user has cloned a manual for themselves, they can then generate a new instance of the 
template for their project. In doing so, Quarto copies the template pages into `projects` for them to step through each page of the 
template at their leisure.

Each manual page follows this rhythm:

1. Discover current project state.
2. Explain the assembly step.
3. Let the user fill in project-specific variables.
4. Generate or modify setup artifacts.
5. Run an inspection/test.
6. Mark that page as complete only if the evidence exists.

In code form, the pattern is roughly:

```python
from manual_lib.project import Project, do_setup, check_slurm
project = Project.discover()
# The page guides the user through one setup task.
do_setup(project)
# It may call helper functions, create files, or export scripts.
check_slurm(project)

test_this_page_is_complete(project)
```

The project object is intentionally simple. It should describe the current project state: paths, names, variables, declared inputs, expected outputs, and known artifacts. It should not become a hidden workflow engine or private progress database.

Progress should be inferred from external evidence:

* files
* directories
* configs
* symlinks
* lockfiles
* generated scripts
* Slurm logs
* container images
* rendered outputs
* passing tests

This is important: the manual does not own the project. The project state remains visible on disk.

⸻

## Why tests?

Like checking your LEGO build against the picture, each page ends with a test because a manual step should have an observable completion condition.

For the Python prototype, the natural test runner is pytest. Pytest fixtures are useful because tests can request shared setup objects by name, which fits the idea of a page test asking for the current project object. (pytest)

A page test might check:

def test_input_symlink_exists(project):
    assert project.raw_data.exists()
    assert project.raw_data.is_symlink()

Or:

def test_runtime_has_expected_tools(project):
    assert project.command_succeeds("python --version")
    assert project.command_succeeds("R --version")
    assert project.command_succeeds("quarto --version")

The test is the manual’s inspection step. It answers the question: did this page actually assemble the thing it claimed to assemble?

⸻

## Repository tour

The repository is organized so that coauthors can read it as is without implementation.

```
quarto-manual/
├── README.md
├── _quarto.yml
├── _extensions/
├── src/
├── templates/
└── projects/
```

Each folder has a different role.

⸻

### `_quarto.yml`

This defines the root Quarto project, what the end-user should have in their home directory or personal workspace.

A rendered manual could behave like a Quarto handbook or lab website, but it is not necessary. The .qmd files _for each implementation in `projects`_ remain the source of truth. The rendered output is helpful for reading, but the real value is that the same pages can also execute setup logic and export project files.

Open this file to see how the manual is configured as a Quarto project.

⸻

### `_extensions/quarto-manual/`

This folder contains the planned Quarto extension machinery.

```
_extensions/quarto-manual/
├── _extension.yml
├── manual.lua
├── manual-export.lua
└── theme.scss
```

#### `_extension.yml`

Defines the Quarto extension.

The long-term goal is for the manual to behave like a custom Quarto project type: a project designed specifically for guided, testable research workflow assembly.

#### `manual.lua`

A rendering filter.

This should eventually style manual blocks such as:

* What you need
* Assemble
* Inspect
* Do not proceed
* Completed checklist

This filter is for presentation. It should not own project state.

#### `manual-export.lua`

An export filter.

This is where the manual becomes more than documentation. The export filter should read structured blocks from .qmd pages and write conventional files into the project, such as:

* Python modules
* R scripts
* shell scripts
* Slurm scripts
* YAML/TOML configs
* pytest/testthat files

The important design decision is that export should rely on Quarto/Pandoc parsing rather than a custom Markdown parser.

#### `theme.scss`

Manual-specific styling.

This should make rendered pages feel like an instruction booklet rather than a generic documentation site.

⸻

### `src/`

This folder contains shared manual machinery.

```
src/
├── project.py
├── checks.py
└── export.py
```

#### `project.py`

Defines the central project object.

The project object is likely to be a small dataclass that can discover the current project state from the filesystem and manual.yml.

Its job is to answer questions such as:

* What is the project root?
* What is the project name?
* Where are the pages?
* Where are the tests?
* Where are the data folders?
* Which template created this project?
* Which variables have been declared?

It should stay boring, explicit, and inspectable.

#### `checks.py`

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

#### `export.py`

A thin Python layer around the manual export behavior.

This may eventually support commands such as:

```
rse-manual inflate .
rse-manual test .
rse-manual render .
```

The CLI should remain small. It should coordinate Quarto, exports, and tests rather than becoming a large custom workflow engine.

⸻

### `templates/`

This is the most important folder conceptually.

Templates are reusable manuals. Each template describes a type of workflow. A user can create a project from a template, edit the pages for their own case, and run the checks.

The current scaffold proposes three templates that scale in complexity:

```
templates/
├── 01_stagecoach_symlink_input/
├── 02_era5_pipeline/
└── 03_reproducible_singularity_environment/
```

These are not finished implementations yet. They are examples of how different research workflows could be expressed as manuals.

⸻

## Template 1: 01_stagecoach_symlink_input/

This is the smallest manual.

Purpose:

Connect an existing registered input dataset into a project workspace using a controlled symlink workflow.

This manual demonstrates the minimum useful pattern:

- discover project state
- declare input
- create symlink
- test symlink
- complete checklist

Expected pages might include:

```
pages/
├── 00_before_you_start.qmd
├── 01_declare_input.qmd
├── 02_create_symlink.qmd
└── 03_completed_checklist.qmd
```

This manual should produce setup evidence, not derived scientific results. Its final checklist should say something like:

[x] input declared
[x] symlink created
[x] symlink target exists
[x] project can read input

The desired output is:

**This project is correctly wired to its input data.**

Not:

The analysis is complete.

I feel this is an appropriate first example because it is small, concrete, and easy to inspect.

⸻

## Template 2: 02_era5_pipeline/

This is a medium-complexity manual.

Purpose:

Assemble the setup and execution tools needed to run an ERA5 data acquisition or processing pipeline.

Expected pages might include:

```
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

* an ERA5 request specification
* project configuration
* pipeline skeleton
* raw/interim/processed data paths
* small dry-run behavior
* Slurm submission scripts
* expected logs
* validation tests

The final checklist should say:

[x] request declared
[x] pipeline skeleton exists
[x] Slurm scripts exist
[x] dry run passes
[x] project is ready to run ERA5 pipeline

The desired output is not the final climate analysis. The desired output is that the ERA5 pipeline cockpit is ready. The end user
can then implement the actual pipeline code as they wish.

⸻

## Template 3: 03_reproducible_singularity_environment/

This is the most complex manual.

Purpose:

Assemble a reproducible Singularity/Apptainer environment for scientific data work.

Expected pages might include:

```
pages/
├── 00_before_you_start.qmd
├── 01_project_contract.qmd
├── 02_platform_recipe.qmd         # this workflow uses Singularity, an alternative to Docker, so the recipe file is defined in the manual
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

* project contract
* platform recipe
* Spack configuration
* Python project files
* R project files
* activation scripts
* container launch scripts
* runtime bind paths
* cache/temp directory behavior
* Slurm launch scripts
* final .sif image behavior
* runtime validation tests

The final checklist should say:

[x] project contract exists
[x] platform recipe declared
[x] runtime boundaries checked
[x] system dependencies installed before language packages
[x] Python/R package state declared
[x] activation works
[x] Slurm launch works
[x] final SIF launches

The desired output is:

The research aircraft is ready for flight.

Not:

The scientific work is done.

⸻

## Workflow-specific helper libraries

Each template can have its own attached software library.

For example:

```
src/01_stagecoach_symlink_input/
└── stagecoach_symlink.py
src/02_era5_pipeline/
├── era5_requests.py
├── era5_paths.py
└── era5_checks.py
src/03_reproducible_singularity_environment/
├── platform_contract.py
├── spack_helpers.py
├── container_helpers.py
└── activation_checks.py
```

This is important because manuals should not become monolithic .qmd files full of repeated helper code. The .qmd page should teach and orchestrate. The helper library should hold reusable implementation.

Each manual page can remain readable by encapsulating helper procedures:

```
project = Project.discover()
from era5_requests import write_request_spec
from era5_checks import expect_valid_request
write_request_spec(project)
expect_valid_request(project)
```

This keeps the manual understandable while still allowing real software engineering practices.

⸻

## `projects/`

This folder contains project instances created from templates.

```
projects/
├── my-stagecoach-input-project/
├── my-era5-project/
└── my-singularity-env-project/
```

A project is a copy or instance of a template that a user edits for a specific case.

For example:

```
projects/my-era5-project/
├── manual.yml
├── pages/
├── src/
├── tests/
├── slurm/
├── data/
└── checklist.md
```

The key idea is that a project does not necessarily have to begin from page zero every time. The author of a manual can decide which pages require previous pages and which pages can be entered independently.

The teaching order may be linear, but the operational logic can be state-based:

Manual pages are ordered for learning.
Manual tests inspect project state.

⸻

## Manual page structure

Each `.qmd` page should be readable as an instruction page.

A typical page might look like this:
````
```
# 02 Request Specification
## What this page does
This page creates the ERA5 request specification for this project.
## Start from current project state

```pythonfrom manual_lib.project import Project
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

The .qmd file is both readable documentation and executable setup logic.

I recommend investigating manual pages yourself to see how this works.

⸻

## Exportable manual blocks

Eventually, pages should be able to contain exportable blocks.

For example:
````
::: {.manual-project-source file="src/{{ project_package }}/contract.py"}
\```python
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

When the manual is inflated, write this code to `src/{{ project_package }}/contract.py`.

Other block types may include:

.manual-lib-source
.manual-project-source
.manual-project-test
.manual-project-script
.manual-project-config
.manual-run
.manual-explain

The goal is to make the .qmd page the source of truth for both explanation and generated setup artifacts.

⸻

## Potential CLI

A CLI is not the main intellectual contribution, but there could be a thin convenience layer.

Possible commands:

rse-manual new myproj --template 02_era5_pipeline   # create a new instance of pipeline from the manual
rse-manual export projects/myproj                   # export the code chunks with helpers to their respective library
rse-manual test projects/myproj                     # test all the pages to see if my project is set up correctly
rse-manual render projects/myproj                   # render the manual to a handbook for my own reading or for sharing with others

The implementation may use uv for Python project management, since uv is designed as a fast Python package and project manager. (Astral Docs) However, the manual pattern should not depend philosophically on uv. A manual can compose uv, R tooling, Spack, Slurm, containers, or other site-specific tools as needed.

⸻

## What this is not

This project is not trying to replace existing tools.

It is not a replacement for:

* READMEs
* Quarto documentation
* package documentation
* uv
* R package managers
* Spack
* Singularity/Apptainer
* Slurm
* Make
* targets
* Snakemake
* Nextflow
* DataLad
* GitHub Actions
* pytest
* testthat

A Quarto Manual is a coordination layer between those tools. It helps a user assemble the correct combination of tools for a specific project and verify that the setup is ready.

⸻

## Common concern: why not just a README?

A README is the correct baseline comparison.

A README works well when the task is short, linear, stable, and mostly copy-pasteable.

The workflows targeted here have a different shape:

* order matters
* later steps depend on earlier artifacts
* users need to edit project-specific variables
* files are generated along the way
* runtime context matters
* completion needs to be verified
* setup may need to be repeated across many projects

A README explains what to do.
A Quarto Manual helps the user do it, modify it, and test whether it worked.

⸻

## Common concern: why not just a CLI?

A CLI works well when the developer can safely choose the right defaults and hide the workflow.

But in research computing, the right choice often depends on local context:

* Which cluster?
* Which filesystem?
* Which dataset?
* Which data governance rules?
* Which system dependencies?
* Which R and Python packages?
* Which runtime?
* Which scheduler constraints?
* Which outputs need to be shared?

How many of those decisions can be meaningfully captured in a handful of CLI flags?

A Quarto Manual keeps these decisions visible. It gives users an editable procedure rather than forcing them into a hidden model.

⸻

## Common concern: is this overengineering?

The intended users are not people who need a one-line install command. The intended users are people who repeatedly assemble research projects where setup quality affects reproducibility, maintainability, and collaboration.

It would be overengineering for a four-command setup.

It may not be overengineering for recurring research workflows where setup involves environment files, data conventions, system dependencies, containers, scripts, notebooks, and handoff checks.

⸻

## What kind of feedback would help?

At this stage, design feedback is more valuable than polish.

Helpful feedback includes:

* Which manual examples are compelling?
* Which examples feel too artificial?
* Which page names are unclear?
* Which checks are too strict or too loose?
* Which parts should be README-only?
* Which parts should be CLI-only?
* Which parts belong in helper libraries?
* Which assumptions are too Harvard/FASRC-specific?
* Which ideas could generalize to other labs?
* What would make this useful for CAFE, LEGO, ERA5, RED, or other shared workflows?

Concrete failure cases are especially valuable. For example:

* “This would not work for my pipeline because…”
* “This page assumes the wrong order because…”
* “This check should happen earlier because…”
* “This should be a reusable helper, not page code.”
* “This is too much machinery for the first template.”
* “This is exactly the kind of handoff step people forget.”

⸻

## Current status and limitations

This project is not yet stable, but its principles are actively in use across several of Tinashe's projects.

Expected changes:

* folder names may change
* page names may change
* template names may change
* CLI names may change
* export block names may change
* helper library structure may change
* tests may be incomplete
* Quarto extension behavior may change

The current goal is to make the architecture legible enough for collaborators to review.

The immediate next milestones are:

1. Create a minimal repository scaffold.
2. Implement the central Project dataclass.
3. Implement one small template end to end.
4. Implement page-level tests for that template.
5. Implement minimal export mechanics.
6. Render the manual as a Quarto book.
7. Use the prototype to refine the architecture.

The smallest useful demonstration is probably the Stagecoach symlink manual, because it can show the full pattern without requiring a full HPC environment build.
