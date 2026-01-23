<p align="center">
  <h1 align="center">
    <u>Who is Klaus Baudelaire?</u>
  </h1>
</p>

<p align="center">
  <img src="klaus_claude.jpg" alt="klaus baudelaire" width="600">
</p>

---

<p align="center">
  <strong>
      Klaus was designed from the architectural design of the Claude Code harness, specifically around the focality of hard embedded idiosyncrasies within Claude Code. Utilizing its features, native capabilities, and <i>spunkiness</i>. This architecture explores refinement and reinforcing the Claude Code CLI harness.
  </strong>
</p

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

---

**Mission Statement:**
_The core focus for Klaus is to reinforce and refine Claude Code's native **out-of-the-box** features, capabilities, and architectural design mechanics. Brainstorming, researching, planning and designing this system based on abstractions, documentation, blogs, & notable novelties made/created/posted by Anthropic. Treating Klaus as a child of Claude - a system that is aligned through and by Anthropics's own mission of AI safety._

---

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

## Section I

### Managing Memory

*I understand that everyone has their own method/approach of managing memory. Letting an agent manage your codebase memory can cause technical debt, which is why I specifically designed it according to Claude's native design. The documentation is referenced above above. I made these commands manually invocable to prevent edge cases from execution of wandered judgement.*

---

> **`/fillmemory`** executes a conditional elif memory dir/doc scaffolding within the:
`$CLAUDE_PROJECT_DIR/.claude` directory. Backing up preexisting `$RULES/ | $PROJECT/` dirs to a folder.

> **`/fillmemory`** executes agents in parallel to follow the  instructions defined by the `$VARIABLE` in the content of each `.md` within the `$PROJECT` dir *(excluding `$STANDARDS`)*

> **`/compost`** replicates the same behavior as **`/fillmemory`** except with one specialized agent designed for populating the `$STANDARDS` `.md` documentation.

Each document within the scaffolding contains `$VARIABLES` & `$INSTRUCTIONS` for the agent to follow during the `/fillmemory | /compost` execution - updating the documentation files - post scaffolding.

**The scaffolding covers:**

```bash
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

## Section II

### Polymathic Delegation

*It would be weird if delegation wasn't polymathic, I mean... I did name this project after an astute orphan.*

---

**What's the Hook?**

`UserPromptSubmit` will invoke the delegation. Delegation is determined through scoring.

**Prompt Scoring Criteria:**

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

>  **Easy to Configure right out-of-the-box:**
>  
>  • scoring weights
>  
>  • keywords
>  
>  • prompt lengths
>  
>  • agentic routing
>  
>  • delegation behaviors
>  
> _Note: Configuring the system to be more submissive in terms of invoking delegations may cause thirstier token consumption._

**The implementation workflow in laymen's terms:**

1. `edit | write` → `follow plan`
2. `run tests` → `fix` (3 loops)
3. `summarize` and `return results`

> _Prompt scoring isn't affected by the workflow._

> _Scoring only determines the initial agentic invocations._

> **_For debugging your configurations:_**
> 
>  `DEBUG_MODE="OFF"` → `DEBUG_MODE="ON"`
> 
>  `DEBUG_LOG="${HOME}/.claude/smart-delegate.log"`

---

## Future Development:

**Mission Statement:**
_The core focus for Klaus is to reinforce and refine Claude Code's native **out-of-the-box** features, capabilities, and architectural design mechanics. Brainstorming, researching, planning and designing this system based on abstractions, documentation, blogs, & notable novelties made/created/posted by Anthropic. Treating Klaus as a child of Claude - a system that is aligned through and by Anthropics's own mission of AI safety._

---

  1. `project-scaffold-agent`
  - Purpose: Initialize/scaffold project deployments (backend/frontend/deployment/infra/etc.)
  - Model: Sonnet
  - Tools: Write, Edit, Bash, Read

  2. Sub-delegation Extensions
  - Purpose: Extend research-lead pattern to other agents
  - Would allow agents to spawn their own sub-agents
  - Configuration: MAX_DELEGATION_DEPTH=3, MAX_SUBAGENTS_PER_LEAD=20

  3. Full Escalation Protocol
  - Purpose: Automated escalation hooks for reminder-nudger-agent
  - Would integrate reminder system with SubagentStop hooks
  - Would automatically inject reminders at stagnation thresholds

  4. Hook Integration for file-path-extractor
  - Purpose: PostToolUse hook to automatically invoke file-path-extractor
  after bash commands
  - Would automatically track file context without manual invocation

---

Thank you for getting to the end of this document. I have rewritten this about 4 times by hand because I have no idea how to capture people's attention & I felt as if my direction with this document needed to have some sort of sentiment with the reader. I really do appreciate it.

PR's are welcome.
