# Diffusion-Generated Market Environments for Risk-Averse Deep Hedging under Transaction Costs

**Author:** Ethan Bobrik, Project Manager, Western AI Club
**Date:** November 5, 2026
**Version:** Product requirements, version 2.3
**Status:** Team of three developers in place; first team meeting on November 5, 2026. This document is the reference for every decision on the project. The primer, the milestone sheet and the deck summarize it, and where they disagree, this one is correct.

---

## 1. Summary

The project tests one question with a controlled experiment: if you train a neural hedging agent in a simulated market, how much does the choice of simulator decide how well it hedges in the real one?

We train the same agent design in five simulated markets of increasing realism: geometric Brownian motion (GBM), a calibrated Heston model, a block bootstrap of historical returns, a GAN and a conditional diffusion model, the last two trained on returns. Each agent is then tested in every simulator and on real S&P 500 options from 2017 to 2026, replayed month by month, with the 2020 crash and the 2022 inflation shock reported separately. Classical hedges run alongside as controls: Black-Scholes delta, a threshold version of it, Leland's cost-adjusted delta, and no hedge. No simulator sees data after 2016, so both crises are out of sample.

Two additions bring the project closer to how a bank works. The first is a desk task. On a real index-options desk, delta is neutralized with futures every day and is not a decision; the decision is how much gamma and vega to carry and how to hedge them with a liquid option. Task B reproduces that setup. The second is a theory module. Whalley and Wilmott (1997) derived how wide the optimal no-trade band should be when trading costs are small. We check whether agents trained without any built-in band end up with bands that follow their law, and how the law changes in simulators where no theory exists.

Evaluation uses the measures a bank's risk function would use: Expected Shortfall at 97.5 percent as the headline tail measure, a Kolmogorov-Smirnov comparison modelled on the FRTB P&L attribution test, and a Greek decomposition of each agent's P&L.

If the richer simulators produce better hedgers, the usual way of training these agents is costing real money. If they don't, the cheap defaults are good enough for this kind of contract, which is worth knowing too. The band measurements are informative either way.

## 2. Background

This section is for a developer with no finance background. The primer covers the same ground more slowly.

**Selling an option.** A bank that sells a call option collects a premium up front and owes the buyer any rise in the stock above the strike price at expiry. Because that loss has no upper limit, the bank hedges by holding some of the underlying, so that gains on the stock offset losses on the option. The right amount to hold is the option's delta, the rate at which its value changes with the stock price.

**Why hedging costs money.** Delta moves with the stock. When the stock rises the hedger has to buy more, and when it falls back the hedger sells, so every round trip buys high and sells low. In the Black-Scholes model (1973) the premium pays for this exactly, but the model assumes continuous trading, no transaction costs and prices that follow GBM, and none of that holds. Once trading costs money, hedging becomes a trade-off between tracking delta closely (and paying for it) and tolerating some risk. For small costs the best policy is a band: leave the hedge alone until it drifts too far from the target, then trade back (Whalley and Wilmott, 1997). Outside simple models there is no formula for the band.

**Deep hedging.** Buehler, Gonon, Teichmann and Wood (2019) proposed letting a small neural network make the daily hedging decision. You simulate many price paths, run the network's decisions along each one, compute the P&L including costs, and adjust the weights by gradient descent to reduce a tail-risk measure of that P&L. It is a direct optimization rather than policy-gradient reinforcement learning, and it trains reliably.

**What desks actually do.** Index desks treat delta as non-negotiable. Net delta is brought close to zero every day using index futures, which are cheaper and more liquid than the stocks and avoid dividend accounting. Positions are managed through the book's net Greeks, not option by option, and rebalancing is often triggered by a threshold; S&P's delta-hedged index methodology, for example, adjusts the futures hedge only when net delta moves more than 0.1. The trader's real decisions concern gamma and vega, within risk limits, usually using at-the-money options. Regulation follows the same logic. Under the Basel FRTB rules, market-risk capital is based on Expected Shortfall at 97.5 percent, and each desk must pass a P&L attribution test comparing the P&L its risk model predicts with the P&L the front office reports, scored with Spearman and Kolmogorov-Smirnov statistics and sorted into green, amber and red zones.

