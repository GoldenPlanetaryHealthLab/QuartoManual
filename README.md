## Abstract

[![hackmd-github-sync-badge](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q/badge)](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q)

- Programming is already difficult, and research data workflows are growing in scale and complexity [CITE NEEDED]. Scientists need workflow rigor, not just working code.
- Traditional documentation helps, but it breaks down for large, multi-step, order-dependent workflows. It is not executable, reproducible, or able to confirm that a user is proceeding correctly. [CITE PROBABLY NEEDED]
- Command-line wrappers are executable, but often too rigid: either the workflow is over-constrained, or flexibility is pushed into an unwieldy number of flags and options.
- AI and agentic systems are promising, but today they are still limited by (FACT) non-determinism [CITE NEEDED] and (OPINION) uneven reliability in complex scientific workflows (though we are working to address these issues with agentic workflows).
- We propose **Quarto Manuals**, a framework for executable software manuals built on Quarto starter templates and extensions.
- A Quarto Manual guides users through a workflow as ordered, interactive pages that combine explanation, code execution, and verification.
- Manuals are flexible across audiences, projects, organizations, and programming languages, while remaining reproducible because their side effects are explicit and inspectable.
- Rather than hiding workflow decisions, Quarto Manuals keep them visible and editable, which is especially important in research computing environments with local constraints and judgment calls.
- The backend is powered by **`quarto-emit`**, a lightweight extension that materializes conventional workflow artifacts from manual pages when needed.
- We demonstrate the approach with three examples of increasing sophistication: a simple manual, an intermediate manual, and a complex manual.
- For authors, Quarto Manuals provide a structured but adaptable template for turning complex recurring workflows into reusable manuals.
- For operators, they provide a stepwise, testable process for leaving behind reproducible setup artifacts and confirming progress in a structured way through the workflow.

## Feature Roadmap

- [ ] abstract as prose
- [ ] stylize each block so it is visually distinct
- [ ] use Lua to print out useful render messages when blocks are being processed
- [ ] can Lua be used to connect checks and prereqs across pages? Maybe?
- [ ] setup a testing suite in a separate repo