# scripts/

Command-line entry points, plus two repo tools:

- `update_lock.sh` regenerates `requirements-lock.txt`, the exact versions CI installs. Run it after changing dependencies in `pyproject.toml`. Needs [uv](https://docs.astral.sh/uv/).
- `setup_github.sh` creates the GitHub milestones and labels for the schedule in `docs/milestones.md`. Run it once, after the repository exists on GitHub. Needs the [GitHub CLI](https://cli.github.com/), logged in.