**The gap.** Pickard and Lawryshyn (2023) reviewed 17 deep RL hedging studies and found that nearly all of them trained on GBM or a slightly richer stochastic volatility model. I have not found a controlled comparison of how the training simulator affects results on real markets; each paper picks one simulator and reports one result. On the theory side, a March 2026 paper (arXiv 2603.29994) builds the no-trade band into the network as a structural prior. Whether a network without that prior finds the band on its own, and what the band looks like in simulators without theory, is still open. Cao, Hull and co-authors (2022) studied the gamma and vega desk task with RL, but in a single simulated world. The closest work on generated markets is CoFinDiff (2025), which evaluated a financial diffusion generator through a single hedging experiment rather than a controlled comparison. Mikkilä and Kanniainen (2023) showed that hedging agents can be evaluated on real S&P 500 option data, which is the model for our real-data replay.

## 3. Why this project

Hedging error is a real cost on every options desk, and managing transaction costs is a large part of sell-side quant work. A clear answer to "does a better simulator produce a better hedger?" is useful to practitioners deciding whether to build generative simulators, and to researchers who train on GBM by default.

The evaluation design matters as much as the question. A wave of papers on LLM trading agents turned out to have tested on periods their models had effectively already seen (see FINSABER and the Profit Mirage audit). This project is set up so that cannot happen, and other students can reuse the protocol.

It also covers a lot of ground for an undergraduate project: derivatives, stochastic models, generative models, policy optimization, regulatory risk measures and careful statistics. The demo can be understood by someone with no finance background in about thirty seconds.

## 4. Goals and non-goals

The main goal is one results table per task, reproducible from the repository. Rows are training simulators; columns are evaluation settings (each simulator, real data overall, crisis periods only); each cell is a tail-risk number with a confidence interval.

Secondary goals are to release the benchmark as open-source code, publish the leakage protocol, report the band-law results, score each simulator with the PLAT-style test, show a live demo at CUCAI and write a paper good enough for a workshop.

Out of scope, on purpose:

- live or paper trading with real money;
- predicting prices or claiming a profitable strategy;
- American options and early exercise;
- intraday hedging (we hedge once a day);
- market impact (costs are proportional, with two tiers in Task B);
- implied volatility surfaces. A simulator carries at most one volatility variable.

## 5. Research questions

**RQ1.** Does the realism of the training simulator change out-of-sample hedging on real data, holding the agent, the training budget and the evaluation fixed? I expect agents trained on simulators with fat tails and volatility clustering to show lower tail risk on real data, with the gap largest in the crises and at high costs. The null is that the simulator makes no material difference.

**RQ2.** How well does each agent carry over to the other simulators? The full train-on-one, test-on-all grid shows which training worlds produce brittle agents.

**RQ3.** Where do differences show up: in calm periods or crises, at low or high costs, for at-the-money calls or out-of-the-money puts?

**RQ4.** In GBM, where theory exists, do agents without a built-in band reproduce the Whalley-Wilmott scaling? The prediction is that band half-width scales with cost to the power 1/3, with gamma to the power 2/3 and with risk aversion to the power -1/3. Is the band centred on Black-Scholes delta, as Whalley and Wilmott predict, or shifted, as Barles and Soner predict? And how do these relations change in the bootstrap and diffusion worlds?

**RQ5.** In the desk task, where delta is handled automatically and the agent only manages gamma and vega, does the simulator matter more than in Task A? I expect it to, because the simulators differ most in how volatility behaves.

## 6. Method

The only thing that changes between experimental arms is the training simulator. The network, training budget, hyperparameter procedure, contracts, costs and evaluation are the same for every arm within a task.

### 6.1 Simulators

All five simulators implement the same Simulator interface and are fitted only on data up to the end of 2016.

GBM is the control and the correctness check, since several results about hedging under GBM are known exactly. In Task B it carries no volatility risk, so there it serves only as a degenerate control.

Heston adds stochastic volatility that mean-reverts and is negatively correlated with returns, which produces volatility clustering and the leverage effect. It is calibrated to pre-2017 data and supplies the volatility state Task B needs directly.

The block bootstrap glues together multi-week blocks of real pre-2017 history, using the stationary bootstrap of Politis and Romano (1994). It has every feature of real data by construction, but it cannot produce anything that history did not contain. For Task B the blocks carry returns and realized volatility together.

The conditional diffusion model is a denoising diffusion model (Ho, Jain and Abbeel, 2020) over short windows of daily returns, conditioned on the current volatility state. It trains on windows pooled across many liquid underliers after volatility standardization, which is the main defence against memorizing a small data set. For Task B it generates returns jointly with a single volatility variable.

The GAN is a generative adversarial network over the same return windows. It is in the study because GANs are the incumbent market generators in the literature (Wiese et al., 2019 and 2020), so the diffusion model needs something learned to be compared against. Adversarial training is unstable, so the GAN gets a two-week timebox and one retry with a gradient penalty. It generates returns only and is not used in Task B.

