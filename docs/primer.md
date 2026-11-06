# Project Primer: Deep Hedging in Generated Markets

**Author:** Ethan Bobrik, Project Manager, Western AI Club
**Date:** November 5, 2026
**Version:** Background reading for the team
**Status:** Written for anyone joining the project or reviewing it without a background in options, hedging or the machine learning involved.

---

This is the background for the project, written for someone who has never traded an option or trained a generative model. Read Parts I to III in order, because each one builds on the last. Part IV covers how the team works, and Part V lists papers in the order you'll need them. If you already know derivatives, skim Part I; if you already know deep learning, skim Part II. The PRD has the exact specification. This document explains why the specification looks the way it does.

## Part I: The finance

### 1. Selling an option

A call option gives its buyer the right to buy a stock at a fixed price, the strike, on a set date. The buyer pays for that right up front, and the payment is called the premium. Say SPY trades at 500 and you sell a one-month call with a 500 strike for about 9 dollars. If SPY finishes the month below 500, the option expires worthless and you keep the 9 dollars. If it finishes at 530, you owe the buyer 30, and at 600 you owe 100. The most you can make is the premium. There is no limit on what you can lose.

Banks and market makers sell options like this all day. They aren't trying to guess where the market goes; they want to keep the premium and get rid of the risk. The way they get rid of it is called hedging.

### 2. Delta

When the stock moves, the option's value moves too, and delta is the ratio between the two. With a delta of 0.5, a one-dollar rise in SPY raises the option's value (and so your liability as the seller) by about fifty cents. To offset that, you hold half a share of SPY for each option you sold. A small move up now costs you fifty cents on the option and earns fifty cents on the stock.

Black and Scholes showed in 1973 that if you adjust this holding continuously, pay nothing to trade, and the stock follows geometric Brownian motion (GBM, a random walk with constant volatility), the hedge reproduces the option exactly. The premium covers the cost of running the hedge and no risk is left over.

### 3. Why hedging costs money

The trouble is that delta changes as the stock moves. If the stock goes up, delta goes up, and you have to buy more shares at the higher price. If it comes back down, delta falls and you sell at the lower price. Every swing makes you buy high and sell low by a small amount. In the Black-Scholes world, that loss is exactly what the premium pays for.

Real markets break each of those assumptions. You can only trade at discrete times (once a day in this project), every trade pays a spread and fees, and prices have crashes, fat tails and long stretches of high volatility. Once trading costs money, there's a trade-off: follow delta closely and pay a lot in costs, or follow it loosely and carry more risk.

### 4. The no-trade band

In 1997 Whalley and Wilmott worked out what the best policy looks like when costs are small. It is a band. You compute the ideal holding, leave your hedge alone while it stays within some distance of that target, and trade back only when it drifts further. They also derived how wide the band should be: its width grows with the trading cost to the power one third and with the option's gamma (section 5) to the power two thirds, and shrinks with the hedger's risk aversion to the power one third.

The one third comes from comparing two costs. Being a distance d away from the target costs you roughly d squared in extra risk, while trading back costs something proportional to d. Balancing a quadratic cost against a linear one gives a cube root. Barles and Soner analysed the same problem differently and found a band plus a volatility adjustment, with a centre that isn't the Black-Scholes delta. One of our research questions is which of the two our agents end up looking like.

This isn't only theory. S&P's delta-hedged index methodology rebalances only when net delta moves more than 0.1 from its target, which is a no-trade band set by hand.

### 5. Gamma, vega, theta, and what a desk actually does

Delta is the first derivative of the option's value with respect to the stock price. Gamma is the second derivative, how quickly delta itself changes, so it tells you how much rebalancing a position will need. Vega is the sensitivity to volatility, and theta is the value lost as time passes. Desks explain each day's P&L in these terms (so much from delta, so much from gamma, vega and theta, and a remainder nobody can account for). That report is called the P&L explain, and we produce one for each of our agents.

On a real index desk, delta isn't much of a decision. The desk has to bring its net delta to roughly zero every day, and it does this with index futures, which are cheaper and more liquid than the underlying stocks and avoid dealing with dividends. The book is managed through its total Greeks rather than option by option. What the trader really decides is how much gamma and vega to carry within the desk's limits, usually by trading at-the-money options, which carry a lot of both. Task B in this project reproduces that setup.

### 6. Regulation

