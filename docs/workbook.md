# Developer Workbook

**Author:** Ethan Bobrik, Project Manager, Western AI Club
**Date:** November 5, 2026
**Version:** Week-by-week plan, November 5, 2026 to CUCAI
**Status:** For Dev 1, Dev 2 and Dev 3. It tells you what to build each week and how to check your own work. It does not give you code or answers, on purpose. Every week has checks you can run yourself, so you'll know when you've got it right without anyone telling you.

---

This workbook turns the PRD into weekly work. Read sections 1 and 2 now, section 3 this week, and your own section before each week starts. You can read the other developers' sections too, and it's worth doing: most of the hand-offs between us are written there.

## 1. How this works

**What each week contains.** Every week in your section has the same parts. *Build* is what you make. *How to approach it* gives an order of work and some hints, usually as questions. *Check yourself* lists tests and sanity checks with known answers or known behaviour; where you can, turn them into pytest tests. *Watch out for* lists the mistakes that cost people an evening. *Done when* names the pull request that closes the week. *Hand-off* says who is waiting on you.

**Hours.** Plan on 6 to 8 hours a week. Exam weeks are deliberately light. Winter reading week is not: in this plan it's a normal working week, so tell me now if you'll be away for it. If a week's work clearly won't fit your real capacity, tell me on Monday rather than Friday, and we'll move something.

**Rules we all follow.**

- Every change goes through a pull request and gets reviewed. In Phase 1 I review everything. From December, Dev 1 and Dev 2 review each other, and Dev 3 and I review each other.
- Tests decide whether code is correct, not how convincing it looks.
- Use AI tools however you like, but you have to be able to explain every line of every PR you open. The reviewer will ask, and code you can't explain doesn't merge.
- If you've been stuck for 24 hours, post in the channel with what you tried. Being stuck isn't a problem; being stuck silently for a week is.
- Every number you report must be reproducible from a config file and a seed.
- No code that fits a simulator may read data after December 31, 2016. Dev 1 builds a guard function for this in week 3 and everyone calls it.

**How hints work.** I give you the target and the test, and you find the route. When you get stuck: re-read the check, write the smallest test that fails, then ask. I'll usually answer with a question first. For some checks I know the exact numbers from my August prototype. I won't tell you them, but I'll tell you whether you're close.

## 2. Calendar

Our first meeting was Thursday, November 5, and we meet every Thursday after that. Milestones are on Saturdays unless noted. Fall classes end December 9, exams run December 14 to 18, winter classes start January 4, and winter reading week is February 13 to 21. Because we started a week later than planned, December 12 stays fixed, two pieces of December work move to the first week of January, and reading week is a working week.

| Week | Dates | Shared milestone | Dev 1, markets | Dev 2, generator | Dev 3, hedger |
|---|---|---|---|---|---|
| 1 | Nov 2 to 8 | Kickoff Thu Nov 5 | Setup, Task 1 | Setup, Task 1 | Setup, Task 1 |
| 2 | Nov 9 to 15 | Task 1 due Nov 12; engine check Nov 14 | Task 2; data pipeline; GBM | Task 2; diffusion on toy data | Task 2; P&L engine with Ethan |
| 3 | Nov 16 to 22 | Task 2 due Nov 19; ES loss test Nov 21 | Firewall guard; realized volatility; episode table | Diffusion on real returns, v0 | ES loss; policy network; rollout |
| 4 | Nov 23 to 29 | Interfaces freeze Nov 24; delta recovered Nov 28 | Heston simulator | Conditioning; memorization audit | Zero-cost training |
| 5 | Nov 30 to Dec 6 | Validation Dec 5 | Heston calibration | Gate dry run | Costs on; beat delta |
| 6 | Dec 7 to 13 | Simulators Dec 12 | Joint bootstrap | Diffusion v1; drift neutralization | Training harness and configs |
| 7 to 9 | Dec 14 to Jan 3 | Exams, break | GAN design note | Joint generation plan | Task B design note |
| 10 | Jan 4 to 10 | Gate report Jan 9 | Admission gate assembled | First full gate attempt | Integration dry run; Task A training |
| 11 | Jan 11 to 17 | GAN timebox starts Jan 11 | GAN attempt 1 | Retry 1; joint generation started | Task A training |
| 12 | Jan 18 to 24 | Admission decisions Jan 23 | GAN retry and decision | Retry 2 and decision | Task A training |
| 13 | Jan 25 to 31 |  | Heston option pricer | Joint generation and extended gate | Generator worlds; Task A grid; Task B environment |
| 14 | Feb 1 to 7 | Headline table Feb 6 | Cross-reproduction; demo data | Cross-reproduction; audit write-up | Cross-reproduction; Task B tests |
| 15 | Feb 8 to 12 | Joint generation decision Feb 13 | Demo | Pricing convention check | Task B training |
| 16 | Feb 13 to 21 | Reading week, working; final tables Feb 20 | Demo | Task B in the diffusion world | PPO ablation |
| 17 | Feb 22 to 28 | Paper and poster drafts Feb 27 | Write-up; poster | Write-up; poster | Write-up; poster |