**Admission gate.** Each learned generator, the GAN and the diffusion model, enters the experiment only if it reproduces the standard stylized facts of returns (Cont, 2001) and passes these checks, which are fixed in advance and reported whether it passes or not:

- absolute lag-1 autocorrelation of returns below 0.05, with no systematic pattern out to lag 10;
- excess kurtosis within 40 percent of the pooled real value;
- autocorrelation of absolute returns positive out to lag 20;
- annualized drift below 2 percent after drift neutralization;
- fewer than 1 percent of generated windows closer to a training window than the 1st percentile of nearest-neighbour distances between real windows.

For joint generation, the volatility variable's autocorrelation and its correlation with returns must also fall within bands around the real values. The gate exists because an agent can do well in a generated world by exploiting an artifact, such as a small built-in drift, instead of by hedging.

### 6.2 Agent and training

The agent is a small multilayer perceptron with two or three hidden layers of about 32 units. Its inputs are log-moneyness, time to expiry, the previous holding and recent realized volatility, and its output is a bounded position. The bounds stop it from taking leveraged directional bets, so any difference between arms reflects hedging. The previous holding has to be an input; without it the network cannot weigh the cost of trading against the benefit, and no band can appear.

Training follows Buehler et al. Each iteration draws a fresh batch of paths, runs the policy along each one through the P&L engine, and reduces the tail risk of the loss by backpropagation. Because every batch is new, there is no fixed training set to memorize. The headline risk measure is Expected Shortfall at 97.5 percent; we also report CVaR at 95 percent.

Two published results serve as correctness checks. In GBM with zero costs the agent must recover Black-Scholes delta, with mean absolute deviation below 0.05 and ES within 5 percent of the delta hedge. With costs it must develop band-like behaviour and beat plain delta hedging. Reproducing both is the validation milestone.

One agent trained with PPO (Schulman et al., 2017) in a single simulator serves as an ablation, to check that the findings hold under true reinforcement learning. It never carries a headline result.

### 6.3 Task A: one option, one hedge instrument

Every agent and baseline hedges the same contract, a one-month at-the-money SPX call sold each month from 2017 to 2026. SPX options are European and settle in cash, which keeps early exercise and dividends out of the accounting. The second contract is a short out-of-the-money put with a delta of about 0.10, where fat tails should matter most. Costs are proportional at three levels (5, 20 and 50 basis points as working values, fixed during Phase 1). The action is the holding in the underlying, capped at roughly 0 to 1.2 for the short call.

### 6.4 Task B: the desk task

Task B copies the way an index-options desk makes decisions. The book is short one one-month at-the-money SPX call and one 10-delta put, rolled monthly. At each close, net delta is set to zero in index futures automatically, and the agent has no say in it. What the agent chooses is how many units of a one-month at-the-money option to hold, within limits on net gamma and vega, based on the book's Greeks, the volatility state, the time to the next roll and its previous holding. Costs come in two tiers, about 1 to 2 basis points for futures and 25 to 50 for the option, fixed during Phase 1.

The baselines here are a delta-only desk with no option hedge, a rule that neutralizes gamma and a rule that neutralizes vega. Task B runs in the Heston, bootstrap and diffusion worlds, the three with real volatility dynamics, with GBM as a degenerate control.

In the bootstrap and diffusion worlds the hedge option needs a price every day, and no model provides one. We price it with Black-Scholes at the world's current volatility state (EWMA realized volatility in the bootstrap, the generated volatility in the diffusion world), then check in the Heston world how far that convention moves the results compared with Heston's own semi-closed-form price. We report the convention and the size of that sensitivity, because a reviewer will ask about it.

### 6.5 Baselines

- Black-Scholes delta, rebalanced daily.
- A threshold version that trades only when the hedge is more than 0.1 from delta, following the S&P index methodology. It is also a hand-set no-trade band, which makes it a natural comparison for the theory module.
- Leland's cost-adjusted delta.
- No hedge.

Each is checked against closed-form or published values before it is used in any comparison.

### 6.6 Temporal firewall

Every simulator, including the Heston calibration and the bootstrap's pool of blocks, uses data up to December 31, 2016 and nothing after. All real-data evaluation starts in 2017, so the 2020 and 2022 episodes are unseen by every model in the study.

### 6.7 Theory module

I own this part. Whalley and Wilmott (1997) analysed the utility-based hedging model of Hodges and Neuberger (1989) and showed, by matched asymptotic expansion for a small proportional cost λ, that the optimal policy is a no-trade band around the frictionless holding with half-width