Under the Basel FRTB rules, banks calculate market-risk capital using Expected Shortfall at 97.5 percent, the average of the worst 2.5 percent of outcomes. It replaced Value at Risk, which only tells you where the tail begins. FRTB also makes each trading desk pass a P&L attribution test. The P&L that the desk's risk model predicts is compared with the P&L the front office actually reports, using a Spearman correlation and a Kolmogorov-Smirnov statistic, and the desk lands in a green, amber or red zone. A red desk loses permission to use its own models.

That test is really a check on whether the world the model assumes matches what actually happened, which is close to our own research question. So we apply a version of it to every trained agent and report which training simulators would keep a desk in the green zone.

## Part II: The machine learning

### 7. The agent

The hedging agent is a neural network with two or three hidden layers of about 32 units, a few thousand parameters in total. Each simulated day it reads a handful of numbers: where the stock is relative to the strike, how much time is left, what it currently holds and how volatile the market has been lately. It outputs the position to hold, kept within fixed bounds so it can't take leveraged bets on direction.

The current holding is an input for a reason. Without it, the network can't compare the cost of changing its position with the benefit, and it could never learn to leave its hedge alone inside a band.

### 8. Training

Training works like this. Draw a fresh batch of price paths from a simulator. Run the network's daily decisions along each path through a P&L engine that charges costs on every trade and settles the option at expiry. That gives you a distribution of outcomes, which you score by its Expected Shortfall, the average of the worst ones. Adjust the weights by backpropagation to make that tail less bad, draw a new batch and repeat. The method comes from the deep hedging paper by Buehler and co-authors (2019). There are no rewards, replay buffers or policy gradients, so the usual instability of reinforcement learning doesn't come into it. We do train one agent with PPO, a standard reinforcement learning algorithm, purely as a check that our findings don't depend on the training method.

Two things follow from this. The network can't memorize its training data, because there is no fixed training set; every batch is new. And we can check it against theory. In a zero-cost GBM world the trained agent has to rediscover delta hedging, since delta is provably optimal there. With costs, it should develop a band and beat plain delta. Both are published results, and reproducing them is our November milestone.

### 9. Simulators and generative models

A market simulator is anything that produces plausible price paths. GBM has a single volatility number. Heston lets volatility move on its own, cluster and jump when prices fall, which is much closer to real markets. A block bootstrap isn't really a model: it cuts real history into blocks a few weeks long and stitches them together in new orders. Every real feature is there, but it can only reuse what history contains.

A diffusion model, the same family as modern image generators, learns to remove noise. You take real windows of returns, add noise in small steps until nothing recognizable is left, and train a network to undo one step at a time. Run the trained network starting from pure noise and it produces new windows that look statistically like real markets without copying any particular one. Ours is small. It works on short windows of daily returns (together with one volatility variable for Task B) and trains on data pooled across many assets.

We also train a GAN, which is two networks trained against each other: one generates return windows and the other tries to tell them apart from real ones, until the generator fools it. GANs are the standard generator in the literature on simulated markets, so the diffusion model needs one to be compared against. GAN training is famously unstable, so it gets a fixed two weeks.

The danger with any learned generator is that it memorizes history or contains a small statistical quirk, such as a slight upward drift, that an agent can exploit to look good. So both the GAN and the diffusion model have to pass a set of numerical checks, which we call the admission gate, before any agent trains in them.

## Part III: The experiment

### 10. The idea

An agent learns to hedge whatever world it trains in. Train it on GBM and it learns habits that suit a market with no crashes and steady volatility, and then it meets the real thing. Pickard and Lawryshyn's 2023 review of 17 deep RL hedging studies found that nearly all of them trained on GBM or something close to it, and as far as I can tell nobody has compared training simulators under controlled conditions. That comparison is the project.

The training simulator is the only thing we change. The agent, its training budget, the contracts and the evaluation stay fixed. There are five simulators, roughly in order of realism: GBM, Heston, the block bootstrap, the GAN and the diffusion model.

### 11. The two tasks

Task A is the core. Every agent and baseline hedges the same contract, a one-month at-the-money SPX call. SPX options are European and settle in cash, which keeps the accounting simple. A short out-of-the-money put is the second contract, and we run three cost levels. The agent decides how much of the underlying to hold each day.

Task B is the desk version. The agent manages a small book, the short call and the short put together. Net delta is set to zero at each close using futures, automatically, the way a real desk is required to do it. The agent only decides how much of an at-the-money option to hold to manage gamma and vega, within limits. Futures are cheap to trade and options are expensive, so there are two cost levels. Task B runs in the Heston, bootstrap and diffusion simulators, the three with real volatility dynamics, and it's where I expect the simulators to differ most.

