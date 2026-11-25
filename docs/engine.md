# P&L engine: accounting rules

**Status:** Rules written by Ansh (Dev 3) and reviewed by Ethan, November 24, 2026. Ethan builds the engine from these rules, and the three-step example below is its first test. Every number in the project passes through the engine, so every rule here gets a test. After the engine merges, changing a rule needs an entry in `docs/decisions.md`.

## Notation

- An episode has T = 21 steps. Prices are S_0, ..., S_T; holdings are h_0, ..., h_{T−1}.
- K is the strike, p the premium, and c the proportional cost rate (0.0005 is 5 basis points).
- Everything is per one unit of the underlying.

```
P&L = p + sum_{t=0}^{T-1} h_t (S_{t+1} - S_t) - sum_{t=0}^{T} c |h_t - h_{t-1}| S_t - max(S_T - K, 0)

with h_{-1} = 0 and h_T = 0.   Loss = -P&L.
```

## Rules

1. **Whose P&L is it, and what is the sign of the loss we minimize?**
   The seller's (the desk's). P&L = premium + share gains − fees − payoff, where the payoff max(S_T − K, 0) is the amount the seller owes at expiry. The loss we minimize is −P&L, because we are hedging a short option.

2. **When does a trade happen, and at which price?**
   The trade at step t happens at the close, at price S_t, after S_t is observed. The holding h_t is then held over [t, t+1) and may use only information up to t. This rules out look-ahead and matches the "one column per step" convention in `docs/apis.md`.

3. **What does the first day cost, starting from a zero holding?**
   The holding starts at zero (h_{−1} = 0), so the first trade is charged by the fee formula in rule 6: c · |h_0| · S_0.

4. **Is the final holding unwound at expiry, and is that unwind charged?**
   Yes. All shares are sold at S_T (h_T = 0) and the unwind is charged once, by the fee formula in rule 6. The option cash-settles at S_T. For real data, standard monthly SPX options settle at Friday's opening price, not a close, so the settlement value follows section 6 of `docs/data_decision.md`.

5. **Is the premium taken at the mid or the bid, and when is it received?**
   It is received in full at t = 0. In simulation, it is the Black-Scholes price at that world's volatility state at t = 0: σ in GBM, the square root of v_0 in Heston, EWMA volatility in the bootstrap and the generated volatility in diffusion. Task B uses the same convention to mark the hedge option. The premium is identical for every hedger on a given path, so it cannot change which hedger wins; it sets the absolute P&L level and the PLAT score. For real data, the default is the mid, confirmed by the data decision. A seller actually receives the bid, so the mid slightly flatters the seller; if the half-spread turns out to be material, we report results at the bid as well.

6. **What exactly is a cost charged on?**
   The notional traded: fee_t = c · |h_t − h_{t−1}| · S_t for t = 0, ..., T, with h_{−1} = 0 and h_T = 0. This one formula covers the first purchase (rule 3) and the unwind (rule 4). Total fees are the sum over t.

7. **Does cash earn interest?**
   No. r = 0, as in the PRD, so cash earns nothing, and borrowing costs nothing.

8. **Are fractional holdings allowed?**
   Yes, because the network's output is continuous. The engine accepts any real holding and never clips. The 0 to 1.2 bound belongs to the agent, and the evaluator checks it separately, so baselines and tests can pass whatever holdings they need.

9. **What changes for Task B: the futures leg at every close, marks for the hedge option, and two cost tiers?**
   Task B isn't built now, but nothing in Task A's design may block it. The engine takes prices, holdings and cost rates per instrument; Task A passes one instrument, the underlying. Task B adds two more:
   - a futures leg, whose holding is set by the delta rule at each close, charged at 1 to 2 basis points;
   - the hedge option, marked daily by the world's pricing rule (rule 5), charged at 25 to 50 basis points.

   The timing, the fee formula and the unwind rule apply to every instrument unchanged. P&L becomes the premium, plus trading gains summed over instruments, minus fees summed over instruments, minus the payoff of the book.

## The three-step example

One path with three rebalancing steps, worked out by hand to the cent. The holdings are fixed by hand rather than computed from delta, so this test checks the accounting only. The numbers become the first test in `tests/evaluation/test_engine.py`.

**Setup.** Prices 100, 102, 99, 103. Holdings h_0, h_1, h_2 = 0.5, 0.6, 0.4. Short call, K = 100. Premium 2.30. Cost rate c = 0.001.

**Share gains**

| Step | Calculation | Gain |
|---|---|---|
| 0 to 1 | 0.5 × (102 − 100) | 1.00 |
| 1 to 2 | 0.6 × (99 − 102) | −1.80 |
| 2 to 3 | 0.4 × (103 − 99) | 1.60 |
| **Total** | | **0.80** |

**Fees** (rule 6)

| Trade | Calculation | Fee |
|---|---|---|
| Initial purchase, t = 0 | 0.001 × 0.5 × 100 | 0.0500 |
| Rebalance, t = 1 | 0.001 × 0.1 × 102 | 0.0102 |
| Rebalance, t = 2 | 0.001 × 0.2 × 99 | 0.0198 |
| Unwind, t = 3 | 0.001 × 0.4 × 103 | 0.0412 |
| **Total** | | **0.1212** |

**Payoff owed.** max(S_3 − K, 0) = max(103 − 100, 0) = 3.00

**Final P&L**

```
P&L = premium + share gains - fees   - payoff
    = 2.30    + 0.80        - 0.1212 - 3.00
    = -0.0212
```

### Clarifications

1. Everything is per one unit of the underlying. A listed equity option covers 100 shares, but we never use a contract multiplier, so none appears in the code.
2. Fees are charged on the notional traded, including the initial purchase and the final unwind. The rate here is 0.001, which is 0.1 percent or 10 basis points.
3. The payoff is a positive amount the seller pays at expiry, so it is subtracted. The seller receives the premium at the start.

## Tests

All in `tests/evaluation/test_engine.py`.

- No hedge: with every holding zero, fees are zero and P&L equals the premium minus the payoff, exactly.
- The three-step example above: fees 0.1212 and P&L −0.0212, to the cent.
- Doubling the cost rate exactly doubles total fees.
- Raising the cost rate never raises the average P&L.
- Gradients flow from the P&L back to the holdings, and are finite and not zero.
- The convergence check runs in CI on every merge, starting the day the engine merges (target November 29).
