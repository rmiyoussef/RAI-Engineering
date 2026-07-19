# Limitations

## Hard Boundaries

1. **The Brain never writes code directly.** It delegates to agents. The Brain routes, validates, and persists — it does not implement.

2. **No project-specific knowledge in the OS.** RAI-Engineering knows how to engineer software. It does not know about BenchHR, Acme Corp, or any specific business domain. That knowledge lives in the project's `memory/` directory.

3. **No single agent handles the full lifecycle.** Planning, execution, review, and memory are separate agents. A Planner does not write code. An Executor does not review its own work.

4. **No model switching.** All agents run on `deepseek-v4-flash`. The system does not route to different models based on task type. Consistency over optimization.

5. **No free-form agent output.** Every agent's response must match its schema. If the output doesn't validate, it is rejected and the agent retries.

6. **No silent failures.** Every error, rejection, or retry is recorded in memory. The system does not hide its failures.

7. **No circular routing.** An agent cannot call itself directly or indirectly. The pipeline is a DAG.

8. **No persistent processes — except ORCHESTRATOR.** The system operates in request-response mode. It does not run daemons, watchers, or background processes. Each invocation is stateless — memory provides continuity. The **ORCHESTRATOR** is the sole exception: it performs session registration, heartbeat, and inbox polling as part of each session loop, but is still driven by user requests, not a background daemon.

9. **No prompt chains.** Skills are not prompt templates. A skill teaches context and patterns — it is not a multi-step instruction list.

10. **No system prompt inside system prompt.** Agents do not contain the Brain's system prompt. Agents contain their own role definition, schema, and skill references. The Brain loads and composes them.