Rehearsals for CUCAI run from March 1 until the conference.

## 3. Weeks 1 and 2: everyone

### Week 1 (Nov 2 to 8): setup and Task 1

**Setup.** Right after the kickoff on November 5, install Python 3.11 in a fresh virtual environment and install the packages from the welcome message. Once you're added to the repository: clone it, run the test suite and confirm it passes, then open a small pull request adding your name to `CONTRIBUTORS.md`. That PR is practice for the review process, and it's how I'll know your setup works. Read Parts I to III of the primer. If you have time, read sections 1 to 3 of Buehler et al. (2019).

**Task 1, due Thursday November 12: build a delta hedge by hand.** You will sell one option, hedge it, and measure what hedging costs. The spec:

- Simulate GBM price paths with starting price 100, volatility 0.20 and zero drift, over one month of 21 trading days. Use at least 10,000 paths, and vectorize over paths (no Python loop over paths).
- Write the Black-Scholes call price and delta with zero interest rate.
- Sell one at-the-money call (strike 100) for its Black-Scholes price, then hedge it with delta at several rebalancing frequencies, for example 5, 21, 84 and 336 times over the month.
- For every path, compute the final P&L: premium received, plus gains and losses on the shares, minus the payoff you owe.
- Do this with no trading fees, then again with a proportional fee of 0.1 percent of the value of every trade (a rate of 0.001). Everyone uses the same rate so the plots can be compared.
- Plot the standard deviation of P&L against rebalancing frequency, with and without fees. For the no-fee case, also plot it on log-log axes and report the slope.
- Write three sentences on what surprised you.

**How to approach it.** Build it in order: simulator, then price and delta, then P&L, then the loop over frequencies, then the plots. Write the P&L for a single path with a plain for-loop first. Then vectorize it and check the two versions agree to many decimal places. That habit will save you hours later in the project.

**Check yourself.**

- For a stock at 100, strike 100, volatility 0.20 and one month to expiry, the call price is about 2.30 and delta about 0.51.
- If you never hedge, every path's P&L must equal the premium minus the payoff, exactly.
- With no fees, the average P&L should be close to zero. Before you run it, write down why you expect that. What does the premium represent when the stock has no drift?
- With no fees, the spread of P&L should shrink as you rebalance more often. Measure how fast.
- With fees, something different happens at high frequencies. Predict it before you run it, then explain the plot.
- Take one path with three rebalancing steps and work its P&L out on paper. Your code must match to the cent.

**Watch out for.**

- On the last step, time to expiry is zero and the delta formula divides by its square root. Handle expiry explicitly.
- Fees are charged on the first hedge (you start holding nothing) and on unwinding at expiry, not only on the trades in between.
- Comparing frequencies on different random paths adds noise to your comparison. Is there a way to use the same underlying paths for every frequency?

**Be ready to explain at the November 12 meeting.** What slope did you get on the no-fee plot, and why that number? Hint: think about how the hedging error from one rebalancing interval scales with the interval's length, and how many intervals there are.

**Done when.** A pull request with your notebook, the plots and your three sentences, reviewed by me.

### Week 2 (Nov 9 to 15): Task 2, and your component starts

**Task 2, assigned November 12 and due Thursday November 19: one admission-gate test each.** The admission gate decides whether a learned generator is realistic enough to train agents in. It's built from three statistical tests, one from each of you:

- **Dev 1, fat tails.** Excess kurtosis of generated daily returns must be within 40 percent of the real value.
- **Dev 2, volatility clustering.** Autocorrelation of absolute returns must stay positive out to lag 20.
- **Dev 3, no linear predictability.** Lag-1 autocorrelation of returns must be below 0.05 in absolute value, with no systematic pattern out to lag 10.

Each test is a function that takes generated returns (one row per window), plus reference real returns, and returns a pass or fail with the statistic and the threshold. Put it in the gate module with its own pytest tests.

