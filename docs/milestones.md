# Milestones and Timeline

**Author:** Ethan Bobrik, Project Manager, Western AI Club
**Date:** November 5, 2026
**Version:** Schedule for a team of three, version 2.3
**Status:** Matches section 12 of the PRD. If the two ever disagree, the PRD is correct.

---

The plan assumes three developers plus me, with the first team meeting on November 5 and CUCAI in early March. Reading week was October 10 to 18, so November has no break. Fall classes end December 9 and exams run December 14 to 18, which is why the December milestone is on the 12th. Winter classes start January 4, and winter reading week, February 13 to 21, is working time in this version.

## Schedule

| Dates | Phase | Work (owner) | Done when |
|---|---|---|---|
| Oct 6 to 17 | Preparation | Hiring; feasibility spike and its numbers recorded; repo, CI, interface drafts and onboarding material; reading Whalley-Wilmott and the 2026 band paper (Ethan) | Spike documented |
| Nov 5 to 12 | Phase 0: onboarding | Kickoff meeting (Nov 5); options and hedging workshop at the kickoff, diffusion workshop at the second meeting; environment setup; first task, a hand-built delta hedge (everyone); option data decision (Ethan) | **Nov 12:** every developer has a cost-error curve; owners confirmed; data source chosen |
| Nov 9 to Dec 5 | Phase 1: engine and agent | P&L engine and the convergence check in CI (Ethan, Dev 3); GBM and data pipeline (Dev 1); agent (Dev 3); diffusion prototype (Dev 2). Weekly checks: convergence (Nov 14), ES loss test (Nov 21), delta recovered at zero cost (Nov 28), delta beaten under costs (Dec 5). Interfaces freeze Nov 24 | **Dec 5:** validation passes. Nothing experimental counts before this |
| Dec 6 to 12 | Phase 2a: simulators | Heston calibrated and bootstrap built (Dev 1); gate tests and memorization audit merged (Dev 1, Dev 2); tuned diffusion model and gate dry run (Dev 2) | **Dec 12:** classical simulators pass their checks; gate tests tested; diffusion dry run logged |
| Dec 13 to Jan 3 | Exams and break | Checkpointed training runs only | |
| Jan 4 to Feb 6 | Phases 2b and 3: main experiment | Gate assembled (Dev 1) and first full diffusion gate attempt (Dev 2) by Jan 9; diffusion retries (Dev 2); the GAN in a two-week timebox from Jan 11 (Dev 1); admission for both decided by Jan 23; joint spot-volatility generation (Dev 2); agents trained in every admitted simulator, five seeds, classical simulators from Jan 4 (Dev 3); Task A grid and real-data replay (Ethan); theory Experiment 1 (Ethan) | **Jan 9:** gate report for the diffusion model. **Feb 6:** Task A table with confidence intervals; both abstracts drafted; scaling slopes measured |
| Feb 8 to 20 | Phase 4: desk task, theory and demo | Task B in Heston, bootstrap and diffusion (Dev 3, with Dev 1 and Dev 2); PPO ablation, one week (Dev 3); PLAT scores and P&L explain (Ethan); theory Experiment 2 (Ethan); demo (Ethan, Dev 1). Reading week Feb 13 to 21 is working time | **Feb 20:** demo runs end to end; tables final |
| Feb 22 to early Mar | Wrap-up | Paper and poster drafts (Feb 27); polish, rehearsals, CUCAI | Presented |

## If something slips

Each of these has a decision date, so a problem gets a decision instead of turning into a February argument. The details are in section 13 of the PRD.

- **Option data below 90 percent coverage.** Switch to SPY, then start-of-episode quotes, then model-implied premiums. Decide by November 12.
- **Validation missed on December 5.** Work through the diagnosis order in the PRD, starting with the convergence check. Fallback is a parametric band policy. Decide by December 12.
- **The diffusion model fails the admission gate.** Two one-week retries. Fallback is to run the remaining simulators and report the gate results. Decide by January 23.
- **The GAN won't train or fails the gate.** One retry with a gradient penalty inside its timebox, then it is dropped. Decide by January 23.
- **Joint spot-volatility generation fails.** Condition on EWMA volatility instead; if that fails too, run Task B in Heston and the bootstrap only. Decide by February 13.
- **Any milestone runs more than a week late.** Apply the cut order below from the top. There is no buffer left in this version, so this applies to the next slip.
- **Band extraction is unstable.** Report the scaling for the threshold baseline's band and compare the agents qualitatively. Decide by February 6.
- **The results look null on February 6.** Run the sensitivity checks in the PRD. Both versions of the abstract will already be drafted.

## Scope

The full plan is in scope: five simulators, both tasks (Task B in Heston, the bootstrap and diffusion), the PPO ablation, the PLAT score, the P&L explain and both theory experiments. Nothing is cut in advance, and nothing was cut to absorb the later start.

If a milestone slips by more than a week, cut in this order:

1. The GAN.
2. The PPO ablation.
3. Theory Experiment 2 limited to GBM against diffusion.
4. Task B reduced to Heston and diffusion.
5. Task B dropped (ES 97.5, the PLAT score and the threshold baseline stay).
6. P&L explain.
7. The out-of-the-money put in Task A.
8. The third cost level.
9. Train-test grid limited to the real-data columns.
10. Down to the three MVP simulators (GBM, bootstrap, diffusion).

Never cut: the P&L engine tests, the firewall, the Task A real-data replay, the demo and theory Experiment 1.

## How the full plan fits three people and a later start

The plan was originally sized for four or five developers. Instead of cutting it, I've sequenced the work so that each person always has one main thing and nobody waits on anyone. Dev 2 starts the diffusion model in November, because it doesn't need the P&L engine and it's the part most likely to need a second retry. Dev 1 finishes the classical simulators before exams, assembles the gate in the first week of January, and then builds the GAN. Dev 3's January is mostly training runs waiting on compute, which leaves room for the PPO ablation in February. My August prototype is already a working engine and baseline set, so the team's engine has something to be checked against from day one.

The first meeting on November 5 put the fall one week behind. December 12 can't move, so the two pieces that would have landed in exam week, the assembled gate and the first full diffusion gate attempt, move to January 4 to 9. January then runs one week later, and February absorbs the week by using reading week as working time. Task B, the PPO ablation and the PLAT and explain work still come after the main table exists, so if they run late they can't delay it. If we fall more than a week behind again, the cut order above decides what goes, starting with the GAN.