h = ((3 λ δ(t,T) S Γ²)/(2γ))^(1/3)

where δ(t,T) is the discount factor (1 when interest rates are zero), S is the spot price, Γ is the Black-Scholes gamma and γ is the hedger's risk aversion. The power of one third comes from balancing two costs: being off target costs roughly the square of the deviation, while trading back costs an amount proportional to it. Barles and Soner (1998) reached a different answer, a band plus a volatility adjustment, whose centre is not the Black-Scholes delta.

**Experiment 1, emergence in GBM.** Train agents across a grid of cost levels and risk aversions; each run takes minutes. For a fixed time and spot, sweep the previous-holding input and record the interval in which the policy does not trade, using a tolerance ε fixed in advance and varied as a sensitivity check. Regress log band width on log cost (predicted slope 1/3), on log gamma across states (2/3) and on log risk aversion (-1/3), with confidence intervals from the seeds, and test whether the band is centred on Black-Scholes delta. The asymptotics are known to understate band width at large costs, so the scaling test uses small and moderate costs only; Zakamouline (2006) gives approximations that are useful beyond that range.

**Experiment 2, deformation.** Extract bands the same way from agents trained on the bootstrap and diffusion worlds, where no asymptotic theory exists, and check whether the one-third law survives, whether the band becomes asymmetric under fat tails and whether its centre moves.

The March 2026 paper builds the band in as a prior and verifies the Whalley-Wilmott formula in a control setting, and Imaki et al. (2021) build band structure into the network architecture. This module asks the complementary question: does the band appear without being built in, and how does it change across simulators? Both papers need to be read before the module is written up.

## 7. Evaluation

**Train-test grid.** For each task, every agent is tested in every simulator it can run in, on real data for the full period and on the crisis windows alone, with five seeds per arm.

**Real-data replay.** For each month from 2017 to 2026, we sell the contract (Task A) or set up the book (Task B) at actual market prices, hedge daily along the real path, charge costs and record the final P&L. That gives about a hundred non-overlapping episodes covering calm years, the 2020 crash and 2022. If the option data turn out to be poor, the fallback needs only the underlier's price history, which is clean, plus a premium at the start of each episode.

**Metrics.** Expected Shortfall at 97.5 percent is the headline. We also report CVaR at 95 percent, the mean and standard deviation of hedging error, turnover, and costs split by tier, for each cost level and task. Mean P&L is always reported separately from its spread. An agent that speculates instead of hedging shows up as a high mean with a wide spread, and we want that to be visible.

**PLAT-style score.** For each agent, we compare the P&L distribution its training simulator predicts for the evaluation episodes with the P&L it actually earns on real data, using the Kolmogorov-Smirnov statistic, and assign the FRTB zones (roughly green below 0.09 and red above 0.12). In regulatory terms, this asks which training simulators would keep a desk on the internal models approach. We report the Spearman part of the test where episodes can be paired, with the caveat that the industry has argued for dropping it because it behaves badly for well-hedged books.

**P&L explain.** Each agent's real-data P&L is split into delta, gamma, vega and theta contributions plus an unexplained remainder, so we can see where any advantage comes from.

**Statistics.** Headline real-data numbers use non-overlapping episodes only; elsewhere, confidence intervals come from a block bootstrap. Simulated evaluation uses about 100,000 held-out paths per simulator, generated with seeds that training never used, and every agent and baseline is scored on the same paths (common random numbers). Comparisons are therefore paired, so luck in the path set affects every arm equally and cancels out of the differences. Hyperparameters are tuned once, on a neutral simulator, with the same budget for every arm.

**Overfitting.** The word covers several different problems here, and each has its own control.

- Memorizing a training set is ruled out by design: every batch is new, and the network has only a few thousand parameters.
- Luck in the evaluation paths is handled by the large held-out sets, the confidence intervals and common random numbers. The five seeds measure luck in initialization. Seeds say nothing about whether the training world resembles reality.
- Overfitting to the simulator is not something we try to avoid. It is what RQ1 and RQ2 measure.
- Exploiting generator artifacts or memorized history is handled by the admission gate, drift neutralization, the action bounds and the separate reporting of mean and spread.
- Our own overfitting, as researchers, is limited by the firewall, tuning on a neutral simulator, disjoint evaluation seeds, and fixing the metrics, sensitivity checks and table layouts before any training run.

Taken together, the validation steps line up with the Federal Reserve's SR 11-7 guidance on model risk (conceptual soundness, outcomes analysis and ongoing monitoring), and the paper will describe them that way.

