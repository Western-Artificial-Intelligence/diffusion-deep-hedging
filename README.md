# Diffusion-Generated Market Environments for Risk-Averse Deep Hedging under Transaction Costs

A Western AI Club research project, 2026-27, ending at CUCAI in March 2027.

We train the same neural hedging agent in five simulated markets of increasing realism (GBM, Heston, a stationary bootstrap of real history, a GAN and a conditional diffusion model) and test every agent in every simulator and on real S&P 500 options from 2017 to 2026. No simulator sees data after 2016. The question is how much the choice of training simulator decides how well an agent hedges in the real market.

Start with these, in this order:

- [docs/primer.md](docs/primer.md): background for people new to options and hedging. Parts I to III first.
- [docs/workbook.md](docs/workbook.md): what each developer builds each week, and how to check it.
- [docs/milestones.md](docs/milestones.md): the schedule and the decision dates.
- [docs/PRD.md](docs/PRD.md): the full specification. If any other document disagrees with it, the PRD is correct.

## Setup

You need Python 3.11 (3.12 also works; CI uses 3.11) and git.

macOS or Linux:

```bash
git clone <repo-url>
cd diffusion-deep-hedging
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -e ".[dev,notebooks]"
```

Windows (PowerShell):

```powershell
git clone <repo-url>
cd diffusion-deep-hedging
py -3.11 -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -e ".[dev,notebooks]"
```

On Linux, install the CPU-only PyTorch first unless you have a working GPU setup, because the default build downloads several gigabytes of GPU libraries:

```bash
pip install torch --index-url https://download.pytorch.org/whl/cpu
```

The `-e` matters: it installs the package in editable mode, so notebooks and tests import the code you're editing and not an old copy.

## Check that it works

```bash
pytest
ruff check .
```

`pytest` should end with a line saying everything passed and nothing failed. If a test in `tests/test_smoke.py` fails, your environment is the problem, not your code: post the error in the channel before you start Task 1.

## Layout

| Folder | What goes in it | Owner |
|---|---|---|
| `src/dhedge/simulators/` | GBM, Heston, bootstrap, GAN, diffusion | Dev 1, Dev 2 |
| `src/dhedge/agents/` | Policy network, training loop, PPO wrapper | Dev 3 |
| `src/dhedge/evaluation/` | P&L engine, metrics, grid runner, replay, PLAT score, P&L explain | Ethan, Dev 3 |
| `src/dhedge/baselines/` | Delta, threshold, Leland, no hedge; Task B desk rules | Ethan |
| `src/dhedge/gate/` | Admission tests and the memorization audit | Dev 1, Dev 2 |
| `src/dhedge/marketdata/` | Code that fetches and prepares data, never the data itself | Dev 1 |
| `src/dhedge/theory/` | Band extraction and scaling fits | Ethan |
| `tests/` | Mirrors the package, one test file per module | Everyone |
| `configs/` | One YAML file per run | Everyone |
| `notebooks/` | Tasks and exploration; the package never imports from here | Everyone |
| `scripts/` | Command-line entry points and repo tools | Everyone |
| `docs/` | PRD, primer, workbook, milestones, interfaces, decisions | Ethan |
| `data/`, `results/` | Local only; git ignores everything but their READMEs | |

Code that's used twice moves out of a notebook and into the package, because code in a notebook can't be tested or imported.

## How we work

- Every change goes through a pull request and gets one approving review, including Ethan's changes. CI must pass before merging.
- Tests decide whether code is correct, not how convincing it looks.
- Use AI tools however you like, but you must be able to explain every line of every PR you open. The reviewer will ask, and code you can't explain doesn't merge.
- If you've been stuck for 24 hours, post in the channel with what you tried.
- Every reported number must be reproducible from a config file and a seed.
- No code that fits a simulator may read data after December 31, 2016.

[CONTRIBUTING.md](CONTRIBUTING.md) has the details. Interfaces between components are in [docs/apis.md](docs/apis.md) and freeze on November 24. Decisions are logged in [docs/decisions.md](docs/decisions.md).

## Running tests

| Command | What it runs |
|---|---|
| `pytest` | Everything, skipping `data` tests when `data/` is empty |
| `pytest -m "not slow and not data"` | What CI runs |
| `pytest -m slow` | Long tests only; run these before merging anything that produces results |

Mark a test `@pytest.mark.slow` if it takes more than about ten seconds, and `@pytest.mark.data` if it needs files in `data/`.
