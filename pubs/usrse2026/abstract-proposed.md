# Proposed abstract revision

This file contains proposed replacement passages for `abstract.md`. The
accepted scientific abstract remains unchanged; a human author should integrate
these passages into the publication source if appropriate.

## Replace the Quarto Manuals contribution paragraphs

Quarto is a modern, plain-text, multi-language, and multi-output literate
programming framework for creating reproducible documents and workflows
[@allaireQuarto2026]. Building on Quarto with a carefully designed set of
templates and extensions, we introduce **Quarto Manuals**: a framework for
executable operator-facing procedures. Manuals expose ordered workflow steps,
required inputs, consequential decisions, observable state transitions, and
verification points. They document how a competent operator performs a workflow
without requiring tutorial-style narration of ordinary domain concepts. Rather
than hiding workflow decisions and steps, Quarto Manuals keep them visible and
editable, making them useful in research-computing contexts where local
constraints and expert judgment shape execution parameters. Mechanical
execution may be automated, but operator decisions and verification boundaries
remain explicit. The framework is powered by `quarto-emit`, a lightweight
backend extension that materializes conventional workflow artifacts from manual
pages when needed.

We demonstrate the approach with three examples of increasing operational
complexity: a simple manual for staging datasets in project space; an
intermediate manual for geospatial aggregation of environmental exposure data;
and a complex manual for creating robust, reproducible, fully containerized
geospatial data-science environments on High Performance Computing (HPC)
clusters. All examples are available at the project
[website](https://goldenplanetaryhealthlab.github.io/QuartoManual/).

For authors, Quarto Manuals provide a structured yet adaptable way to turn
recurring workflows into reusable operator manuals for themselves and
colleagues. For operators, they provide a bounded, reproducible handoff in
which human-authored operational intent, agent or software execution, and
observable verification remain distinguishable. Quarto Manuals complement
rather than replace conventional software-engineering tools: they provide an
operator-facing surface through which computational procedures can be scoped,
inspected, and verified without collapsing meaningful judgment into opaque
automation.

## Replace the closing framing

Quarto Manuals provide a practical interface for making scientific workflows
more reproducible and inspectable, particularly where local constraints and
expert judgment shape execution parameters. We see future opportunities to use
them alongside AI-assisted and agentic systems: a Manual does not make an agent
reliable by itself, but it can give human-authored operational intent a bounded
surface in which agent actions are scoped, inspected, and verified.
