# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AIChat is an all-in-one LLM CLI tool written in Rust, featuring Shell Assistant, CMD & REPL Mode, RAG, AI Tools & Agents, and built-in HTTP server capabilities. It integrates with 20+ LLM providers through a unified interface.

## Build & Test Commands

### Build
```bash
cargo build                    # Debug build
cargo build --release          # Release build (with LTO, stripped, optimized)
```

### Run
```bash
cargo run                      # Run in REPL mode (default)
cargo run -- <args>            # Run with arguments in CMD mode
cargo run -- --serve           # Start HTTP server mode
```

### Test & Quality
```bash
cargo test --all              # Run all tests
cargo clippy --all --all-targets -- -D warnings  # Run linter
cargo fmt --all --check       # Check formatting
cargo fmt --all               # Format code
```

### Development Testing Scripts (via Argcfile.sh)

The project uses `argc` for development workflows. Key commands:

```bash
./Argcfile.sh test-init-config <args>       # Test config initialization
./Argcfile.sh test-no-config <args>         # Test without config file
./Argcfile.sh test-function-calling <args>  # Test function calling
./Argcfile.sh test-clients                  # Test all client integrations
./Argcfile.sh test-server                   # Test proxy server
./Argcfile.sh chat <args>                   # Quick chat testing
```

## Architecture Overview

### Core Modules (`src/`)

**Main Entry & Flow** (`main.rs`, `cli.rs`)
- Entry point determines working mode: `Serve`, `Repl`, or `Cmd`
- Uses Tokio async runtime
- Loads configuration, sets up logging, handles abort signals

**Configuration System** (`config/`)
- `mod.rs`: Main config structure, initialization, model/client management
- `role.rs`: Role system (custom prompts + model configs)
- `session.rs`: Conversation session management with compression
- `agent.rs`: Agent definitions (roles + tools + RAG documents)
- `input.rs`: Multi-form input handling (stdin, files, URLs, commands)

Config hierarchy: CLI args → environment variables → config files → defaults

**Client Abstraction** (`client/`)
- `mod.rs`: Client registry using `register_client!` macro
- Provider-specific implementations: `openai.rs`, `claude.rs`, `gemini.rs`, `bedrock.rs`, `vertexai.rs`, `cohere.rs`, `azure_openai.rs`
- `openai_compatible.rs`: Unified adapter for 18+ OpenAI-compatible providers
- `model.rs`: Model metadata and capabilities
- `message.rs`: Message format abstraction
- `stream.rs`: SSE streaming support
- `common.rs`: Shared client utilities

**REPL System** (`repl/`)
- `mod.rs`: REPL loop with 36+ dot commands (`.help`, `.model`, `.role`, `.session`, etc.)
- `completer.rs`: Tab completion for commands and paths
- `highlighter.rs`: Syntax highlighting for input
- `prompt.rs`: Custom prompt rendering with variables

**Function Calling** (`function.rs`)
- Loads function declarations from `functions.json`
- Executes tool calls via external binaries in `functions/bin/`
- Supports MCP (Model Context Protocol) integration
- Handles tool result evaluation and deduplication

**RAG System** (`rag/`)
- Document loading, chunking, embedding, and retrieval
- Vector similarity search using HNSW
- BM25 keyword search for hybrid retrieval
- `splitter/`: Language-aware document splitting

**HTTP Server** (`serve.rs`)
- OpenAI-compatible API endpoints (`/v1/chat/completions`, `/v1/embeddings`, `/v1/rerank`)
- Web playground and LLM arena interfaces
- Embedded static assets via `rust-embed`

**Rendering** (`render/`)
- Markdown rendering with syntax highlighting (via `syntect`)
- Theme support (Monokai Extended dark/light)
- Streaming output formatting

**Utilities** (`utils/`)
- Abort signal handling
- Clipboard integration (platform-specific via `arboard`)
- Command execution (`command.rs`)
- Path resolution and file loading
- Custom prompts and spinners

### Configuration Files

**User Configuration Directory** (`~/.config/aichat/`)
```
config.yaml              # Main config (models, behavior, clients)
.env                     # Environment variables
models-override.yaml     # Override model definitions
messages.md              # Message history
roles/                   # Role definitions (*.md files with frontmatter)
sessions/                # Session state (*.yaml)
rags/                    # RAG configurations (*.yaml)
macros/                  # Command macros (*.yaml)
functions/
  ├── functions.json     # Tool declarations
  ├── bin/               # Tool executables
  └── agents/            # Agent function directories
agents/                  # Agent runtime data
```

See `CONFIG.md` for detailed configuration documentation and environment variable overrides.

### Working Modes

1. **CMD Mode**: One-shot queries via command line
   - Supports multi-form input: `--file`, stdin, remote URLs
   - Shell assistant mode with `--execute` flag
   - Code generation with `--code` flag

2. **REPL Mode**: Interactive chat session
   - Persistent history and context
   - Dot commands for configuration
   - Session/role switching
   - Multi-line input support

3. **Serve Mode**: HTTP server
   - OpenAI-compatible API proxy
   - Web playground UI
   - LLM arena for model comparison

### Key Design Patterns

**Client Registration**: Uses declarative macro `register_client!` to register all provider implementations with unified interface

**Global Config**: Uses `Arc<RwLock<Config>>` (type alias: `GlobalConfig`) for thread-safe shared configuration across async tasks

**Streaming**: SSE parsing with `reqwest-eventsource`, manual chunk handling for providers with custom formats

**Theming**: Binary-embedded color schemes via `include_bytes!`, runtime theme selection based on terminal color detection

**Model Sync**: Can pull model definitions from remote YAML (`models.yaml`) to stay updated with provider changes

## Important Files

- `models.yaml`: Provider model definitions and capabilities
- `config.example.yaml`: Reference configuration with all options
- `config.agent.example.yaml`: Example agent definition
- `CONFIG.md`: Comprehensive configuration documentation
- `Cargo.toml`: Dependencies and release profile settings

## Testing Notes

- Tests require provider API keys via environment variables
- Use `AICHAT_CONFIG_DIR` to isolate test configurations
- `dry_run` flag prevents actual API calls in tests
- Function calling tests check tool registration and execution flow
