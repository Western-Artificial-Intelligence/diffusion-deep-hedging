# Results table shells

The tables the paper needs, fixed before any run so results can't change what we report. Each cell is Expected Shortfall at 97.5 percent with a block-bootstrap confidence interval, over five seeds.

## Task A: trained in (rows), tested in (columns)

| Trained in | GBM | Heston | Bootstrap | GAN | Diffusion | Real, 2017 to 2026 | Real, crises |
|---|---|---|---|---|---|---|---|
| GBM | | | | | | | |
| Heston | | | | | | | |
| Bootstrap | | | | | | | |
| GAN | | | | | | | |
| Diffusion | | | | | | | |
| Black-Scholes delta | | | | | | | |
| Threshold delta | | | | | | | |
| Leland | | | | | | | |
| No hedge | | | | | | | |

One table per contract (at-the-money call, 10-delta put) and per cost level.

## Task B: trained in (rows), tested in (columns)

| Trained in | Heston | Bootstrap | Diffusion | GBM (control) |
|---|---|---|---|---|
| Heston | | | | |
| Bootstrap | | | | |
| Diffusion | | | | |
| Delta-only desk | | | | |
| Gamma-neutral rule | | | | |
| Vega-neutral rule | | | | |
