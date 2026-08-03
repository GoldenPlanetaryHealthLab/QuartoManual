## Abstract

[![hackmd-github-sync-badge](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q/badge)](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q)

Software development activities continue to evolve in scale and complexity, as evidenced by
the growth of global repository counts and volume of large-scale software archives[@GithubInnovationGraph; @martinelliSoftwareHeritageActivity2026]
And as we navigate the paradigm shift of AI and agentic systems, 
maintaining accessibility to scientific software 
and data science workflows must remain a high priority. 

Despite the critical importance of modern data science and AI workflows in 
academia and industry, effective, reproducible documentation remains an 
overlooked and under-served component of delivering 
high quality software [@aghajaniSoftwareDocumentationIssues2019]. This issue
is only expected to be exacerbated as the proportion and sophistication of AI 
generated code submitted to public repositories continues to rise [@robbesAgenticMuchAdoption2026].
Developers need creative solutions to address the limitations of traditional
software documentation to executing workflows in a reproducible and verifiable manner 
as the landscape of software development continues to evolve.

Conventional documentation can describe a workflow, but for complex, multi-step, 
order-dependent tasks and projects, it is often insufficient to document and 
verify critical runtime execution details such as user platform 
dependencies, configuration, versions, and step relationships [@ebertGeneralConceptConsistent2015]. 
On the other hand, command-line wrappers can be built to wrap and directly execute
tasks in a declarative workflow [@vanderaalstDeclarativeWorkflowsBalancing2009], improving automation and reproducibility. However,
developing CLI wrappers can be time-consuming and comes with a trade-off between control
and flexibility: highly specialized wrappers can improve consistency, but may be inflexible and difficult to maintain, while
more generic wrappers enable complexity by shifting the burden to the user, requiring them to manage a large 
number of flags and options via configuration files [@sadiqSpecificationValidationProcess2005; @brackTenSimpleRules2022].
AI and agentic systems are promising, but their reproducibility is currently limited by non-determinism [@siddiqLargeLanguageModels2025]. Furthermore, ongoing development of
agentic systems is still in its infancy, with current exploratory implementations
(such as harnesses)
still requiring careful human oversight to achieve acceptable levels of reliability [@agrawalCanAIConduct2026].

By contrast, executable literate programming approaches can encode and enforce complex
workflow steps _and_ generate idempotent results. Quarto modern, plain-text, 
multi-language, and multi-output literate programming framework that enables the creation of 
reproducible documents and workflows [@allaireQuarto2026]. By extending Quarto with a
carefully designed set of templates and extensions, we propose **Quarto Manuals**, a framework 
for executable software manuals that guide users through a workflow as ordered, interactive 
pages that combine explanation, code execution, and verification. Quarto Manuals 
are intended to be flexible across audiences, projects, organizations, and 
programming languages, while maintaining reproducibility by enabling explicit 
and auditable side effects.
Rather than hiding workflow decisions, Quarto Manuals keep them visible and editable, 
which is especially important in research computing environments where local constraints and 
expert judgment often shape how work is performed. The system is powered by quarto-emit, a 
lightweight backend extension that materializes conventional workflow artifacts from manual 
pages when needed. We demonstrate the approach through three examples of increasing 
sophistication: a simple manual, an intermediate manual, and a complex manual. For authors, 
Quarto Manuals provide a structured yet adaptable way to turn recurring workflows into reusable 
manuals. For operators, they provide a stepwise, testable process for generating reproducible 
setup artifacts and confirming progress in a structured and auditable way throughout the 
workflow.

## Feature Roadmap

- [ ] abstract as prose
- [ ] stylize each block so it is visually distinct
- [ ] use Lua to print out useful render messages when blocks are being processed
- [ ] negative reinforcement: identify and correct misuse of the manual visually
- [ ] setup a testing suite in a separate repo
- [ ] can Lua be used to connect checks and prereqs across pages? Maybe?