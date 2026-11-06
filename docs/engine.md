# P&L engine: accounting rules

**Status:** to be written by Ethan and Dev 3 before any engine code exists (week 2, before Task 1 is due). Every number in the project passes through the engine, so every rule here gets a test.

Answer each question below in one or two sentences, with the reason. Where the two of you disagree, work the three-step example by hand together; it then becomes the engine's first test.

## Questions

1. Whose P&L is it, and what is the sign of the loss we minimize?
   **Decision:**
2. When does a trade happen, and at which price?
   **Decision:**
3. What does the first day cost, starting from a zero holding?
   **Decision:**
4. Is the final holding unwound at expiry, and is that unwind charged?
   **Decision:**
5. Is the premium taken at the mid or the bid, and when is it received?
   **Decision:**
6. What exactly is a cost charged on?
   **Decision:**
7. Does cash earn interest?
   **Decision:**
8. Are fractional holdings allowed?
   **Decision:**
9. What changes for Task B: the futures leg at every close, marks for the hedge option, and two cost tiers?
   **Decision:**

## The three-step example

A single path with three rebalancing steps, worked out by hand to the cent. Commit the working here and the numbers in the test next to the engine.

## Tests

- No hedge: P&L equals the premium minus the payoff, exactly.
- The three-step example above, to the cent.
- Raising the cost rate never raises the average P&L.
- Gradients flow from the P&L back to the holdings, finite and not zero.
- The convergence check in CI (due November 14).
