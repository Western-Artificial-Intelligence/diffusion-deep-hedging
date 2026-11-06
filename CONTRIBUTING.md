# Contributing

## Branches and pull requests

- Branch from `main` and name the branch `<your-name>/<short-topic>`, for example `maya/heston-sim`.
- One pull request per task. Keep it under about 400 changed lines where you can. Small PRs get read; big ones get skimmed.
- Fill in the PR template, link the issue it closes, and attach plots as PNG images.
- A PR merges when CI passes and one reviewer approves. Pushing new commits dismisses the approval, so the reviewer sees the final version.
- In Phase 1, Ethan reviews everything. From December, Dev 1 and Dev 2 review each other, and Dev 3 and Ethan review each other.

## The AI rule

Use AI tools however you like. The rule is that you can explain every line of every PR you open, and the reviewer will ask. Code you can't explain doesn't merge.

## Tests

- Every module gets a test file under `tests/`, mirroring the package layout.
- Prefer checks with known answers: closed-form values, limiting cases, properties that must hold, a small case worked out by hand.
- Mark tests over about ten seconds with `@pytest.mark.slow` and tests that need files in `data/` with `@pytest.mark.data`. CI skips both, so run them locally before merging anything that produces results.
- Every function that draws random numbers takes a seed or a generator and never touches the global random state.

## Data and the firewall

- Nothing in `data/` or `results/` is committed. Git ignores both folders and common data file types.
- Code that fits a simulator calls the firewall guard, which rejects any date after December 31, 2016.
- Data source, licence and storage rules are in `docs/data_decision.md`.

## Notebooks

- Notebooks are for tasks and exploration. The package never imports from `notebooks/`.
- For a task, copy the template to `<your-github-username>.ipynb` in the task's folder, so two people never edit the same file.
- Save the plots a reviewer needs as PNG files next to your notebook. GitHub shows notebook diffs badly.
- Clear large outputs before committing.

## Conventions

Shapes, units, time steps and seeds follow `docs/apis.md`. Until the interfaces freeze on November 24, raise disagreements in a PR against that file. After the freeze, a change needs an entry in `docs/decisions.md` and the agreement of every owner it affects.

## When you're stuck

Re-read the check, write the smallest test that fails, then ask in the channel with what you tried. Twenty-four hours stuck is the limit before you post.
