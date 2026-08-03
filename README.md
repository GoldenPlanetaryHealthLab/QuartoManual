## Abstract

[![hackmd-github-sync-badge](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q/badge)](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q)

Software development is continuing to expand in both scale and complexity, 
evidenced by the growth of global repository counts and large-scale software archives[@GithubInnovationGraph; @martinelliSoftwareHeritageActivity2026]
At the same time, AI and agentic systems are reshaping how software 
is produced, making it increasingly important to preserve 
accessibility, transparency, and reproducibility in scientific 
software and data science workflows.

Despite the central role of these workflows in academia and industry, 
effective, reproducible documentation remains an 
overlooked and under-served part of delivering 
high quality software [@aghajaniSoftwareDocumentationIssues2019]. This issue
is likely to become more acute as the volume and sophistication of AI 
generated code submitted to public repositories continues to increase [@robbesAgenticMuchAdoption2026].
Developers therefore need solutions beyond traditional documentation 
to support workflow execution __ address the limitations of traditional
software documentation to executing workflows in a reproducible and verifiable manner 
as the landscape of software development continues to evolve.

Conventional documentation can describe a workflow, but for complex, multi-step, 
order-dependent tasks and projects, it is often insufficient capturing and 
verifying critical runtime execution details such as platform 
dependencies, configuration, versions, and relationships between steps [@ebertGeneralConceptConsistent2015]. 
Command-line interface (CLI) wrappers can improve automation and reproducibility of a 
declarative workflow by providing a directly executable interface for complex
tasks [@vanderaalstDeclarativeWorkflowsBalancing2009]. However,
developing and maintaining CLI wrappers can be time-consuming and introduces
a persistent trade-off between control and flexibility: highly specialized 
wrappers can improve consistency, but may be inflexible and difficult to maintain, while
more generic wrappers enable complexity by shifting the burden to the user through
large numbers of flags and configuration options [@sadiqSpecificationValidationProcess2005; @brackTenSimpleRules2022].
Lastly, AI and agentic systems are promising, but their reproducibility remains limited by 
non-determinism [@siddiqLargeLanguageModels2025]. Furthermore, current 
practical agentic workflow implementations (such as harnesses) still require careful human oversight to achieve acceptable reliability [@agrawalCanAIConduct2026].

Executable literate programming approaches can encode and enforce complex
workflow steps _and_ generate idempotent results. Quarto is a modern, plain-text, 
multi-language, and multi-output literate programming framework for creating 
reproducible documents and workflows [@allaireQuarto2026]. Building on Quarto with a
carefully designed set of templates and extensions, we introduce **Quarto Manuals**, a
framework for executable software manuals that guide users through a workflow as ordered, interactive 
pages that combine explanation, code execution, and verification. Rather than 
hiding workflow decisions and steps, Quarto Manuals keep them visible and editable, 
making them ideal for research computing contexts where local constraints and 
expert judgment often shape execution parameters. The framework is powered 
by `quarto-emit`, a lightweight backend extension that materializes conventional 
workflow artifacts from manual pages when needed. We demonstrate the approach 
with three examples of increasing sophistication: a simple manual, 
an intermediate manual, and a complex manual. 

For authors, Quarto Manuals provide a structured yet adaptable way to turn 
recurring workflows into reusable manuals; for operators, they provide a 
stepwise, testable process for generating reproducible setup artifacts 
and confirming progress throughout execution in a structured and auditable manner.

Quarto Manuals promise to improve the reproducibility and reliability of software workflows,
while also providing a more accessible and interactive experience for users. And,
with the increasing adoption of AI and agentic systems in software development,
may provide a framework for ensuring that these workflows remain transparent, verifiable, and 
reproducible in the face of increasing complexity and non-determinism.

## Feature Roadmap

- [x] abstract as prose
- [ ] stylize each block so it is visually distinct
- [ ] use Lua to print out useful render messages when blocks are being processed
- [ ] negative reinforcement: identify and correct misuse of the manual visually
- [ ] setup a testing suite in a separate repo
- [ ] can Lua be used to connect checks and prereqs across pages? Maybe?