Your test has to classify three inputs correctly: daily returns simulated from GBM, real pre-2017 SPY returns, and returns from an AR(1) process with coefficient 0.2. Before you run anything, write in the PR description whether each input should pass or fail your test, and why. If the code disagrees with your prediction, one of them is wrong; find out which. The Task 2 issue names the exact real-data file and date range, so all three of you test against the same series.

Statistics computed over many short windows have a trap. If you join the windows end to end and compute an autocorrelation, what happens at the joins? Decide how to compute each statistic properly and explain the choice in the PR.

**Your component also starts this week.** See your own section for week 2. Dev 3 starts the engine with me early in the week, before Task 1 is due, because the engine check is on Saturday.

## 4. Dev 1: markets

You own the data and the classical simulators: the data pipeline, GBM, Heston and the bootstrap. You also build the GAN in January, the Heston option pricer for Task B, and you work on the demo with me in February. Almost everyone depends on you early. Dev 2 needs the pooled return data in week 3, Dev 3 needs GBM through the frozen interface in week 4, and I need the real-data episode table in week 3.

### Week 2 (Nov 9 to 15): data pipeline and GBM

**Build.**

- A fetch script that downloads daily prices for the S&P 500 index and SPY from 2000 onward, plus a pool of liquid underliers for Dev 2's generator (30 or so large stocks and broad ETFs). The script must be able to rebuild the data from scratch.
- A storage layout under `data/` (kept out of git) using a columnar format, plus a manifest file that records the source, the date pulled and a checksum for each file.
- GBM as a Simulator that follows the conventions in section 7.

**How to approach it.** Free price data (for example through yfinance) is convenient but changes under you, because adjusted prices get revised when dividends are added. Decide how you'll pin what you downloaded. There is also a design question to answer in the data README. Hedging paths for SPX options use the index price, but the index ignores dividends and we assume zero interest rates. Which price series should the hedging paths use, and what small bias does that choice introduce? I make the final call, but I want your reasoning first.

**Check yourself.**

- Rerunning the fetch script reproduces the same checksums for historical dates.
- No trading days are missing compared with the exchange calendar. A market-calendar package can tell you which days should exist.
- GBM: the mean and standard deviation of simulated log returns match the theoretical values to within a few standard errors. The same seed gives identical paths, and different seeds give different ones. The first column of every path equals the starting price.

**Watch out for.** Time zones; market holidays; tickers that changed name or were delisted inside your date range.

**Done when.** Two PRs merged: the data pipeline with its manifest, and the GBM simulator with its tests.

**Hand-off.** Tell Dev 2 where the pooled returns live and how they're structured.

### Week 3 (Nov 16 to 22): firewall guard, realized volatility, episode table

**Build.**

- **The firewall guard.** One function that every fitting routine must call. It raises an error if any input date is later than December 31, 2016. Add a test that tries to fit on 2017 data and expects the error.
- **Realized volatility.** One shared definition, used everywhere: Heston calibration, the bootstrap, the agent's state, Task B and the diffusion model's conditioning. Pick an estimator, justify it in a docstring, and make sure it is trailing. The value on day t may only use data up to day t.
- **The real-data episode table** for 2017 to 2026, one row per month: start date, expiry date, index level at the start, the at-the-money strike, the premium and its source, and a quality flag. Agree with me on how start dates line up with listed monthly expiries before you write it.
- **The data quality battery**, if we've chosen a data source with option quotes: put-call parity residuals, positive bids, quoted spread under 15 percent of the mid price, and at least 90 percent of months covered. Output a short report.

**Check yourself.**

- Take one month and check every column of its row in the episode table by hand.
- Shift your realized volatility series by one day. If your code still passes the "no peeking" test, the test is wrong.
- Parity: residuals won't be exactly zero, because we ignore interest rates and dividends, and they'll drift a little with the strike. Work out what that drift should look like on a given day, then flag the quotes that sit off it.

**Done when.** The guard, realized volatility and the episode table are merged; the battery report is posted if it applies.

**Hand-off.** I need the episode table for the real-data replay. Dev 2 needs the realized volatility definition for conditioning.

### Week 4 (Nov 23 to 29): Heston simulator

**Build.** A Heston simulator with five parameters (mean-reversion speed κ, long-run variance θ, volatility of variance ξ, correlation ρ, starting variance v0), returning both price and variance paths through the frozen interface.

**How to approach it.** The obvious Euler scheme lets the variance go negative. Read about the full-truncation scheme (Lord, Koekkoek and van Dijk, 2010) and the QE scheme (Andersen, 2008), pick one and say why.