**If the results look null.** Before calling the result null, we check, in this order: the crisis windows, the highest cost level, the out-of-the-money put, Task B, and weekly instead of daily rebalancing. Both versions of the abstract get drafted before the February 6 review.

## 8. Architecture and stack

Three interfaces connect the components. The Simulator returns price paths (with a volatility path for Task B) for a given horizon and seed. The Agent takes a state and returns a bounded action. The Evaluator takes paths, actions, a contract and a cost model and returns the metrics. The interfaces freeze on November 24, two weeks into Phase 1.

The P&L engine sits inside the Evaluator, and every number in the study passes through it. It has two owners, property tests, a hand-calculated three-step test case and a convergence check that runs in CI on every merge: at zero cost under GBM, delta-hedging error must shrink as rebalancing becomes more frequent, at a known rate. My prototype engine from the August spike stays in the repository as an independent implementation to cross-check against.

The stack is Python 3.11, PyTorch for the models and the differentiable P&L engine, and NumPy, pandas, SciPy and matplotlib, with pytest and ruff for tests and linting. GitHub requires review and has branch protection on main, and Actions runs the full test suite on every merge. Experiments are tracked in the free tier of Weights and Biases. The largest runs need a few GPU-hours on Colab or Kaggle. Nothing in the project costs money.

## 9. Data

SPX daily prices (SPY if needed) are free and clean. Free end-of-day SPX option chains provide the premium at the start of each episode and, where quality allows, daily marks. Realized volatility is computed from the underlier.

Option data has to pass a quality check before we use it: put-call parity within tolerance, positive bids, spreads under 15 percent of the mid price, and at least 90 percent of monthly episodes from 2017 to 2026 covered. If it fails, we switch to SPY, then use market quotes only at the start of each episode, and finally fall back to model-implied premiums on real paths, reported plainly as a replication-error study.

The diffusion model trains on pre-2017 daily returns (plus realized volatility, for Task B), pooled across liquid underliers and standardized by volatility.

## 10. Team

Three developers and me.

| Role | Owns | Backup |
|---|---|---|
| Dev 1, markets | Data pipeline, GBM, Heston calibration, bootstrap, the statistical tests in the admission gate; the GAN in January | Dev 2 |
| Dev 2, generator | Diffusion model, joint spot-volatility generation, gate runs, memorization audit | Dev 1 |
| Dev 3, hedger | Policy network and training loop for both tasks; the PPO ablation; co-owner of the P&L engine | Ethan |
| Ethan, PM | P&L engine (co-owner), evaluation harness (grid runner, replay, statistics, PLAT score, P&L explain), baselines, theory module, integration, demo | Dev 3 |

The plan keeps the full scope with three developers by sequencing work instead of cutting it. Dev 2 starts the diffusion prototype in November rather than December, because it does not depend on the P&L engine and the generator is the component most likely to need a second retry. Dev 1 finishes the classical simulators by December 12, builds the GAN in a two-week timebox starting January 11, and joins demo work in February. Dev 3 trains the Task A agents in January, when most of the work is waiting on compute, and runs the PPO ablation in February alongside Task B.

Python is the only requirement. PyTorch helps for Dev 2 and Dev 3, and pandas for Dev 1. Nobody needs a finance background; I run workshops on options and hedging and on diffusion models in the first week. Everyone's first task is to build a delta hedge by hand on simulated GBM paths and plot hedging error and cost against rebalancing frequency. Each component keeps a README that its backup can work from.

## 11. Scope

**MVP.** Three simulators (GBM, bootstrap, diffusion), Task A, the agent, the delta and Leland baselines, the P&L engine with its full test suite, and the real-data replay. If everything else fails, this is still a complete study.

**Full plan.** Everything in this document is in scope: five simulators, Task A, Task B in the Heston, bootstrap and diffusion worlds, the PPO ablation, the PLAT score, the P&L explain and both theory experiments. Nothing is cut in advance.

**Cut order if a milestone slips** by more than a week, applied at phase reviews, in this order:

1. The GAN.
2. The PPO ablation.
3. Theory Experiment 2 limited to GBM against diffusion.
4. Task B reduced to the Heston and diffusion worlds.
5. Task B dropped. ES 97.5, the PLAT score and the threshold baseline stay, since they cost almost nothing.
6. P&L explain.
7. The out-of-the-money put in Task A.
8. The third cost level.
9. Train-test grid limited to the real-data columns.
10. Down to the three MVP simulators.

**Never cut:** the P&L engine tests, the firewall, the Task A real-data replay, the demo and theory Experiment 1.

**Only if everything else is done:** a public leaderboard for outside hedging policies.