### 12. The firewall

Every simulator, including the Heston calibration and the bootstrap's pool of blocks, is fitted only on data up to the end of 2016. All real-data testing starts in 2017, so the 2020 crash and the 2022 inflation shock are new to every model in the study. Several recent papers on LLM trading agents turned out to have tested on periods their models had already seen, which made their results meaningless. The firewall is how we avoid the same mistake.

### 13. How agents are scored

Each agent is tested in every simulator and on real data, with five random seeds per agent. That shows both how it transfers between simulators and how it does in reality.

For the real data we replay history month by month from 2017 to 2026. Each month we sell the contract at its actual market price, hedge it daily along the real price path with costs charged, and record the final P&L. That gives about a hundred separate episodes, and the crisis months are reported on their own.

The headline number is Expected Shortfall at 97.5 percent, the regulators' measure. We also report the distribution of hedging error, turnover and costs. Mean P&L is always shown separately from its spread, because an agent that speculates instead of hedging shows up as a high mean with a wide spread.

Each agent also gets a PLAT-style score, where the P&L distribution its training simulator predicted is compared with what it actually earned on real data, using the Kolmogorov-Smirnov statistic and the regulatory zones. And each one gets a P&L explain, so we can see where any advantage comes from.

All agents and baselines are scored on exactly the same held-out simulated paths, which makes every comparison paired. If the paths happen to include an unusually rough stretch, it hits every agent equally and drops out of the differences. Headline real-data numbers use only non-overlapping episodes, with confidence intervals from a block bootstrap.

### 14. The theory module

This is the most mathematical part, and I'm running it. Experiment 1 trains agents in GBM across a grid of cost levels and risk aversions, which takes minutes per run. For each trained agent we measure its no-trade band directly: fix the market state, vary the previous-holding input and find the range where the agent chooses not to trade. Then we test the three predicted scaling laws by regression (band width against cost should have slope 1/3, against gamma 2/3 and against risk aversion -1/3), and check whether the band is centred on delta, which tells Whalley-Wilmott apart from Barles-Soner.

Experiment 2 does the same for agents trained in the bootstrap and diffusion simulators, where no theory exists, and measures how the laws change. A 2026 paper already brings these results into deep hedging by building the band into the network. We're asking something different: does the band show up without being built in, and what does it look like where there's no theory to predict it?

### 15. If nothing differs

If agents trained in richer simulators hedge real markets better, especially in the crises and in Task B, then the habit of training on GBM is costing money. If all five simulators give similar results, the cheap defaults are fine for these contracts and expensive generators aren't worth building for this purpose. People working on this would want to know that as well. The band measurements are useful in either case.

## Part IV: How the team works

There are three developers and me. Dev 1 owns market data and the classical simulators (GBM, Heston and the bootstrap), writes the statistical tests the admission gate uses, and builds the GAN in January. Dev 2 owns the diffusion model. Dev 3 owns the hedging agent, runs the PPO ablation in February and shares the P&L engine with me. I own the rest of the evaluation code, the baselines, the theory module and integration. Every component has a named backup and a README that the backup can work from.

The components talk through three interfaces: a Simulator that returns paths, an Agent that maps a state to a bounded action, and an Evaluator that turns paths and actions into metrics. They freeze on November 24. The P&L engine is the one piece every number passes through, so it has two owners, property tests, and a convergence check that runs on every merge. At zero cost in GBM, delta-hedging error has to fall as rebalancing gets more frequent, at a known rate.

Your first task, whatever your role, is to build a Black-Scholes delta hedge by hand on simulated GBM paths and plot hedging error and cost against rebalancing frequency. It covers the whole problem on a small scale, and your plot becomes the first baseline in the results. The second task is one statistical test, for example a check for fat tails, written as a pytest function. It goes into the admission gate.

The scope is protected by a cut list we agreed on in advance, so if something has to go in February nobody needs to argue about what. Python is the only prerequisite, and everything in this primer gets covered again in the first-week workshops.

## Part V: Reading list

Read the first group in week one. After that, it depends on your role.

**Everyone, in week one**

