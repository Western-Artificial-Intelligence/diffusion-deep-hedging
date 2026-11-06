#!/usr/bin/env bash
# Creates the project's GitHub milestones and labels. Run once, after the repository exists on
# GitHub, from inside the repo:  bash scripts/setup_github.sh
# Needs the GitHub CLI (https://cli.github.com/), logged in with `gh auth login`.
# Running it twice makes GitHub reject the duplicates, which is harmless.
set -uo pipefail

repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Setting up milestones and labels for $repo"

milestone() {  # title, due date (YYYY-MM-DD), description
  gh api "repos/$repo/milestones" --silent \
    -f title="$1" -f due_on="$2T12:00:00Z" -f description="$3" \
    && echo "  milestone: $1 ($2)" || echo "  skipped milestone: $1"
}

milestone "Task 1"                    2026-11-12 "Every developer has a cost-error curve; owners confirmed; data source chosen"
milestone "Engine convergence check"  2026-11-14 "P&L engine merged with the convergence check running in CI"
milestone "Task 2"                    2026-11-19 "One admission-gate test each, with pytest tests"
milestone "ES loss test"              2026-11-21 "Both ES implementations pass the known-answer test"
milestone "Interface freeze"          2026-11-24 "docs/apis.md tagged v1.0"
milestone "Delta recovered"           2026-11-28 "Zero-cost GBM agent within 0.05 of Black-Scholes delta"
milestone "Validation"                2026-12-05 "Agent beats delta under costs; nothing experimental counts before this"
milestone "Simulators"                2026-12-12 "GBM, Heston and bootstrap pass their checks; gate tests tested; diffusion dry run logged"
milestone "Gate report"               2027-01-09 "Gate assembled; first full diffusion gate attempt logged"
milestone "Admission decisions"       2027-01-23 "GAN and diffusion admitted or dropped"
milestone "Task A table"              2027-02-06 "Task A table with confidence intervals; both abstracts; scaling slopes"
milestone "Joint generation decision" 2027-02-13 "Joint spot-volatility generation in or out of Task B"
milestone "Demo and final tables"     2027-02-20 "Demo runs end to end; tables final"
milestone "Paper and poster drafts"   2027-02-27 "Drafts ready for review"

label() {  # name, colour, description
  gh label create "$1" --color "$2" --description "$3" >/dev/null 2>&1 \
    && echo "  label: $1" || echo "  skipped label: $1"
}

label task        "2E6E65" "A unit of work with an owner and a due date"
label engine      "C8553D" "P&L engine"
label simulator   "4E8A57" "GBM, Heston, bootstrap, GAN"
label generator   "6B5B95" "Diffusion model and joint generation"
label agent       "D9A23A" "Policy, training, PPO"
label evaluation  "1F2D2B" "Metrics, grid, replay, PLAT, explain"
label gate        "667A74" "Admission gate and memorization audit"
label data        "8FA9A1" "Data pipeline and quality checks"
label theory      "A3322A" "Band extraction and scaling"
label docs        "EEF2F0" "Documentation"
label blocked     "000000" "Waiting on someone or something"