## 12. Timeline

CUCAI in early March is fixed. Western's fall reading week was October 10 to 18, so there is no break in November. Fall classes end December 9 and exams run December 14 to 18. Winter classes start January 4, and winter reading week is February 13 to 21. We work in weekly sprints with a short risk review each week. The milestone sheet has the same plan as a table.

**Phase 0, November 5 to 12: onboarding.** The team was hired by October 26 but first met on November 5, a week later than version 2.2 assumed. Phase 0 is the kickoff meeting, the workshops (options and hedging at the kickoff, diffusion models at the second meeting), environment setup and the first task, a hand-built delta hedge and its cost-error curve. Milestone on November 12: every developer has a cost curve, owners are confirmed and the interface draft has been reviewed. Every fall date after this moves one week later. The week is made up in February, not by cutting anything.

**Phase 1, November 9 to December 5: engine and agent.** P&L engine with property tests and the convergence check in CI (Ethan and Dev 3); GBM and the data pipeline (Dev 1); the agent (Dev 3); the diffusion prototype (Dev 2). Weekly checks with known answers: the convergence check (November 14), the ES loss unit test (November 21), delta recovered at zero cost (November 28) and delta beaten under costs (December 5). Interfaces freeze on November 24. Milestone on December 5: validation passes. The outcome is either proceed or fix first, and no experimental result counts until it passes.

**Phase 2a, December 6 to 12: simulators.** Heston calibrated (the work starts in late November) and the bootstrap built (Dev 1); the three gate tests and the memorization audit merged and tested (Dev 1 and Dev 2); the tuned diffusion model and a gate dry run (Dev 2). Milestone on December 12: GBM, Heston and the bootstrap pass their checks, the gate tests are tested and the diffusion dry run is logged. Classes end December 9 and exams start December 14, so this date can't move. From December 13 to January 3, only checkpointed training runs continue.

**Phases 2b and 3, January 4 to February 6: main experiment.** January runs one week later than in version 2.2. From January 4 to 9, the admission gate is assembled into one report (Dev 1) and the diffusion model makes its first full gate attempt (Dev 2), with a checkpoint on January 9. After that come the diffusion retries, with the admission decision by January 23 (Dev 2); the GAN, built in a two-week timebox from January 11 with its admission also decided by January 23 (Dev 1); joint spot-volatility generation (Dev 2); agents trained in every admitted simulator with five seeds, starting with the classical simulators on January 4 (Dev 3); evaluation paths frozen; the full Task A grid and real-data replay; and theory Experiment 1. Milestone on February 6: the Task A table with confidence intervals, both abstracts drafted and the scaling slopes measured.

**Phase 4, February 8 to 20: desk task, theory and demo.** Task B in Heston, the bootstrap and diffusion (Dev 3, with Dev 2 and Dev 1 supplying the joint generators); the PPO ablation, one week (Dev 3); PLAT scores and the P&L explain (Ethan); theory Experiment 2 (Ethan); the demo (Ethan and Dev 1). Winter reading week, February 13 to 21, is working time in this version, where version 2.2 kept it as a buffer. That is where the fall's lost week is made up. Milestone on February 20: the demo runs end to end and the tables are final.

**February 22 to early March:** paper and poster drafts by February 27, then polish, rehearsals and CUCAI.

## 13. Risks

Two risks were dealt with in the design itself. The direct training method avoids the instability of policy-gradient RL, and the firewall rules out leakage. Every other risk has a trigger, a first response, a fallback agreed in advance, a decision date and an owner, and we go through them at each weekly review.