**Check yourself.**

- Set the volatility of variance to zero and the starting variance equal to the long-run variance. Heston should then behave exactly like GBM with variance θ, so test it against your GBM.
- With zero drift, the average final price equals the starting price to within standard error.
- The expected variance at time t has a closed form. Derive it and test against it.
- The realized correlation between the two driving shocks matches ρ.
- Halve the time step and check that your statistics converge.

**Watch out for.** The Feller condition, 2κθ > ξ². What happens when it's violated, and does your scheme still behave?

**Done when.** The Heston simulator is merged with these tests.

### Week 5 (Nov 30 to Dec 6): Heston calibration

**Build.** A calibration script that fits Heston's parameters to pre-2017 data, a parameter file, and a one-page report.

**How to approach it.** Answer this first, in writing. You could calibrate Heston to option prices or to the time series of returns and realized variance. Our agents train on paths that are supposed to look like what markets actually do, not like what option prices imply. Which data should you calibrate to, and why? Once that's settled, look at the variance equation over a single day. It looks a lot like an AR(1). What would its coefficients tell you about κ and θ? For a more formal approach, see Aït-Sahalia and Kimmel (2007).

**Check yourself.**

- Paths simulated with your fitted parameters roughly match pre-2017 reality: the volatility level, fatter tails than GBM and positive clustering. Run the Task 2 tests on them as a sanity check.
- The fitting code calls the firewall guard.
- Your estimates are stable when you drop a year of data.

**Done when.** The calibration script, parameter file and report are merged.

### Week 6 (Dec 7 to 13): the joint bootstrap

**Build.** A stationary block bootstrap (Politis and Romano, 1994) over pre-2017 data. It samples returns and realized volatility together by date, so Task B can use it.

**How to approach it.** Choose the average block length and justify it. What do you lose with a block length of one day? Of a year? Politis and White (2004) give an automatic choice if you want one. Then decide about drift. Every training world must be drift-neutral (GBM has zero drift). Pre-2017 history went up on average, so what would an agent learn if you left that drift in? Remove it, and document how.

**Check yourself.** With a block length of one day, volatility clustering should disappear from the output. Prove that your code shows it. With multi-week blocks, clustering survives. The average return of the output is zero after neutralization.

**Done when.** December 12: the joint bootstrap is merged with these tests, and GBM, Heston and the bootstrap all pass their own checks.

### Weeks 7 to 9 (Dec 14 to Jan 3): exams and break

No new work. If a long training run is going, check on it. Before January 4, sketch how the gate function will be laid out (one page is plenty). Before January 11, read Quant GANs (Wiese et al., 2020) and write a one-page GAN design note: architecture, loss, what you'll log, and how you'll know within two days whether training is failing.

### Week 10 (Jan 4 to 10): assemble the admission gate

**Build.** One gate function that runs all three Task 2 tests, the drift check and Dev 2's memorization audit. It returns a report table with each statistic, its threshold and pass or fail, and saves it to a file. Thresholds live in a single config file, not in the code.

**Check yourself.** Run the gate on GBM, Heston and the bootstrap. Classical simulators don't have to pass, because the gate only admits learned generators, but the results show whether the gate can tell the worlds apart. Before you run it, predict which checks each world will pass. Running the same gate twice with the same seed gives the same report.

**Done when.** By January 9, the gate is merged and Dev 2's first full report has run through it. Merge early in the week if you can, because Dev 2 is waiting on it.

### Week 11 (Jan 11 to 17): GAN, attempt 1

**Build.** A GAN trained on the same standardized return windows Dev 2 uses, with the architecture and loss from your design note. The two-week timebox starts January 11.

**Check yourself.**

- Log generator and discriminator losses. What does it look like when the discriminator wins completely?
- Every few hundred steps, run the gate tests on samples as a diagnostic.
- Check for mode collapse by measuring how different the samples are from each other.

**Watch out for.** Tuning forever. The timebox exists because GAN training can eat any amount of time you give it.

**Done when.** A gate report for attempt 1 is posted by January 16.

### Week 12 (Jan 18 to 24): GAN retry and decision

**Build.** One retry with a gradient penalty (Gulrajani et al., 2017), then the gate. You and I decide on admission by January 23. If the GAN is dropped, write half a page on what failed and why. That is a result we can report too.

### Week 13 (Jan 25 to 31): Heston option pricer

**Build.** A pricing function for European options under Heston, using the semi-closed form from Heston (1993). Task B needs it to price the hedge option in the Heston world.

