# C/Clang Development Environment in Docker

A fully containerized C programming environment using Clang, Docker, and VS Code Dev Containers. Nothing needs to be installed on your host machine except Docker and VS Code — the compiler, debugger, linter, and all other tools run entirely inside the container.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [What's Inside the Docker Container](#whats-inside-the-docker-container)
- [Using VS Code (Dev Container Workflow)](#using-vs-code-dev-container-workflow)
  - [Opening the Project](#opening-the-project)
  - [Building and Running](#building-and-running)
  - [Modifying VS Code Settings](#modifying-vs-code-settings)
  - [Debugging a C Program](#debugging-a-c-program)
- [Using the Terminal (Standalone Workflow)](#using-the-terminal-standalone-workflow)
- [Writing Your Own Code](#writing-your-own-code)
- [Testing](#testing)
- [Makefile Reference](#makefile-reference)
- [Using Git](#using-git)
- [Running This on Another Machine](#running-this-on-another-machine)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

You need exactly two things installed on your host machine:

1. **Docker Desktop** — [Download here](https://www.docker.com/products/docker-desktop/)
   - Make sure Docker is running before you start (you should see the Docker icon in your menu bar / system tray)
2. **Visual Studio Code** — [Download here](https://code.visualstudio.com/)
   - Install the **Dev Containers** extension (`ms-vscode-remote.remote-containers`). VS Code will prompt you to install it when you open this project, or you can install it manually from the Extensions sidebar.

That's it. You do **not** need to install Clang, Make, GDB, or any C toolchain on your host machine.

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd c_sandbox01

# Option A: Open in VS Code and use Dev Containers (recommended)
code .
# VS Code will prompt "Reopen in Container" — click it

# Option B: Build and run from the terminal
docker compose build
docker compose run --rm dev make run
# Output: Hello from clang in Docker!
```

## Project Structure

```
c_sandbox01/
├── .devcontainer/
│   └── devcontainer.json      # Dev Container configuration for VS Code
├── .vscode/
│   ├── extensions.json        # Recommended VS Code extensions
│   ├── settings.json          # Editor settings (formatting, C standard, etc.)
│   └── tasks.json             # Build/Run/Clean tasks (Cmd+Shift+B)
├── src/
│   ├── main.c                 # Program entry point
│   ├── greeter.h              # Header for greeting module
│   └── greeter.c              # Greeting implementation
├── test/
│   └── test_greeter.c         # Unit tests for greeter module
├── unity/                     # Unity test framework (git submodule)
├── build/                     # Compiled output (auto-created, git-ignored)
├── .gitignore                 # Ignores build artifacts, OS files, editor temps
├── Dockerfile                 # Defines the container image and installed tools
├── docker-compose.yml         # Configures the dev service and volume mounts
├── Makefile                   # Build system: compile, run, clean, test targets
└── README.md                  # This file
```

### Where your code lives

- **Source code** goes in `src/`. Add `.c` and `.h` files here.
- **Tests** go in `test/`. Each test file should include `unity.h` and the header for the module under test.
- **Compiled output** goes in `build/`. This directory is created automatically by `make` and is git-ignored.

## What's Inside the Docker Container

The container is built from `debian:bookworm-slim` (a minimal Debian 12 image) and includes:

| Tool             | Purpose                                              |
|------------------|------------------------------------------------------|
| `clang`          | C compiler (used instead of GCC)                     |
| `clang-format`   | Automatic code formatting (enforces consistent style)|
| `clang-tidy`     | Static analysis / linting for C code                 |
| `make`           | Build automation (reads the `Makefile`)               |
| `gdb`            | Interactive debugger for stepping through code        |
| `valgrind`       | Memory error detector (finds leaks, invalid reads)    |

### What is NOT in the container

- No text editor or IDE — VS Code runs on your host and connects into the container
- No Git — Git runs on your host machine (your files are bind-mounted into the container)
- No GUI tools — everything is command-line based inside the container

### How the bind mount works

The `docker-compose.yml` maps your project directory (`.`) on the host to `/workspace` inside the container. This means:

- Files you edit in VS Code are immediately visible inside the container
- Files the compiler creates (in `build/`) are immediately visible on your host
- You are editing real files on disk, not copies — there is no sync delay

## Using VS Code (Dev Container Workflow)

This is the **recommended** way to use this project. VS Code runs on your machine but operates entirely inside the Docker container — the terminal, IntelliSense, compiler, and debugger all run in the container.

### Opening the Project

1. **Launch VS Code** — open it from your Applications folder, Dock, Start Menu, or by running `code .` in a terminal from the project directory.

2. **Open the project folder** — if you didn't use `code .`, go to `File > Open Folder...` (or `Cmd+O` on macOS / `Ctrl+K Ctrl+O` on Windows/Linux) and select the `c_sandbox01` folder.

3. **Reopen in Container** — VS Code will detect the `.devcontainer/devcontainer.json` file and show a notification in the bottom-right corner:

   > "Folder contains a Dev Container configuration file. Reopen folder to develop in a container."

   Click **"Reopen in Container"**.

   If you miss the notification, open the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`) and run:
   ```
   Dev Containers: Reopen in Container
   ```

4. **Wait for the build** — the first time, Docker will build the image (downloads Debian, installs Clang, etc.). This takes a few minutes. Subsequent opens are fast because Docker caches the image.

5. **You're in** — the bottom-left corner of VS Code will show `Dev Container: C (Clang)`. The integrated terminal is now a shell inside the container.

### Building and Running

Once inside the Dev Container, you have several ways to build and run your code:

**Using keyboard shortcuts (recommended):**

| Action | Shortcut | What it does |
|--------|----------|-------------|
| Build  | `Cmd+Shift+B` (macOS) / `Ctrl+Shift+B` (Windows/Linux) | Compiles all `.c` files in `src/` into `build/main` |
| Run a task | `Cmd+Shift+P` > "Tasks: Run Task" | Choose Build, Run, or Clean |

**Using the integrated terminal:**

Open the terminal with `` Ctrl+` `` (backtick) and run:

```bash
make          # Compile (same as 'make build')
make run      # Compile and run
make test     # Compile and run unit tests
make clean    # Delete all compiled files
```

**Understanding build output:**

When you build, the compiler output looks like this:
```
clang -Wall -Wextra -Werror -std=c17 -g -c -o build/main.o src/main.c
clang -Wall -Wextra -Werror -std=c17 -g -o build/main build/main.o
```

If there are warnings or errors, they'll appear as clickable links in the VS Code terminal (thanks to the `$gcc` problem matcher in `tasks.json`). Clicking an error jumps you to the exact file and line.

### Modifying VS Code Settings

VS Code settings for this project live in two places:

**1. `.vscode/settings.json` — editor behavior (shared with all contributors)**

This file is committed to git and controls how VS Code behaves when editing this project. Current settings:

```json
{
  "files.associations": { "*.c": "c", "*.h": "c" },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "xaver.clang-format",
  "C_Cpp.default.cStandard": "c17",
  "editor.tabSize": 4,
  "editor.insertSpaces": true
}
```

To modify these:
1. Open `.vscode/settings.json` directly from the file explorer, or
2. Open the Command Palette (`Cmd+Shift+P`) > "Preferences: Open Workspace Settings (JSON)"

Common changes you might make:
- **Disable format-on-save**: Set `"editor.formatOnSave": false`
- **Change the C standard**: Set `"C_Cpp.default.cStandard"` to `"c11"`, `"c99"`, etc.
- **Change tab size**: Set `"editor.tabSize"` to `2` or `8`

**2. `.devcontainer/devcontainer.json` — container-specific settings**

This controls which extensions are installed inside the container and the compiler path for IntelliSense. You generally don't need to change this unless you want to add more extensions to the container.

To add an extension that should run inside the container, add its ID to the `extensions` array:
```json
"extensions": [
    "ms-vscode.cpptools",
    "xaver.clang-format",
    "notskm.clang-tidy",
    "your.new-extension-id"
]
```

After changing `devcontainer.json`, rebuild the container: `Cmd+Shift+P` > "Dev Containers: Rebuild Container".

**3. Your personal VS Code settings**

Your global VS Code settings (`Cmd+,` > User tab) still apply inside the Dev Container but are overridden by workspace settings. If something looks different inside the container, check `.vscode/settings.json` first.

### Debugging a C Program

The project compiles with `-g` (debug symbols) by default, so binaries are always ready for debugging.

#### Method 1: Using GDB in the Terminal

Open the integrated terminal (`` Ctrl+` ``) and run:

```bash
# Build first
make

# Start GDB with your program
gdb build/main
```

Common GDB commands:

| Command | Short | What it does |
|---------|-------|-------------|
| `run` | `r` | Start the program |
| `break main` | `b main` | Set a breakpoint at the `main` function |
| `break main.c:5` | `b main.c:5` | Set a breakpoint at line 5 of main.c |
| `next` | `n` | Execute the next line (step over function calls) |
| `step` | `s` | Step into a function call |
| `print x` | `p x` | Print the value of variable `x` |
| `backtrace` | `bt` | Show the call stack |
| `continue` | `c` | Continue running until the next breakpoint |
| `quit` | `q` | Exit GDB |

Example debugging session:
```bash
$ gdb build/main
(gdb) break main
Breakpoint 1 at 0x...: file src/main.c, line 4.
(gdb) run
Starting program: /workspace/build/main

Breakpoint 1, main () at src/main.c:4
4           printf("Hello from clang in Docker!\n");
(gdb) next
Hello from clang in Docker!
5           return 0;
(gdb) quit
```

#### Method 2: Using the VS Code Graphical Debugger

To use VS Code's built-in debug UI with breakpoints, variable inspection, and step controls:

1. **Create a launch configuration** — create the file `.vscode/launch.json` with this content:

   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Debug (GDB)",
         "type": "cppdbg",
         "request": "launch",
         "program": "${workspaceFolder}/build/main",
         "args": [],
         "cwd": "${workspaceFolder}",
         "MIMode": "gdb",
         "miDebuggerPath": "/usr/bin/gdb",
         "preLaunchTask": "Build",
         "setupCommands": [
           {
             "description": "Enable pretty-printing for GDB",
             "text": "-enable-pretty-printing",
             "ignoreFailures": true
           }
         ]
       }
     ]
   }
   ```

2. **Set a breakpoint** — click in the gutter (the space to the left of a line number) in any `.c` file. A red dot appears.

3. **Start debugging** — press `F5` or go to `Run > Start Debugging`. The program will compile (via the `preLaunchTask`), launch, and pause at your breakpoint.

4. **Use the debug toolbar** — once paused, use the toolbar at the top of the editor:

   | Button | Shortcut | Action |
   |--------|----------|--------|
   | Continue | `F5` | Run to the next breakpoint |
   | Step Over | `F10` | Execute the current line |
   | Step Into | `F11` | Enter a function call |
   | Step Out | `Shift+F11` | Finish the current function |
   | Restart | `Cmd+Shift+F5` | Restart debugging |
   | Stop | `Shift+F5` | Stop the program |

5. **Inspect variables** — while paused, hover over any variable in the editor to see its value. The "Variables" panel in the sidebar shows all local and global variables. The "Watch" panel lets you track specific expressions.

#### Method 3: Using Valgrind for Memory Debugging

Valgrind detects memory leaks, use-after-free, buffer overflows, and uninitialized reads. Run it from the terminal:

```bash
make
valgrind ./build/main
```

For more detail:
```bash
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./build/main
```

A clean program produces output like:
```
==123== HEAP SUMMARY:
==123==     in use at exit: 0 bytes in 0 blocks
==123==   total heap usage: 1 allocs, 1 frees, 1,024 bytes allocated
==123==
==123== All heap blocks were freed -- no leaks are possible
```

## Using the Terminal (Standalone Workflow)

If you prefer not to use VS Code, you can do everything from a terminal:

```bash
# Build the Docker image (first time or after changing the Dockerfile)
docker compose build

# Compile and run
docker compose run --rm dev make run

# Just compile
docker compose run --rm dev make

# Run unit tests
docker compose run --rm dev make test

# Clean build artifacts
docker compose run --rm dev make clean

# Open an interactive shell inside the container
docker compose run --rm dev bash

# Run GDB inside the container
docker compose run --rm dev gdb build/main

# Run Valgrind inside the container
docker compose run --rm dev valgrind ./build/main
```

The `--rm` flag removes the container after it exits so you don't accumulate stopped containers.

## Testing

This project uses the [Unity](https://github.com/ThrowTheSwitch/Unity) unit testing framework, included as a git submodule in `unity/`.

### Running tests

```bash
make test
```

This compiles all test files in `test/` along with the source modules (excluding `main.c`) and Unity, then runs the resulting test binary. Output looks like:

```
test/test_greeter.c:14:test_greeting_returns_expected_string:PASS

-----------------------
1 Tests 0 Failures 0 Ignored
OK
```

### Writing a new test

1. Create a test file in `test/`, e.g. `test/test_mymodule.c`:

   ```c
   #include "unity.h"
   #include "mymodule.h"

   void setUp(void) {}
   void tearDown(void) {}

   void test_something(void) {
       TEST_ASSERT_EQUAL(42, my_function());
   }

   int main(void) {
       UNITY_BEGIN();
       RUN_TEST(test_something);
       return UNITY_END();
   }
   ```

2. Run `make test` — the Makefile automatically picks up all `.c` files in `test/`.

### How the test target works

The `make test` target compiles test files with:
- `-Isrc` so test files can `#include` your module headers
- `-Iunity/src` so test files can `#include "unity.h"`
- All source files from `src/` except `main.c` (to avoid duplicate `main` symbols)
- Unity's `unity.c` implementation

The test binary is built at `build/test_runner`.

### Cloning with tests

Since Unity is a git submodule, clone with `--recurse-submodules`:

```bash
git clone --recurse-submodules <your-repo-url>
```

If you already cloned without it, initialize the submodule:

```bash
git submodule update --init
```

## Writing Your Own Code

### Adding a new source file

1. Create your file in `src/`, for example `src/utils.c` and `src/utils.h`
2. Include the header in `main.c`:
   ```c
   #include "utils.h"
   ```
3. Run `make` — the Makefile automatically picks up all `.c` files in `src/`

### How the Makefile finds your files

The Makefile uses a wildcard to find all source files:
```makefile
SRCS = $(wildcard $(SRC_DIR)/*.c)
```

Every `.c` file in `src/` is compiled into a corresponding `.o` file in `build/`, then all `.o` files are linked into `build/main`. You don't need to edit the Makefile when adding new source files.

### Compiler flags explained

```makefile
CFLAGS = -Wall -Wextra -Werror -std=c17 -g -Isrc
```

| Flag | Meaning |
|------|---------|
| `-Wall` | Enable common warnings |
| `-Wextra` | Enable additional warnings |
| `-Werror` | Treat all warnings as errors (forces you to fix them) |
| `-std=c17` | Use the C17 standard |
| `-g` | Include debug symbols (required for GDB and Valgrind) |
| `-Isrc` | Add `src/` to the include path so headers resolve with `#include "header.h"` |

If `-Werror` is too strict while you're experimenting, remove it from the `CFLAGS` line in the Makefile.

## Using Git

Git runs on your **host machine**, not inside the Docker container. This is by design — your SSH keys, Git config, and credentials live on the host.

### Basic workflow

```bash
# Check what's changed
git status

# Stage and commit
git add src/main.c
git commit -m "Add feature X"

# Push to remote
git push
```

### What's tracked and what's ignored

The `.gitignore` file excludes:

| Pattern | What it ignores |
|---------|----------------|
| `build/` | Compiled binaries and object files |
| `*.o` | Object files (if any end up outside `build/`) |
| `*.dSYM/` | macOS debug symbol bundles |
| `.DS_Store` | macOS Finder metadata |
| `*.swp`, `*.swo`, `*~` | Vim/editor swap and backup files |

Everything else is tracked, including all configuration files (`.devcontainer/`, `.vscode/`, `Dockerfile`, etc.). This is intentional — when someone clones the repo, they get the full development environment.

### What to commit

**Always commit:**
- Source code (`src/`)
- Build configuration (`Makefile`, `Dockerfile`, `docker-compose.yml`)
- Editor configuration (`.vscode/`, `.devcontainer/`)
- `.gitignore`

**Never commit:**
- `build/` directory (compiled output)
- `.DS_Store` or other OS-specific files
- Personal IDE settings that aren't in `.vscode/`

## Running This on Another Machine

This project is designed to be fully portable. Here's what someone needs to get up and running:

### Requirements on the new machine

1. **Docker Desktop** — [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. **Visual Studio Code** — [code.visualstudio.com](https://code.visualstudio.com/)
3. **Dev Containers extension** — install `ms-vscode-remote.remote-containers` from the VS Code Extensions sidebar
4. **Git** — to clone the repository

### Steps

```bash
# 1. Clone the repo (--recurse-submodules pulls in the Unity test framework)
git clone --recurse-submodules <your-repo-url>
cd c_sandbox01

# 2. Open in VS Code
code .

# 3. Click "Reopen in Container" when prompted
#    (or Cmd+Shift+P > "Dev Containers: Reopen in Container")

# 4. Wait for the image to build (first time only)

# 5. Start coding — make run in the terminal, or Cmd+Shift+B to build
```

That's it. The Docker image builds automatically from the Dockerfile, all VS Code extensions install automatically inside the container, and all settings are applied from the committed `.vscode/` directory. The experience is identical across macOS, Windows, and Linux.

### Platform notes

| Platform | Notes |
|----------|-------|
| **macOS** | Works out of the box with Docker Desktop |
| **Windows** | Use WSL 2 backend for Docker Desktop (this is the default). Git should be configured with `core.autocrlf=input` to avoid line ending issues |
| **Linux** | Install Docker Engine (Docker Desktop is optional). Make sure your user is in the `docker` group (`sudo usermod -aG docker $USER`) |

### No Docker? No problem.

If you have Clang installed natively, you can still build without Docker:

```bash
make run
```

The Makefile doesn't depend on Docker — it just calls `clang` and `make`. The Docker setup is there to guarantee a consistent environment, but it's not a hard requirement for building the code itself.

## Troubleshooting

### "Reopen in Container" doesn't appear

- Make sure Docker Desktop is running
- Install the Dev Containers extension: `ms-vscode-remote.remote-containers`
- Open the Command Palette (`Cmd+Shift+P`) and search for "Dev Containers: Reopen in Container"

### The container build is slow

The first build downloads Debian and installs packages (~500 MB). Subsequent builds are cached and take seconds. If you change the `Dockerfile`, Docker rebuilds from the changed layer onward.

### IntelliSense shows errors but the code compiles fine

- Make sure you're inside the Dev Container (check the bottom-left corner of VS Code)
- Run `Cmd+Shift+P` > "C/C++: Reset IntelliSense Database"
- Verify the compiler path is set: the `devcontainer.json` sets `C_Cpp.default.compilerPath` to `/usr/bin/clang`

### "Permission denied" on build artifacts

If `build/` was created by Docker with root ownership:
```bash
sudo rm -rf build/
make
```

### Valgrind reports errors in system libraries

Valgrind may show warnings from standard library internals (like `printf`). These are usually false positives. Focus on reports that reference your source files (`src/*.c`).

### Port conflicts with Docker

If you get "port already in use" errors, another container may be running:
```bash
docker compose down
docker compose run --rm dev make run
```
