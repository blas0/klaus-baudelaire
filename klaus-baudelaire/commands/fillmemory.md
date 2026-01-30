---
description: Returns a complete analysis detailing the entire directory across multiple files with in the `$CLAUDE_PROJECT_DIR/.claude/project` directory.
allowed-tools: Bash, Grep, Glob, Edit
disable-model-invocation: true
---

# fillmemory

## CRITICAL/REQUIRED/BLOCKING: Scaffold Directory Structure

BEFORE filling memory documents, ensure the scaffolding structure exists.

```
CLAUDE_DIR="$CLAUDE_PROJECT_DIR/.claude"
RULES_DIR="$CLAUDE_DIR/rules"
PROJECT_DIR="$CLAUDE_DIR/project"
INDEX_FILE="$RULES_DIR/project-index.md"
```

Execute the following bash script to create directories and template files if they don't exist:

```bash
#!/bin/bash
set -euo pipefail

# Validate environment
if [ -z "${CLAUDE_PROJECT_DIR:-}" ]; then
  echo "Error: CLAUDE_PROJECT_DIR not set" >&2
  exit 1
fi

cd "$CLAUDE_PROJECT_DIR" || exit 1

# Define paths
CLAUDE_DIR="$CLAUDE_PROJECT_DIR/.claude"
RULES_DIR="$CLAUDE_DIR/rules"
PROJECT_DIR="$CLAUDE_DIR/project"
INDEX_FILE="$RULES_DIR/project-index.md"

# Function to check if file has content beyond templates
has_content() {
  local file="$1"
  [ ! -f "$file" ] && return 1
  grep -q "<excerpt>" "$file" && return 1
  return 0
}

# Check if ALL files exist and have content
for file in "$INDEX_FILE" "$PROJECT_DIR"/{architecture,frontend,backend,database,infrastructure,testing}.md "$PROJECT_DIR/standards"/{standards,coherence,patterns}.md; do
  if ! has_content "$file"; then
    all_populated=false
    break
  fi
done

if [ "$all_populated" = true ]; then
  echo "All documentation files already populated, skipping scaffold"
  exit 0
fi

# Back up existing rules/ and project/ if they exist
BACKUP_PATH="$CLAUDE_PROJECT_DIR/.backup.claude.rules-project"
if [ -d "$RULES_DIR" ] || [ -d "$PROJECT_DIR" ]; then
  echo "Backing up existing rules/ and project/ to .backup.claude.rules-project..."
  rm -rf "$BACKUP_PATH" 2>/dev/null || true
  mkdir -p "$BACKUP_PATH"
  [ -d "$RULES_DIR" ] && cp -r "$RULES_DIR" "$BACKUP_PATH/"
  [ -d "$PROJECT_DIR" ] && cp -r "$PROJECT_DIR" "$BACKUP_PATH/"
fi

# Create directories
mkdir -p "$RULES_DIR"
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/standards"

# Create project-index.md in rules
if has_content "$INDEX_FILE"; then
  echo "Skipping project-index.md (already populated)"
else
  echo "Creating project-index.md..."
  cat > "$INDEX_FILE" << 'INDEX_EOF'
# Project | Codebase Documentation

**Use bash to analyze/understand the project | codebase per the paths provided.**

See `$CLAUDE_PROJECT_DIR/.claude/project/architecture.md` for the project's | codebase's architecture.

See `$CLAUDE_PROJECT_DIR/.claude/project/frontend.md` for the documentation on the project's | codebase's frontend structure/implementation.

See `$CLAUDE_PROJECT_DIR/.claude/project/backend.md` for the documentation on the project's | codebase's backend structure/implementation.

See `$CLAUDE_PROJECT_DIR/.claude/project/database.md` for the documentation on the project's | codebase's database structure/implementation.

See `$CLAUDE_PROJECT_DIR/.claude/project/infrastructure.md` for the documentation on the project's | codebase's infrastructure structure/implementation.

See `$CLAUDE_PROJECT_DIR/.claude/project/testing.md` for the documentation on the project's | codebase's testing structure/implementation.
INDEX_EOF
fi

# Create architecture.md
if [ -f "$PROJECT_DIR/architecture.md" ]; then
  echo "Skipping architecture.md (already exists)"
else
  echo "Creating architecture.md..."
  cat > "$PROJECT_DIR/architecture.md" << 'ARCH_EOF'
<excerpt>
You are tasked with thoroughly analyzing the project directory located at $CLAUDE_PROJECT_DIR and proactively producing a comprehensive document that covers four key areas. First, clearly articulate the purpose and intention behind the project, explaining what problem it solves or what need it addresses. Second, provide an overview of the project that gives readers a solid understanding of its scope, functionality, and key features. Third, document the complete code stack, detailing all technologies, frameworks, libraries, and tools used throughout the project. Finally, create an ASCII tree diagram that visually represents the directory structure and scaffolding of $CLAUDE_PROJECT_DIR, showing how files and folders are organized within the project. Deleting this excerpt after completing the task.
</excerpt>
ARCH_EOF
fi

# Create frontend.md
if [ -f "$PROJECT_DIR/frontend.md" ]; then
  echo "Skipping frontend.md (already exists)"
else
  echo "Creating frontend.md..."
  cat > "$PROJECT_DIR/frontend.md" << 'FRONTEND_EOF'
<excerpt>
Your task is to thoroughly analyze the project directory at $CLAUDE_PROJECT_DIR and proactively complete this document with comprehensive information about the frontend architecture. Include detailed coverage of the design patterns and architectural approach, the complete technology stack and code frameworks being used, all libraries and their purposes, the component structure and hierarchy, UI/UX styling methodologies and design systems, and all frontend components and elements. Additionally, establish clear mappings that show how these frontend elements connect to and interact with the backend systems, database layer, and infrastructure as documented in the infrastructure.md file located at $CLAUDE_PROJECT_DIR/.claude/project. Ensure your analysis captures both the technical implementation details and the relationships between frontend and backend layers. Deleting this excerpt after completing the task.
</excerpt>
FRONTEND_EOF
fi

# Create backend.md
if [ -f "$PROJECT_DIR/backend.md" ]; then
  echo "Skipping backend.md (already exists)"
else
  echo "Creating backend.md..."
  cat > "$PROJECT_DIR/backend.md" << 'BACKEND_EOF'
<excerpt>
Your task is to thoroughly analyze the project directory located at $CLAUDE_PROJECT_DIR and proactively populate this document with comprehensive information about the project's technical structure. Specifically, you should document the backend architecture design, including all components and their organization. Detail the complete code stack being used, covering frameworks, libraries, and technologies. Map out all API connections, describing endpoints, data flows, and integration points. Identify and describe the services utilized throughout the project, whether internal or external. Finally, trace and document the direct paths showing how the backend connects to and interacts with the frontend, database, and infrastructure, with particular attention to any configuration or infrastructure files located in the $CLAUDE_PROJECT_DIR/.claude/project directory. Your analysis should provide a clear, complete picture of how all these elements wire together to form the functioning system. Deleting this excerpt after completing the task.
</excerpt>
BACKEND_EOF
fi

# Create database.md
if [ -f "$PROJECT_DIR/database.md" ]; then
  echo "Skipping database.md (already exists)"
else
  echo "Creating database.md..."
  cat > "$PROJECT_DIR/database.md" << 'DATABASE_EOF'
<excerpt>
Your task is to thoroughly analyze the project directory located at $CLAUDE_PROJECT_DIR and proactively populate this document with comprehensive information about the project's database architecture. Specifically, you should document the database type and technology (SQL, NoSQL, etc.), schema design and data models, relationships between entities, migration strategies, and query patterns. Detail any ORM/ODM usage, connection pooling, caching layers, and data access patterns. Map out backup strategies, replication setups, and performance optimization approaches. Your analysis should provide a clear, complete picture of how data is stored, accessed, and managed throughout the system. Deleting this excerpt after completing the task.
</excerpt>
DATABASE_EOF
fi

# Create infrastructure.md
if [ -f "$PROJECT_DIR/infrastructure.md" ]; then
  echo "Skipping infrastructure.md (already exists)"
else
  echo "Creating infrastructure.md..."
  cat > "$PROJECT_DIR/infrastructure.md" << 'INFRA_EOF'
<excerpt>
Your task is to thoroughly analyze the project directory located at $CLAUDE_PROJECT_DIR and proactively populate this document with comprehensive information about the project's infrastructure setup. Specifically, you should document the deployment architecture, including hosting platforms, cloud providers, and environment configurations. Detail the CI/CD pipeline structure, covering build processes, deployment workflows, and automation scripts. Map out all containerization and orchestration configurations, describing Dockerfiles, compose files, and Kubernetes manifests if present. Identify and describe infrastructure-as-code resources, including Terraform, CloudFormation, or similar tooling. Finally, trace and document the environment management approach showing how development, staging, and production environments are configured and isolated. Your analysis should provide a clear, complete picture of how all these elements wire together to deploy and operate the functioning system. Deleting this excerpt after completing the task.
</excerpt>
INFRA_EOF
fi

# Create testing.md
if [ -f "$PROJECT_DIR/testing.md" ]; then
  echo "Skipping testing.md (already exists)"
else
  echo "Creating testing.md..."
  cat > "$PROJECT_DIR/testing.md" << 'TESTING_EOF'
<excerpt>
Your task is to thoroughly analyze the project directory located at $CLAUDE_PROJECT_DIR and proactively populate this document with comprehensive information about the project's testing infrastructure. Specifically, you should document the testing strategy and architecture, including all test types implemented such as unit, integration, and end-to-end tests. Detail the testing frameworks and tools being used, covering assertion libraries, mocking utilities, and coverage reporters. Map out the test organization structure, describing how tests are grouped, named, and executed. Identify and describe fixture management, test data generation, and environment isolation approaches. Finally, trace and document the CI integration showing how tests are triggered, parallelized, and reported within the deployment pipeline. Your analysis should provide a clear, complete picture of how quality assurance is implemented and maintained across the functioning system. Deleting this excerpt after completing the task.
</excerpt>
TESTING_EOF
fi

# Create standards.md
if [ -f "$PROJECT_DIR/standards/standards.md" ]; then
  echo "Skipping standards.md (already exists)"
else
  echo "Creating standards.md..."
  cat > "$PROJECT_DIR/standards/standards.md" << 'STANDARDS_EOF'
[introduction]
Standards exist to establish a non-negotiable baseline of uniformity, ensuring that every file appears as though it was written by a single author regardless of team size. Their intent is to eliminate cognitive friction caused by stylistic differences so developers can focus entirely on logic rather than formatting.
[end-introduction]

## Code Style Standards
<!-- Naming conventions, formatting rules, file structure -->

## Documentation Standards
<!-- Comment style, README structure, inline docs -->

## Commit & Version Standards
<!-- Commit message format, versioning approach, changelog -->

## Import & Dependency Standards
<!-- Import ordering, aliasing, dependency management -->

## Examples
<!-- Real code examples extracted from this codebase -->
STANDARDS_EOF
fi

# Create coherence.md
if [ -f "$PROJECT_DIR/standards/coherence.md" ]; then
  echo "Skipping coherence.md (already exists)"
else
  echo "Creating coherence.md..."
  cat > "$PROJECT_DIR/standards/coherence.md" << 'COHERENCE_EOF'
[introduction]
Coherence ensures the entire system adheres to a unified logical philosophy, making the behavior of unknown modules predictable based on the behavior of known ones. Its intent is to minimize the mental effort required to navigate the codebase by guaranteeing that similar concepts are implemented in consistent ways across the application.
[end-introduction]

## Error Handling Philosophy
<!-- How errors are consistently handled across modules -->

## State Management Philosophy
<!-- How state is managed, updated, and synchronized -->

## Data Flow Philosophy
<!-- How data moves through the system -->

## Naming Philosophy
<!-- Conceptual consistency in naming across domains -->

## Examples
<!-- Real implementations showing coherent patterns -->
COHERENCE_EOF
fi

# Create patterns.md
if [ -f "$PROJECT_DIR/standards/patterns.md" ]; then
  echo "Skipping patterns.md (already exists)"
else
  echo "Creating patterns.md..."
  cat > "$PROJECT_DIR/standards/patterns.md" << 'PATTERNS_EOF'
[introduction]
Patterns serve as reusable structural blueprints that provide proven, pre-agreed solutions to recurring architectural problems. Their intent is to accelerate development and streamline communication by creating a shared technical vocabulary that everyone on the team understands immediately.
[end-introduction]

## Architectural Patterns
<!-- High-level structural patterns (e.g., MVC, layered, event-driven) -->

## Design Patterns
<!-- Common design patterns in use (e.g., Factory, Observer, Strategy) -->

## Integration Patterns
<!-- How components/services integrate (e.g., API contracts, event schemas) -->

## Data Patterns
<!-- Data access, transformation, validation patterns -->

## Examples
<!-- Real implementations with file paths and code snippets -->
PATTERNS_EOF
fi

  echo "Memory scaffold complete"
  exit 0
  ```

## Phase 2: Fill Memory Documents

After scaffolding is complete, invoke 6 @"explore-light (agent)" agents in parallel to follow the instructions/task defined within the `<excerpt>` tags in each of these files:
- `$CLAUDE_PROJECT_DIR/.claude/project/architecture.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/frontend.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/backend.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/database.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/infrastructure.md`
- `$CLAUDE_PROJECT_DIR/.claude/project/testing.md`

Do NOT process files in the `standards/` subdirectory. Standards documentation should be maintained separately.