1. This primer, then the PRD.
2. Buehler, Gonon, Teichmann and Wood (2019), "Deep hedging," Quantitative Finance 19(8), arXiv:1802.03042. Read sections 1 to 3 closely, since that's the training method we use, and skim the rest.
3. Pickard and Lawryshyn (2023), "Deep reinforcement learning for dynamic stock option hedging: A review," Mathematics 11(24), 4943. The introduction and the summary tables show how much of the field trains on GBM.
4. If Part I felt fast, the chapters on option properties, the Greeks and delta hedging in Hull's Options, Futures, and Other Derivatives.

**Dev 1, markets**

- Heston (1993), Review of Financial Studies 6(2), for the model you'll calibrate.
- Politis and Romano (1994), "The stationary bootstrap," Journal of the American Statistical Association 89(428), for the bootstrap.
- Cont (2001), "Empirical properties of asset returns: Stylized facts and statistical issues," Quantitative Finance 1(2). This is the list of properties the admission gate tests.
- Wiese et al. (2020), "Quant GANs," Quantitative Finance 20(9), and Wiese, Bai, Wood and Buehler (2019), arXiv:1911.01700, for the GAN you'll build in January.

**Dev 2, generator**

- Ho, Jain and Abbeel (2020), "Denoising diffusion probabilistic models," arXiv:2006.11239. The model you'll implement.
- CoFinDiff (IJCAI 2025), arXiv:2503.04164, the closest earlier work: a financial diffusion generator tested through one hedging experiment.
- Cont (2001), for the same reason as Dev 1.
- Wiese et al. (2020), "Quant GANs," Quantitative Finance 20(9), for how generated returns are usually evaluated, and because the GAN is what your model will be compared against.

**Dev 3, hedger**

- Buehler et al. (2019), all of it.
- Imaki et al. (2021), "No-transaction band network," arXiv:2103.01775. It builds the band into the architecture, which is a useful contrast with our free-form agent.
- Cao, Hull and co-authors (2022), "Gamma and vega hedging using deep distributional reinforcement learning," arXiv:2205.05614. Task B follows the desk structure described here.
- Schulman et al. (2017), "Proximal policy optimization algorithms," arXiv:1707.06347, for the PPO ablation.

**Evaluation and baselines (Ethan)**

- Mikkilä and Kanniainen (2023), "Empirical deep hedging," Quantitative Finance 23(1), the model for our real-data replay.
- FINSABER, arXiv:2505.07078, and The Profit Mirage, arXiv:2510.07920. The abstracts and conclusions explain why the firewall exists.
- Leland (1985), Journal of Finance 40(5), for the cost-adjusted delta baseline.
- S&P Dow Jones Indices, delta-hedged straddle indices methodology, for the 0.1 threshold baseline.

**Theory module (Ethan, and anyone curious)**

- Whalley and Wilmott (1997), Mathematical Finance 7(3). The band formula and the one-third law; work through the balancing argument.
- Barles and Soner (1998), Finance and Stochastics 2, for the other asymptotic answer.
- The 2026 band paper, arXiv:2603.29994. Read it before the module is written up. It also shows that the formula understates band width at large costs, which limits where we can test the scaling.
- Zakamouline (2006), for approximations beyond small costs.
- Hodges and Neuberger (1989), the original utility-based model, skimmed for context.

**Regulatory background (skim)**

- Basel FRTB, minimum capital requirements for market risk: the ES 97.5 definition and the P&L attribution test.
- Federal Reserve SR 11-7, guidance on model risk management, which our validation steps line up with.

When you read a paper, start with the abstract, the figures and the conclusion. Then read the method section with a pencil, and reproduce one number or plot if you can. You understand a paper once you can say what it assumed and what it showed, and name one thing it couldn't show.

## Self-test

You understand the project when you can answer these without looking anything up.

1. Why does selling an option force the seller to trade the stock at all?
2. Why does hedging once a day lose money on market swings, even before fees?
3. Why do trading costs make textbook delta hedging suboptimal, and what does the better policy look like?
4. Where does the power of one third in the band formula come from?
5. Why is minimizing Expected Shortfall through simulated P&L not reinforcement learning, and why is that useful?
6. Why can't the agent memorize its training data?
7. Why would an agent trained on GBM struggle in a crash, and what specifically would it get wrong?
8. Why can the simulators only see data from before 2017?
9. On a real desk, which hedging decision is mandatory and which is up to the trader, and which instrument is used for each?
10. What does a red zone on the PLAT-style score say about a training simulator?
11. If every row of the results table looks the same, what have we learned, and why is it still worth publishing?

If an answer feels shaky, go back to the relevant section and its entry in the reading list.