**Check yourself.**

- Your pricer agrees with Monte Carlo prices from your own simulator to within standard error.
- With the volatility of variance set to zero, it reproduces Black-Scholes.
- Prices satisfy put-call parity.

**Watch out for.** Our Heston parameters were fitted to real-world paths, and pricing needs risk-neutral parameters. Using the same parameters assumes the market charges nothing for volatility risk. Write that assumption down where the pricer is used.

**Also this week.** Finalize the episode table with me, and give Dev 2 the EWMA volatility convention for pricing in the bootstrap world.

### Week 14 (Feb 1 to 7): cross-reproduction and demo data

**Build.** Pick one cell of Dev 3's results table. From a clean clone of the repo, rerun its config and match the number to within seed variation. If you can't, we have a reproducibility bug, and finding it before February 6 is worth more than anything else you could do this week. Then extract everything the demo needs for the 2020 crash: the real paths, the agents' decisions at each cost level and the baselines.

### Weeks 15 and 16 (Feb 8 to 21): the demo, with Ethan

**Build.** The CUCAI demo. It replays the 2020 crash, runs three hedgers side by side and has a cost slider; a second panel shows the no-trade band.

**How to approach it.** Precompute results for every cost level the slider allows, so the demo only reads files. A live demo that trains anything can fail in front of judges, and one that reads files can't. Keep the user interface simple.

**Done when.** By February 20, the demo runs end to end on a laptop with no internet connection. Reading week falls inside this stretch and counts as working time.

### Week 17 (Feb 22 to 28): write-up and poster

Write the methods paragraph for your simulators and make one figure that shows how they differ, then your poster section. Drafts are due February 27. Demo rehearsals run from March 1 until CUCAI.

## 5. Dev 2: generator

You own the diffusion model: training it, conditioning it on volatility, running the memorization audit, getting it through the gate and, for Task B, generating returns and volatility jointly. The generator is the component most likely to need retries, which is why it starts in November. You depend on Dev 1's pooled data from week 3. Until then, you'll work on toy data where you know the answer.

### Week 2 (Nov 9 to 15): diffusion on toy data

**Build.** A minimal denoising diffusion model for short one-dimensional vectors (return windows), trained on two toy datasets with known properties: independent Student-t returns with 5 degrees of freedom, and returns simulated from a GARCH(1,1) process.

**How to approach it.** Read sections 2 and 3 of Ho, Jain and Abbeel (2020) on the forward process, the noise-prediction objective and sampling. The noise schedule in Nichol and Dhariwal (2021) is worth a look. Start with a small network and a modest number of diffusion steps. There's a design question to settle with me this week: how long should a window be? The agent's state includes recent realized volatility on the first day of each episode, so the window has to cover more than just the 21 days of the episode.

**Check yourself.**

- Work out the excess kurtosis of a Student-t with 5 degrees of freedom. Samples from your model should land near it.
- On the GARCH data, samples should show positive autocorrelation of absolute returns. On the Student-t data, they shouldn't.
- At the last step of the forward process, the noised data should be indistinguishable from standard normal noise. Test that directly.
- Samples are not copies of training points; check nearest-neighbour distances.

**Watch out for.** Unscaled inputs; using far more diffusion steps than such a small problem needs; judging the model only on data it trained on.

**Done when.** A PR with the toy model and a short note on how close each statistic came.

### Week 3 (Nov 16 to 22): real returns, version 0

**Build.** An unconditional model trained on pooled pre-2017 return windows from Dev 1's data.

**How to approach it.** You have to standardize returns by volatility so that different assets and periods are comparable. You also have to be able to undo the standardization later, to produce price paths at the scale of the S&P 500. Decide how you'll do both before writing code. Split your data by time and by asset. Holding out entire assets and years is what makes the memorization audit meaningful.

**Check yourself.** Run all three Task 2 tests on your samples against held-out real data. Check the average return for drift. Plot samples next to real windows, but don't trust your eyes over the tests.

**Done when.** A version 0 report: which checks pass, which fail, and your guess why.

### Week 4 (Nov 23 to 29): conditioning and the memorization audit

**Build.**

- **Conditioning on the volatility state.** A simple approach is to embed the conditioning value alongside the diffusion timestep.
- **The memorization audit.** For each generated window, find the distance to its nearest training window. Compare those distances with the nearest-neighbour distances from held-out real windows to the training set. Report the fraction of generated windows that fall below the 1st percentile of the real-to-training distances. The gate requires that fraction to be under 1 percent.

