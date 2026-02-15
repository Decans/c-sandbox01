# Claude Code Instructions

## Build Environment

This project uses a devcontainer with Clang on Debian. The workspace is bind-mounted at `/workspace`.

Build, run, and test commands should be executed inside the container via:
```
docker compose exec dev <command>
```

For example:
```
docker compose exec dev make
docker compose exec dev ./your_program
```

## Documentation

When making changes that affect the project structure, build targets, tooling, dependencies, or developer workflow, update `README.md` to reflect those changes. This includes but is not limited to:

- Adding, removing, or renaming source files, directories, or modules
- Adding or modifying Makefile targets
- Changing compiler flags or build configuration
- Adding dependencies or git submodules
- Changing how the project is cloned, built, run, or tested