- **Late start.** This happened: the team was hired on October 26, two days past the October 24 trigger, and first met on November 5. Phase 0 runs November 5 to 12 and the fall moves one week. The gate assembly and the first full diffusion gate attempt move to January 4 to 9, January moves one week, and winter reading week becomes working time. The full scope is kept and the work is sequenced to fit (section 10). There is no buffer left, so the next slip of more than a week goes straight to the cut order in section 11. Owner: Ethan.
- **The GAN won't train or fails the gate.** One retry with a gradient penalty inside its two-week timebox, then it is dropped (cut item 1) and the study runs with four simulators. Decide by January 23. Owner: Dev 1.
- **Validation missed on December 5.** Trigger: mean absolute deviation from delta above 0.05 at zero cost, or no improvement over delta under costs beyond the confidence interval. Response, in order: the convergence check, input normalization, a unit test of the risk measure, a learning-rate sweep, and an exact reproduction of the published example. Fallback: a parametric band policy for each simulator. Decide by December 12. Owners: Dev 3 and Ethan.
- **The diffusion model fails the gate.** The response depends on how it fails: more capacity and volatility conditioning for thin tails, a larger training pool and early stopping on nearest-neighbour distance for memorization, and forced drift neutralization for autocorrelation. Two retry cycles of one week each. Fallback: run with the classical simulators only and report the gate results. Decide by January 23. Owner: Dev 2.
- **Joint spot-volatility generation fails.** Response: condition on EWMA volatility instead. Fallback: Task B in Heston and the bootstrap only, then item 5 of the cut order. Decide by February 13. Owner: Dev 2.
- **Band extraction is unstable**, meaning the band edges move under the ε sweep. Response: average over states with the same gamma and sample more states. Fallback: report the scaling for the threshold baseline's band, which is exact, with a qualitative comparison to the agents. Decide by February 6. Owner: Ethan.
- **Option data below 90 percent coverage.** Switch to SPY, then use start-of-episode quotes only, then model-implied premiums. Decide by November 12. Owner: Dev 1.
- **A null result at the February 6 review.** Run the checks listed in section 7. Both abstracts will already exist.
- **An agent exploits a generator artifact.** Trigger: its mean P&L in its home world is more than two standard deviations above the baselines, or its advantage disappears when drift is neutralized. Neutralize, tighten the action bounds and retrain. If it persists, exclude that simulator and add the new check to the gate.
- **Schedule slip or new ideas.** Trigger: any milestone more than a week late. Apply the cut order in section 11 from the top. New ideas go on a list that we only look at after February 6.
- **Someone leaves, or compute runs short.** Every component has a README and a backup, the engine has two owners, and every run is checkpointed and can resume.

## 14. Deliverables and success

By CUCAI we want: the open-source repository, with the simulators, agents for both tasks, baselines, the gate, the evaluation harness, the PLAT scorer, the P&L explain and all configuration files; the Task A table with confidence intervals, and the crisis analysis; the Task B table; the band results (scaling slopes, the centring test and the deformation plots); the memorization and artifact audits; the demo; and the poster.

The demo replays the 2020 crash. The audience picks a cost level, and three hedgers run side by side on the same real path: Black-Scholes delta, the agent trained on GBM and the agent trained on the diffusion model. Their P&L distributions pull apart as the crash unfolds. A second panel shows the learned no-trade band widening as the cost slider goes up.

Success has three levels.

- **Minimum:** the MVP, validation passed on December 5, honest statistics, theory Experiment 1 and the demo.
- **Target:** the full five-simulator Task A grid with crisis results, Task B in all three of its simulators, PLAT scores, the P&L explain, Experiment 2 and the PPO ablation.
- **Stretch:** a workshop submission and the leaderboard.

## 15. Open items

- Confirm the CUCAI date.
- Fix the cost levels and the Task B risk limits during Phase 1.
- Write down the hedge-option pricing rule for each simulator, with the Heston sensitivity check.
- Fix the band-extraction tolerance ε and the sample of states before Experiment 1.
- Check for new papers this fall on simulator comparisons or band emergence.

## Appendix A. Glossary

- **Option, call, strike, premium.** A call gives the buyer the right to buy a stock at a fixed price, the strike. The seller keeps the premium paid up front and owes any rise above the strike.
- **Delta.** How much the option's value changes per dollar move in the stock; also the stock holding that offsets that change.
- **Gamma.** How fast delta changes as the stock moves, which determines how much rebalancing a position needs.
- **Vega.** Sensitivity to changes in volatility.
- **Theta.** Value lost as time passes.
- **Hedging error.** The P&L left over after hedging.
- **GBM, Heston.** The textbook price model with constant volatility, and a model in which volatility is itself random and clusters.
- **Stylized facts.** Fat tails, volatility clustering, and daily returns that are almost uncorrelated with each other.
- **Expected Shortfall (ES) 97.5.** The average of the worst 2.5 percent of outcomes; the FRTB risk measure. CVaR is the same quantity at a chosen level.
- **No-trade band.** The range of deviation from the target within which a cost-aware hedger does not trade.
- **PLAT.** The FRTB P&L attribution test, which compares the P&L a desk's risk model predicts with the P&L the desk reports, using Spearman and Kolmogorov-Smirnov statistics and traffic-light zones.
- **P&L explain.** The standard desk report that splits daily P&L into Greek contributions and an unexplained remainder.
- **Temporal firewall.** The rule that simulators see only data before 2017.
- **Futures delta leg.** The automatic end-of-day trade in index futures that sets net delta to zero in Task B.

## Appendix B. Revision history

