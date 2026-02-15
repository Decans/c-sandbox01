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
