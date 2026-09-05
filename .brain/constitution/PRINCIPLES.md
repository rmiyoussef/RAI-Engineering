# Principles

## 1. Single Responsibility
Every file does one thing. Skills teach one domain. Agents handle one role. If a file has two responsibilities, split it.

## 2. Structured Over Free-Form
Agents return structured data (schemas), not paragraphs. Structured outputs are validatable, composable, and testable. Free-form text is for the final user response, not for agent-to-agent communication.

## 3. Context Over Instructions
Give the AI context about the domain — not step-by-step scripts. A senior engineer doesn't need a recipe; they need to know the constraints, the patterns, and the goal. Trust the model to execute.

## 4. Memory Is a First-Class Citizen
Every decision, every lesson, every architecture change is indexed. Nothing is lost. Before any work starts, memory is consulted. After any work ends, memory is updated. The project grows smarter with every session.

## 5. Validate at Boundaries
The Brain validates every input and every output. Bad data stops at the border. An agent that returns malformed output is rejected and retried — it doesn't propagate garbage downstream.

## 6. Framework-Agnostic Core
The OS knows how to engineer software, not how to build Laravel apps. Domain knowledge (Laravel, React, Redis) lives in Skills. The Brain knows patterns — routing, validation, pipeline, memory, review — and delegates domain specifics.

## 7. Versioned Product
RAI-Engineering has releases. Projects pin a version and upgrade deliberately. Breaking changes are documented. Changelogs are enforced.

## 8. Testable Pieces
Every agent, every skill, every rule can be tested in isolation. Mock the input, assert the output. If you can't test it in isolation, it's coupled wrong.

## 9. Progressive Complexity
Start simple. Add layers as the project grows. Don't build scaffolding for problems you don't have yet. The system must work well with just the Brain and one agent before you add a second.

## 10. Reusable Across Projects
Nothing exists only because it's useful today. Every file must be designed for reuse. If a skill references a specific project, it's not a skill — it's a note. Skills live in RAI-Engineering. Memories live in the project.