**How to approach it.** You have to choose a distance. Raw standardized returns? Cumulative returns? Each choice detects a different kind of copying, so think about which kind matters here. With around 100,000 windows on each side, a full distance matrix won't fit in memory, so compute it in chunks.

**Check yourself.**

- Raising the conditioning value should raise the realized volatility of the generated windows, monotonically.
- Feed the audit the training windows themselves and it should flag nearly all of them. Feed it fresh GBM windows and it should flag almost none. If it can't tell those two apart, it can't be trusted on the model.

**Done when.** Conditioning and the audit are merged with these tests.

### Week 5 (Nov 30 to Dec 6): gate dry run

Run Dev 1's draft gate tests and your audit on your current model. For each check that fails, write down what kind of failure it is and which fix you'd try first. Use the PRD's guide: thin tails point to capacity or conditioning, memorization points to more data or early stopping, and autocorrelation artifacts point to drift handling.

### Week 6 (Dec 7 to 13): version 1 and drift neutralization

**Build.** A tuned conditional model, plus drift neutralization of its output.

**How to approach it.** You can remove drift per window or globally. Does removing it per window distort anything real data has? Pick a method and justify it. The gate's drift check is applied after neutralization.

**Done when.** By December 12, version 1 is merged and a dry-run report is logged: the three gate tests, the drift check and your audit, run separately on version 1. The assembled gate comes in January.

### Weeks 7 to 9 (Dec 14 to Jan 3): exams and break

Checkpointed runs only. Before January, write a one-page plan for joint generation: generating returns and the volatility variable together as a two-channel window, and how you'll check that the relationship between them is realistic.

### Week 10 (Jan 4 to 10): first full gate attempt

**Done when.** By January 9, a full gate report is logged for the diffusion model: every statistic against its threshold, plus the audit, run through Dev 1's assembled gate. If the assembled gate isn't merged by midweek, run the pieces separately and rerun through the gate when it lands. Passing on the first try isn't required. A clear, honest report is.

### Weeks 11 and 12 (Jan 11 to 24): retries and the admission decision

Two retry cycles of one week each, each fix matched to the failure mode you diagnosed. By January 23 you and I decide on admission. If the model is admitted, freeze the checkpoint and record its hash in the configs, so every result points to exactly one model. Start joint generation in parallel.

### Week 13 (Jan 25 to 31): joint generation and the extended gate

**Build.** The two-channel model, plus the extended gate checks: the volatility variable's autocorrelation, and its correlation with returns, must fall within bands around the real values.

**Check yourself.** Confirm on real data first that returns and volatility changes are negatively correlated (the leverage effect), then check that your model reproduces it.

### Week 14 (Feb 1 to 7): cross-reproduction and the audit write-up

Rerun one of Dev 1's simulator test results from a clean clone and match it. Then write the generator part of the audit report: memorization results and artifact checks, including anything that failed along the way.

### Week 15 (Feb 8 to 12): the pricing convention check

In the diffusion world, the hedge option is priced with Black-Scholes at the generated volatility. Using Dev 1's Heston pricer, measure how much that convention moves results in the Heston world, where we know the right price. By February 13, you and I decide whether joint generation goes into Task B.

### Week 16 (Feb 13 to 21): Task B in the diffusion world

If joint generation passed, run the Task B training in the diffusion world with Dev 3's environment and configs, so Dev 3 can run the PPO ablation the same week. Reading week is working time in this plan. Results are in by February 20.

### Week 17 (Feb 22 to 28): write-up and poster

Write the methods paragraph for the generator and make a figure comparing generated and real windows, then your poster section. Drafts are due February 27, and rehearsals run from March 1 until CUCAI.

## 6. Dev 3: hedger

You own the agent, the training loop, the PPO ablation and the Task B environment, and you co-own the P&L engine with me. Phase 1 is mostly yours: three of the four weekly checkpoints test your code. The engine comes first, because every number in the project passes through it.

### Week 2 (Nov 9 to 15): the P&L engine, with Ethan

**Build.** The engine function: price paths, holdings, a contract and a cost rate go in, and per-path P&L comes out. It must be differentiable end to end in PyTorch, because training backpropagates through it.

**How to approach it.** Before any code, early in the week and before Task 1 is due, the two of us write the accounting rules down in `docs/engine.md`. When is a trade made, and at which price? How long is a holding kept? What happens on the first day and at expiry? What is a cost charged on? Disagreements we settle on paper cost minutes. The same disagreements found in code cost days.

