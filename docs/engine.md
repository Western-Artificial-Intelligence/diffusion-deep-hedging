# P&L engine: accounting rules

**Status:** to be written by Ethan and Dev 3 before any engine code exists (week 2, before Task 1 is due). Every number in the project passes through the engine, so every rule here gets a test.

Answer each question below in one or two sentences, with the reason. Where the two of you disagree, work the three-step example by hand together; it then becomes the engine's first test.

## Questions

1. Whose P&L is it, and what is the sign of the loss we minimize?
   The seller's (the desk's). P&L = premium + share gains − costs − payoff, and the loss we minimize is −P&L.
2. When does a trade happen, and at which price?
   The trade at time t happens at the close S_t, and the holding h_t is held over [t, t+1). h_t may use only information up to t. Rules out look-ahead and matches the "one column per step" convention.
3. What does the first day cost, starting from a zero holding?
   The holding starts at 0, so day 0 is charged on c|h_0 − 0| · S_0.
4. Is the final holding unwound at expiry, and is that unwind charged?
   The option cash-settles at S_T. The last holding h_{T−1} is sold at S_T and charged once.
5. Is the premium taken at the mid or the bid, and when is it received?
   Received at t=0. In simulation it is the Black-Scholes price at the world's volatility. For real data, mid vs bid is a question for Ethan, because it depends on his data-source decision. ( I would assume its mid to avoid bid-ask spread within the hedging error)
6. What exactly is a cost charged on?
   Rate × |Δholding| × price at the trade, i.e. the notional traded.
7. Does cash earn interest?
   None (r = 0), consistent with the PRD.
8. Are fractional holdings allowed?
   Allowed, since the network output is continuous
9. What changes for Task B: the futures leg at every close, marks for the hedge option, and two cost tiers?
    Don't build it now, build Task A in a way that doesn't prevent Task B from being added later.

## The three-step example

A single path with three rebalancing steps, worked out by hand to the cent. Commit the working here and the numbers in the test next to the engine.

Setup:
   Prices: 100, 102, 99, 103.
   Holdings h₀, h₁, h₂ = 0.5, 0.6, 0.4.
   Short call, K = 100.
   Premium 2.30.
   Fee 0.001.

share gains:
   0.5(102-100) = 1.00
   06.(99-102) = -1.80
   04.(103-99) = 1.60

   total share gains = 1.00 -1.80 + 1.60 = 0.80

transaction fees:

fee = Fee_t = c|h_t - H_t-1|S_t

trade                    calcualation        fee
Intial purchase         0.001(0.5)(100)      $0.0500
Rebelance 1             0.001(0.1)(102)      $0.0102
Rebalence 2             0.001(0.2)(99)	      $0.0198
Final unwind	         0.001(0.4)(103)	   $0.0412
**Total**                                  **$0.1212**

Option payoff
   Since this is a short call, the seller owes the buyer
                  -max(S_3 - k,0)
               = -max(103-100,0) = -3.00

Final PnL

      P&L = Premium + ShareGains - Fees - Payoff
         P&L = 2.30 + 0.80 - 0.1212 - 3.00

      Net PnL. = -$0.0212


Clarifications:
1. 
example assumes that the option payoff and premium are expressed on the same one unit basis as the underlying share holdings, for a standar 100 share equity option, the payoff and premium would need to use the contract multipler. 
2. 
This assumes the fee is charged on the absolute notional value traded, including the initial purchase and final unwind. It also assumes the fee rate is 0.1%
3. 
The payoff is negative because we're calculating the seller's P&L. The seller receives the premium initially but must pay the option payoff at expiry

## Tests

- No hedge: P&L equals the premium minus the payoff, exactly.
- The three-step example above, to the cent.
- Raising the cost rate never raises the average P&L.
- Gradients flow from the P&L back to the holdings, finite and not zero.
- The convergence check in CI (due November 14).
