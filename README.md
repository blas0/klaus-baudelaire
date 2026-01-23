<p align="center">
  <h1 align="center">
    <u>Who is Klaus Baudelaire?</u>
  </h1>
</p>

<p align="center">
  <strong>
    Klaus was designed from the ground up, specifically around the architecturally embedded idiosyncrasies of Claude Code. Utilizing its features, native capabilities, and <i>spunkiness</i>.
  </strong>
</p>

<p align="center">
  <img src="klaus_claude.jpg" alt="klaus baudelaire" width="600">
</p>

---

<p align="center">
  <i>
    If you have ever read the Lemony Snicket books or watched the films. You know who he is. Instead of protecting his sisters from Jim Carrey or Barney Stinson...he serves you, by delegating agents to ship your 6th SaaS tool of the week.
  </i>
</p>

---

> [!CAUTION]
> **_This project is in active development._**
> 
> _**I will slowly commit updates/docs regarding this architecture.**_
> 
> _**As of right now (1/22/2026) I am not sure how I am going to package this.**_
> 
> _**Expect:**_ _**`npx | plugin | git/script`**_ _**after I get version control in sorts.**_

### Prologue

The amount of harnesses that appear daily is mind boggling & of course we're all going to try it out, but like most of us - we go back home: **Claude Code, OpenCode, Cursor or even Droid.**

Claude Code is my poison & I'm tired of the Kinko's Print Center *(Github)* of harnesses, novel abstractions, and VS forked IDE's.

Klaus's architecture was designed from the ground up, with the focality of Anthropic/Claude documentation, papers, and blog posts. 

### To swim with or against the current?

Without creating technical debt by adding in every skill, subagent, operational pipeline into the `~.claude/`, I focused on: what matters most during agentic development.