**Check yourself.** These become the engine's test suite:

- No hedge: P&L equals the premium minus the payoff, exactly.
- A three-step path worked out by hand. Commit the hand calculation next to the test, and match it to the cent.
- Raising the cost rate never raises the average P&L.
- Gradients flow: backpropagate from the P&L sum to the holdings and check the gradient is finite and not zero.
- **The convergence check, due November 14.** Delta hedging with no costs, error spread against rebalancing frequency on a log-log plot. The slope must match the value you explained in Task 1, within a tolerance you choose and defend. It runs in CI on every merge, so it has to be fast. How few paths can you use and still get a stable slope?

**Watch out for.** In-place tensor assignment breaks gradients silently. Watch for off-by-one errors between the holding index and the price index, and for charging the unwind cost twice.

**Done when.** By November 14, the engine is merged with CI passing.

### Week 3 (Nov 16 to 22): the loss, the network and the rollout

**Build.**

- Expected Shortfall at a chosen level, on the loss (minus P&L), in two ways: by sorting and averaging the tail, and in the Rockafellar-Uryasev form with an auxiliary variable (Rockafellar and Uryasev, 2000).
- The policy network from the PRD: two or three layers of about 32 units. Its inputs are log-moneyness, time to expiry (scaled), previous holding and recent realized volatility. Its output is bounded between 0 and 1.2.
- A rollout that steps through time, builds the state, calls the policy and collects holdings, vectorized over paths.

**Check yourself.**

- **The ES test, due November 21.** Test both implementations against a distribution whose ES you can compute exactly. Derive it, or look it up, for the normal distribution; for the uniform you can do it by hand. Set the tolerance from the sample size, not by eye. The two implementations must agree with each other.
- Roll out a policy that always returns Black-Scholes delta. It must reproduce the engine results you got in week 2.

**Questions to answer in the PR.** How many paths land in the 2.5 percent tail with a batch of 512? With 4,096? What does that mean for training? And why does the network need the previous holding as an input?

**Done when.** The loss, the network and the rollout are merged by November 21.

### Week 4 (Nov 23 to 29): zero-cost training and delta recovery

**Build.** The training loop: a fresh batch of paths every iteration, the Adam optimizer, logging to Weights and Biases, and fixed seeds. Evaluate on a held-out set of about 100,000 paths, with the Black-Scholes baseline scored on the same paths.

**Check yourself, due November 28.** In GBM with no costs, the trained policy must stay within 0.05 of Black-Scholes delta (mean absolute deviation over evaluation states), and its ES must be within 5 percent of the delta hedge's. Plot the policy's output against delta. Show it for three seeds.

**Watch out for.** Feeding raw prices into the network; a learning rate that makes the loss jump around; any drift in the training paths.

**Done when.** The training loop and the delta-recovery plots are merged by November 28.

### Week 5 (Nov 30 to Dec 6): costs on, beat delta

**Build.** Train with costs: first at a high level where the effect is obvious, then at the three planned levels. Compare against the delta hedge and the threshold baseline I'm building.

**Check yourself.**

- **Validation, due December 5.** With costs, the agent's ES beats the delta hedge by more than the confidence interval, across three seeds.
- Plot the policy's output against moneyness at a fixed time, once for each of several previous holdings. What would a no-trade band look like in this plot? Describe it before you make the plot.
- Compare turnover with the delta hedge.

If validation fails, work through the PRD's diagnosis order, starting with the convergence check.

**Done when.** The validation results are reviewed by December 5.

### Week 6 (Dec 7 to 13): a training harness for any world

**Build.** Training driven by config files. A YAML file names the simulator and its parameters, the contract, the cost level and the seed, and one command reproduces a run. Add checkpointing and resuming. Add the out-of-the-money put as a second contract.

**Check yourself.** Two runs with the same config and seed give identical results on CPU. On GPU, find out which settings affect determinism and document them.

### Weeks 7 to 9 (Dec 14 to Jan 3): exams and break

Checkpointed runs only. Read Cao, Hull et al. (2022) and the PPO paper (Schulman et al., 2017). Write a Task B design note covering the state, the action and its bounds, the cost tiers, how the monthly roll works, what the futures leg does each day, and how P&L is computed with two instruments.

### Week 10 (Jan 4 to 10): integration dry run, then Task A training

Start with a small grid end to end, with me: agents trained in Heston and the bootstrap, each evaluated in both. Its job is to find the integration problems in the first days of January, before the full runs start. Then begin the Task A runs in GBM, Heston and the bootstrap.

