# Task 1: build a delta hedge by hand

**Due:** Thursday, November 12, at the second meeting. **Reviewer:** Ethan.

You will sell one option, hedge it, and measure what hedging costs.

## Getting started

Copy `template.ipynb` to `<your-github-username>.ipynb` in this folder and work in your copy. Open the pull request from a branch named `<your-name>/task01`.

## Spec

- Simulate GBM price paths with starting price 100, volatility 0.20 and zero drift, over one month of 21 trading days. Use at least 10,000 paths, and vectorize over paths (no Python loop over paths).
- Write the Black-Scholes call price and delta with zero interest rate.
- Sell one at-the-money call (strike 100) for its Black-Scholes price, then hedge it with delta at several rebalancing frequencies, for example 5, 21, 84 and 336 times over the month.
- For every path, compute the final P&L: premium received, plus gains and losses on the shares, minus the payoff you owe.
- Do this with no trading fees, then again with a proportional fee of 0.1 percent of the value of every trade (a rate of 0.001). Everyone uses the same rate so the plots can be compared.
- Plot the standard deviation of P&L against rebalancing frequency, with and without fees. For the no-fee case, also plot it on log-log axes and report the slope.
- Write three sentences on what surprised you.

## How to approach it

Build it in order: simulator, then price and delta, then P&L, then the loop over frequencies, then the plots. Write the P&L for a single path with a plain for-loop first. Then vectorize it and check the two versions agree to many decimal places.

## Check yourself

- For a stock at 100, strike 100, volatility 0.20 and one month to expiry, the call price is about 2.30 and delta about 0.51.
- If you never hedge, every path's P&L must equal the premium minus the payoff, exactly.
- With no fees, the average P&L should be close to zero. Before you run it, write down why you expect that.
- With no fees, the spread of P&L should shrink as you rebalance more often. Measure how fast.
- With fees, something different happens at high frequencies. Predict it before you run it, then explain the plot.
- Take one path with three rebalancing steps and work its P&L out on paper. Your code must match to the cent.

## Watch out for

- On the last step, time to expiry is zero and the delta formula divides by its square root. Handle expiry explicitly.
- Fees are charged on the first hedge (you start holding nothing) and on unwinding at expiry, not only on the trades in between.
- Comparing frequencies on different random paths adds noise to your comparison. Is there a way to use the same underlying paths for every frequency?

## Done when

A pull request containing your notebook, your two plots saved as PNG files (`<your-github-username>_no_fee.png` and `<your-github-username>_with_fee.png`) and your three sentences. Be ready to explain your slope at the meeting.
