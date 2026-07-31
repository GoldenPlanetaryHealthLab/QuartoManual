## Abstract

[![hackmd-github-sync-badge](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q/badge)](https://hackmd.io/_App6vg9Tr-d0id8Uj675Q)

- programming is already hard and the data is only going to get bigger. workflows are blowing up in complexity and scale. scientists need rigour in their workflows.

- to get around this, we could write better and better docs. but even great docs have limitations:

    - docs are something you _read_, not something you _do_, meaning they break down in usefulness when we have to scale to longer and more complicated procedures

    - docs are not executable, meaning artifacts of progress are not reproducible, testable, or verifiable

    - good docs do not have a flexible feedback loop to confirm the user is acting correctly

- _What about building command line wrappers around existing tools?_ They are executable but they are totally inflexible. 

    - You build it once and everyone has to do it that way, or 
    
    - You inundate your software with several flags, arguments, and runtime options to try to make it flexible. This is not a good solution for repetitive but unexpectedly parametric workflows.

- _What about AI, LLMs, agents?_ 
    
    - This is a promising solution, but (fact) LLMs are non-deterministic, 
    meaning some steps in larger and more complex workflows will inevitably have results that may not be reproducible. 

    - Additionally (opinion) agents are not yet mature enough to be reliable
for some of the complex workflows we have in mind (though we are working on it with agentic workflows). Most users are still in the dyadic, "paste text into the box and read what comes out" turn-based workflow, which is not sufficient for many of the complex workflows we do.

- To solve this, we need a new type of documentation that is executable, flexible, and scalable. This is where Quarto and notebook-driven-development (NDD) comes in.

- We propose Quarto Manuals, an executable documentation framework that is flexible, scalable, and reproducible. Internally, a Quarto Manual is
a custom starter template and extension for Quarto.

- benefits:

    - flexible: can be used for different audiences, can be used for different purposes, can be used for different programming languages

    - scalable: can be used for different projects, can be used for different teams, can be used for different organizations, and can scale in complexity required of the project

    - reproducible: side effects are intentional, meaning they can be used to generate reproducible artifacts for the workflow itself

    - relies on quarto and can leverage the full ecosystem of quarto, including quarto extensions, quarto publishing, and quarto rendering

- drawbacks:

    - requires some programming knowledge to use

    - requires quarto; might be a new framework for some

    - requires active user participation, not fully automated (but this is a feature, not a bug)

- we show three examples in action: a simple example, an intermediate example, and a complex example.

- Importantly, we use `quarto-emit`, a new extension, for the backend. A Quarto Manual is just a cognitive framework physically materialized
by Quarto's custom Divs, and powered in the backend by a simple but powerful file export extension, `quarto-emit`. 

- Workflow for manual _authors_:

    - Authors call `quarto use template GoldenPlanetaryHealthLab/QuartoManuals` to create a new Quarto Manual that instructs users on how to do something complex and procedural, for e.g., "SetupMyProject"

    - Helpful prompts throughout the template help guide manual authors to use the template effectively, but leave them with the flexibility to implement
    their workflows to their desired level of sophistication.

    - Authors implement each page check with a testing suite to give the user feedback on whether they are implementing the workflow correctly.

    - inter-page dependencies are gently suggested, but not enforced to reduce implementation overhead for the extension and allow for flexibility in workflow design.

    - Authors `git push` their manuals to an organization's GitHub repository (or code hosting site of your choice)

- For manual _users_:

    - In your home directory or otherwise, `quarto use template MyLab/SetupMyProject` clones the `SetupMyProject` Manual to your local machine.

    - Step through the pages of the manual, hardcoding critical, context-specific variables (like your cluster configuration, your desired Python version, etc.) and executing the code as you go.
    
    - With each page, leave behind setup artifacts as you go, like environment files (`.venv`, `.Renviron`)
    scripts (`setup.sh`, `install.R`), and other configuration files (`config.toml`, `settings.json`, `pyproject.toml`).

    - Run `quarto render` to render the whole manual to HTML, PDF, or DOCX. If the manual has checks implemented in a testing suite, quarto render will execute the testing suite, providing you with a visual report of your progress in the manual and whether you are implementing the workflow correctly.

    - If all goes well, you now have a fully setup project as the original author intended, and you can now start working on your implementation of the project. If it doesn't you can go back to the exact Point of Failure (POF) and fix the issue, or you can reach out to the original author for help.