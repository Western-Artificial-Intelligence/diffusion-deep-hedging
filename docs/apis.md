# Interfaces

**Status:** draft v0. Reviewed at the meeting on November 12, open to change until the freeze on Tuesday, November 24, then tagged `apis-v1.0` in git. After the freeze, a change needs an entry in `docs/decisions.md` and the agreement of every owner it affects.

Three interfaces connect the components: a **Simulator** returns price paths, an **Agent** maps a state to a bounded action, and an **Evaluator** turns paths and actions into P&L and metrics. Everything else in the project talks through these.

## Conventions

These already apply to all code (workbook section 7).

- **Time.** Trading days, with a time step of 1/252 years. An episode is 21 steps, so a price path has 22 values including the start.
- **Prices.** Simulated paths start at 100. Real paths are rescaled so that each episode starts at 100.
- **Shapes.** Spot and volatility paths have one row per path and one column per time point. Holdings have one column per step: the holding chosen at time t is held until t + 1.
- **Numbers.** float32 for training. The evaluator accumulates P&L in float64 for reporting.
- **Volatility** is annualized and written as a decimal, so 0.20 rather than 20.
- **Costs** are proportional rates on the value traded, as decimals, so 5 basis points is 0.0005.
- **Randomness.** Every function that draws random numbers takes a seed or a generator and never touches the global random state.
- **Runs.** One run is one config file plus a seed. Results go under `results/<run id>/` along with a copy of the config.
- **The firewall.** Every fitting routine calls the guard in `dhedge.marketdata`, which rejects any date after December 31, 2016.

## Simulator

To decide before the freeze:

- The method that produces paths, its arguments, and what it returns (which named outputs, which are required and which optional).
- How a seed or generator is passed in.
- How classical simulators are fitted, and where the firewall guard is called.
- Where drift neutralization happens.

## Agent

To decide before the freeze:

- The method that maps a state to an action, and what the state contains (which named features, with what shapes).
- Where the action bounds are enforced, and what the evaluator checks.
- How the same interface covers a Task B action.

## Evaluator

To decide before the freeze:

- What goes in: paths, holdings, a contract and a cost model, and how each is described.
- What comes out: per-path P&L as well as the summary metrics.
- How a contract is specified (type, strike, expiry, signed quantity).
- How costs are specified when there is more than one instrument.

## What Task B needs from these interfaces

Task B starts in February, after the freeze, so its needs have to fit now:

- A second instrument with its own daily price (the hedge option), alongside the underlying or futures.
- Holdings for more than one instrument.
- The book's Greeks, for the gamma and vega limits.
- A futures leg that trades automatically at every close.
- Separate cost rates for futures and options.

## Tests every implementation must pass

- Look-ahead: changing every price after step t must not change any action up to step t.
- Reproducibility: the same seed gives identical paths and identical results.