> **Managing Memory** (*View the [Manage Memory](https://code.claude.com/docs/en/memory?) documentation.*)

> **Hook Determinism** (*View the [Hooks Reference](https://code.claude.com/docs/en/hooks#hook-output) documentation.*)

> **Simplicity < Complexity** (*View the [Tool use with Claude](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview) documentation.*) 

> **Amplify and Reinforce** (*View the [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) documentation.*) 

---

<u><h2> Section I</h2></u>
### Managing Memory

*I understand that everyone has their own method/approach of managing memory. Letting an agent manage your codebase memory can cause technical debt, which is why they were specifically designed by thoroughly reading through the memory documentation seen above. I made these commands manually invocable to prevent edge case execution from wandered judgement.*

---

> **`/fillmemory`** executes a conditional elif memory dir/doc scaffolding within the:
`$CLAUDE_PROJECT_DIR/.claude` directory. Backing up preexisting `$RULES/ | $PROJECT/` dirs to a folder.

> **`/fillmemory`** executes agents in parallel to follow the  instructions defined by the `$VARIABLE` in the content of each `.md` within the `$PROJECT` dir *(excluding `$STANDARDS`)*

> **`/compost`** replicates the same behavior as **`/fillmemory`** except with one specialized agent designed for populating the `$STANDARDS` `.md` documentation.

Each document within the scaffolding contains `$VARIABLES` & `$INSTRUCTIONS` for the agent to follow during the `/fillmemory | /compost` execution - updating the documentation files - post scaffolding.

<u>**The scaffolding covers:**</u>

```
  .claude/
  ├── rules/
  │   └── project-index.md
  └── project/
      ├── architecture.md
      ├── frontend.md
      ├── backend.md
      ├── database.md
      ├── infrastructure.md
      ├── testing.md
      └── standards/
          ├── standards.md
          ├── coherence.md
          └── patterns.md
```

**This enforces the native architectural "behind the scenes" operations during startup.**

`CLAUDE.md` + `$CLAUDE_PROJECT_DIR/.claude/rules` are treated equally in terms of hierarchy.

**This will give Claude the context of "Oh, hey the codebase architecture index is here."**

The `project-index.md` contains strict non-absolute `path-to` directories covering `$PROJECT*`.

This approach gives Claude enough context to understand where to look when it's judgement decides to start looking, without overloading the context window.

> **You can update your memory scaffolding through:** `/updatememory`.
> *This will update your entire `$PROJECT` dir, with conditional elifs to prevent indirect documentation population.*
---

<u><h2> Section II</h2></u>
### Polymathic Delegation

*It would be weird if delegation wasn't polymathic, I mean... I named this project after an astute orphan.*

---

**What's the Hook?**

`UserPromptSubmit` will invoke the delegation. Delegation is determined through scoring.

<u>**Prompt Scoring Criteria:**</u>

| Score Range | Tier | Workflow | Agents |
|:-----------:|:----:|:--------:|:---:|
| 0-2 | Direct | None | None |
| 3-4 | Light | Solo | `explore-light-agent` |
| 5-6 | Medium | Parallel + sequential | `explore-light-agent, research-light-agent, Plan-agent` | |
| 7+ | Full | Parallel + sequential | `Explore-agent, research-lead-agent, Plan-agent` |

*Delegation will route specific subagents based on your prompt score.*

> The weighted system is based on **prompt length** & **keyword semantics**.
>  **Simple Keywords** are considered negative scoring.
>  **Complex Keywords** are considered positive scoring.
>  **Scoring-floor** prevents negative scoring.

| Prompt Length | Points Added |
|:-------------:|:------------:|
| > 100 chars | +1 |
| > 200 chars | +1 (cumulative) |
| > 400 chars | +2 (cumulative) |

| Simple | Points | Complex | Points |
|:-------------:|:------------:|:---:|:---:|
| fix typo \| rename | -4 | system \| architecture \| integrate| 3 |
| simple \| quick | -3 | across \| multiple | 2 |
| this file | -2 | best practice \| research | 3 |

> [!TIP]
>  **Configurability:**
>  
>  • scoring weights
>  
>  • keywords
>  
>  • prompt lengths
>  
>  • agentic routing
>  
>  
>  • delegation behaviors
>  
>  _Allowing full and complete control to your liking._

**<u>The implementation workflow in laymen's terms:</u>**

1. `edit | write` → `follow plan`
2. `run tests` → `fix` (3 loops)
3. `summarize` and `return results`

> _0+ scores inherit this workflow._

> _Scoring only affects the agents usages._

> **_For debugging your configurations:_**
> 
>  `DEBUG_MODE="OFF"` → `DEBUG_MODE="ON"`
> 
>  `DEBUG_LOG="${HOME}/.claude/smart-delegate.log"`

---

## In Development:

_Prioritizing this architecture by iterating upon during daily use. Refining where and when needed. The overall goal is to reinforce Claude's native **out-of-the-box** features, capabilities, and design mechanics - architecting a system that utilizes Claude to it's full potential._

**<u>As of **1/22/2026** the following agents are available:</u>**

`explore-light`
`research-light`
`research-lead`
`research-subagent`
`composter`

---

## Delegation Architecture
<U><h3>Feat. List</h3></u>

`sub-delegative capabilities`

`task-specific subagents`

`tool-specific subagents`

`more specialized subagents`

`enhance delegation workflow`

`...more`


#### FIRST PRIORITY:
* Tool based subagent `web-research-specialist` → high utility, low complexity
* Hook based subagent `bash-file-path-extractor` → context enricher, lower token usage
  
#### SECOND PRIORITY:
* Post implementation subagent `test-infra-agent`→ enhanced validation step
* Workflow/hook based subagent `reminder-nudger-agent`→  stagnation steering, reality-checker
* Metrics for `TodoWrite`

#### LAST PRIORITY:
* Extending delegation to subagentic delegation
* Contextually aware/plan based subagent `project-scaffold-deployment-agent` → setup frontend, backend, infra for new projects
* Full escalation protocol → loop prevention, edge cases, complex runs
  
  ---
  
  _Not all features/refinements were added to this section._