- **v1, August 2026.** Original design: five simulators, Task A only.
- **v2, October 6, 2026.** Added the desk task, the theory module, FRTB-style evaluation (ES 97.5 and the PLAT score), the threshold baseline and the P&L explain. Timeline compressed for a late-October start.
- **v2.1, October 26, 2026.** Phase 0 shortened to October 26 to November 4; academic calendar dates added.
- **v2.2, October 26, 2026.** Rewritten for a team of three with the full scope kept. The GAN moves to Dev 1 in January and the PPO ablation to Dev 3 in February; the diffusion prototype moves to November; interfaces freeze on November 17.
- **v2.3, November 5, 2026.** Re-dated for a first team meeting on November 5. Phase 0 runs November 5 to 12 and the Phase 1 checks move one week later, with validation on December 5 and the interface freeze on November 24. December 12 stays fixed; the gate assembly and the first full diffusion gate attempt move to January 4 to 9. January moves one week, with admission decisions on January 23 and the Task A table on February 6. Winter reading week becomes working time. Nothing is cut.

## References

Barles, G., and Soner, H. M. (1998). Option pricing with transaction costs and a nonlinear Black-Scholes equation. Finance and Stochastics, 2, 369-397.

Basel Committee on Banking Supervision (2019). Minimum capital requirements for market risk.

Black, F., and Scholes, M. (1973). The pricing of options and corporate liabilities. Journal of Political Economy, 81(3), 637-654.

Board of Governors of the Federal Reserve System (2011). SR 11-7: Supervisory guidance on model risk management.

Bridging stochastic control and deep hedging: Structural priors for no-transaction band networks (2026). arXiv:2603.29994.

Buehler, H., Gonon, L., Teichmann, J., and Wood, B. (2019). Deep hedging. Quantitative Finance, 19(8), 1271-1291. arXiv:1802.03042.

Cao, J., Chen, J., Hull, J., Poulos, Z., et al. (2022). Gamma and vega hedging using deep distributional reinforcement learning. arXiv:2205.05614.

CoFinDiff: Controllable financial diffusion model for time series generation (2025). IJCAI 2025. arXiv:2503.04164.

Cont, R. (2001). Empirical properties of asset returns: Stylized facts and statistical issues. Quantitative Finance, 1(2), 223-236.

Heston, S. L. (1993). A closed-form solution for options with stochastic volatility with applications to bond and currency options. Review of Financial Studies, 6(2), 327-343.

Ho, J., Jain, A., and Abbeel, P. (2020). Denoising diffusion probabilistic models. NeurIPS. arXiv:2006.11239.

Hodges, S. D., and Neuberger, A. (1989). Optimal replication of contingent claims under transaction costs. Review of Futures Markets, 8, 222-239.

Imaki, S., Imajo, K., Ito, K., Minami, K., and Nakagawa, K. (2021). No-transaction band network: A neural network architecture for efficient deep hedging. arXiv:2103.01775.

Leland, H. E. (1985). Option pricing and replication with transactions costs. Journal of Finance, 40(5), 1283-1301.

Li, Kim, Cucuringu, and Ma (2025). Can LLM-based financial investing strategies outperform the market in the long run? (FINSABER). arXiv:2505.07078.

Mikkilä, O., and Kanniainen, J. (2023). Empirical deep hedging. Quantitative Finance, 23(1).

Pickard, R., and Lawryshyn, Y. (2023). Deep reinforcement learning for dynamic stock option hedging: A review. Mathematics, 11(24), 4943.

Politis, D. N., and Romano, J. P. (1994). The stationary bootstrap. Journal of the American Statistical Association, 89(428), 1303-1313.

S&P Dow Jones Indices (2025). S&P delta-hedged straddle indices methodology.

Schulman, J., Wolski, F., Dhariwal, P., Radford, A., and Klimov, O. (2017). Proximal policy optimization algorithms. arXiv:1707.06347.

The Profit Mirage (2025). arXiv:2510.07920.

Whalley, A. E., and Wilmott, P. (1997). An asymptotic analysis of an optimal hedging model for option pricing with transaction costs. Mathematical Finance, 7(3), 307-324.

Wiese, M., Bai, L., Wood, B., and Buehler, H. (2019). Deep hedging: Learning to simulate equity option markets. arXiv:1911.01700.

Wiese, M., Knobloch, R., Korn, R., and Kretschmer, P. (2020). Quant GANs: Deep generation of financial time series. Quantitative Finance, 20(9), 1419-1440.

Zakamouline, V. (2006). Efficient analytic approximation of the optimal hedging strategy for a European call option with transaction costs.
