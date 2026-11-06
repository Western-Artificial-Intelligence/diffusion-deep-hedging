# data/

Local only. Git ignores everything in this folder except this README.

Data is rebuilt from scratch by the fetch scripts in `src/dhedge/marketdata/` (Dev 1, week 2). Each file gets an entry in a manifest recording its source, the date it was pulled and a checksum, so everyone can confirm they have the same data.

Option data may come with a licence that limits who can use it. Where it lives and who can access it is in `docs/data_decision.md`. Never commit it, and never put it in a public place.