### Weeks 11 and 12 (Jan 11 to 24): Task A training

Train Task A agents in every simulator that's ready: GBM, Heston and the bootstrap first, then the GAN and diffusion worlds after January 23 if they're admitted. That means five seeds, three cost levels and two contracts. Count the runs first and schedule them across Colab and Kaggle. Freeze the evaluation path sets with me so every agent is scored on the same paths.

### Week 13 (Jan 25 to 31): generator worlds, the grid, and the Task B environment

Add the admitted generator worlds to the training runs, and run the Task A grid with me. Start the Task B environment. The book is short one call and one put. At each close the futures leg automatically sets net delta to zero. The agent chooses how many units of the hedge option to hold, within gamma and vega limits. There are two cost tiers and a monthly roll.

**Check yourself.**

- If the agent always holds zero hedge options, Task B's P&L must equal the delta-only baseline exactly.
- After each close, net delta is approximately zero; add an assertion.
- The agent's holdings never break the limits.

### Week 14 (Feb 1 to 7): cross-reproduction and Task B tests

Rerun one of Dev 2's gate reports from a clean clone and match it. Finish the Task B tests. Help get the February 6 table out.

### Week 15 (Feb 8 to 12): Task B training

Train Task B agents in Heston and the bootstrap, using Dev 1's pricing conventions. Compare them with the delta-only desk and the gamma- and vega-neutral rules. The diffusion world joins if joint generation passes on February 13; Dev 2 runs those jobs with your configs.

### Week 16 (Feb 13 to 21): the PPO ablation

**Build.** One PPO agent in one simulator for Task A, with the same state, action and bounds as the deep hedging agent. A library implementation is fine (Stable-Baselines3, for example) if you wrap our environment properly. The reward design is a real decision, because PPO needs per-step or end-of-episode rewards rather than an ES loss. Decide it with me and document it. Then compare the PPO agent with the deep hedging agent in the same world. It's a one-week timebox, ending February 20. Reading week is working time in this plan.

### Week 17 (Feb 22 to 28): write-up and poster

Write the methods paragraph for the agent and the training, and make the delta-recovery and band figures, then your poster section. Drafts are due February 27, and rehearsals run from March 1 until CUCAI.

## 7. Conventions all code follows

These are drafts until the interfaces freeze on November 24. After that, `docs/apis.md` is the authority.

- **Time.** Trading days, with a time step of 1/252 years. An episode is 21 steps, so a price path has 22 values including the start.
- **Prices.** Simulated paths start at 100. Real paths are rescaled so that each episode starts at 100, so agents always see the same scale.
- **Shapes.** Spot and volatility paths have one row per path and one column per time point. Holdings have one column per step: the holding chosen at time t is held until t + 1.
- **Numbers.** float32 for training. The evaluator accumulates P&L in float64 for reporting.
- **Volatility** is annualized and written as a decimal, so 0.20 rather than 20.
- **Costs** are proportional rates on the value traded, as decimals, so 5 basis points is 0.0005.
- **Randomness.** Every function that draws random numbers takes a seed or a generator and never touches the global random state.
- **Runs.** One run is one config file plus a seed. Results go under `results/<run id>/` along with a copy of the config.
- **The firewall.** Every fitting routine calls Dev 1's guard.

## 8. Extra references in this workbook

The PRD's references cover most of what you need. These are the additional papers mentioned above:

- Aït-Sahalia, Y., and Kimmel, R. (2007). Maximum likelihood estimation of stochastic volatility models. Journal of Financial Economics, 83(2), 413-452.
- Andersen, L. (2008). Simple and efficient simulation of the Heston stochastic volatility model. Journal of Computational Finance, 11(3), 1-42.
- Gulrajani, I., Ahmed, F., Arjovsky, M., Dumoulin, V., and Courville, A. (2017). Improved training of Wasserstein GANs. NeurIPS. arXiv:1704.00028.
- Lord, R., Koekkoek, R., and van Dijk, D. (2010). A comparison of biased simulation schemes for stochastic volatility models. Quantitative Finance, 10(2), 177-194.
- Nichol, A., and Dhariwal, P. (2021). Improved denoising diffusion probabilistic models. arXiv:2102.09672.
- Politis, D. N., and White, H. (2004). Automatic block-length selection for the dependent bootstrap. Econometric Reviews, 23(1), 53-70.
- Rockafellar, R. T., and Uryasev, S. (2000). Optimization of conditional value-at-risk. Journal of Risk, 2(3), 21-41.
