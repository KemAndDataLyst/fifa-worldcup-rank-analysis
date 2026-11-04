# Does a High FIFA Rank Predict a Deep World Cup Run? (1994-2018)

## Question

Do top-ranked teams reliably reach the World Cup quarterfinals (the top 8), and does the likelihood change with how high a team is ranked going in?

## Data

- **FIFA rankings:** "FIFA Soccer Rankings" (International Men's Ranking, August 1993 - June 2018) by Tadhg Fitzgerald, via Kaggle. [Link](https://www.kaggle.com/datasets/tadhgfitzgerald/fifa-international-soccer-mens-ranking-1993now/data) · License: CC0: Public Domain
- **Match results:** "International football results from 1872" by martj42, via Kaggle. [Link](https://www.kaggle.com/datasets/martj42/international-football-results-from-1872-to-2017) · License: CC0: Public Domain

The rankings end in June 2018, so the analysis covers the seven World Cups from 1994 to 2018. The raw CSV files are not included in this repo; download them from the links above.

Tables used: `fifa_ranking`, `results`, `shootouts`.

## Method

All queries are in MySQL 8.0 (window functions are required) and are built as a chain of CTEs.

1. **Number the matches.** For each World Cup, `ROW_NUMBER()` counts matches backwards from the final (1 = final, 2 = third-place match, 3-4 = semifinals, 5-8 = quarterfinals).
2. **Find the winner of each match.** Draws are resolved with a `LEFT JOIN` to the shootouts table.
3. **Find each team's furthest round.** Home and away teams are stacked with `UNION ALL`, then `MIN(rn)` per team per year gives the deepest match they reached. Only the final eight matches are kept.
4. **Pick the pre-tournament ranking.** For each World Cup, the latest ranking date before the first match. This keeps results out of the ranking.
5. **Start from the rankings, not the results.** The top-ranked teams are `LEFT JOIN`ed to the finishes, so a team that missed the top 8 shows up as `NULL` and still counts in the total.
6. **Bucket and count.** A `CASE` on rank groups teams, and the share that reached the top 8 is calculated for each group.

Team names were mapped between the tables (`United States` to `USA`, `South Korea` to `Korea Republic`).

## Findings

| Rank before the tournament | Team-tournaments | Reached top 8 | Share |
|---|---|---|---|
| 1-5 | 36 | 17 | 47% |
| 6-10 | 34 | 12 | 35% |
| 11-20 | 70 | 15 | 21% |

For comparison, 56 of the 216 teams across the seven tournaments reached the top 8, about 26%.

Higher-ranked teams reached the quarterfinals more often, and the share drops steadily with rank. But even teams in the top 5 made the top 8 less than half the time, so a high rank is not a guarantee. A team ranked 11-20 did slightly worse than the average team in the field.

## Caveats

- The sample is small (about 35-70 team-tournaments per group), so a few upsets would shift the percentages noticeably.
- 1994 had 24 teams instead of 32.
- 2006 had a tie at rank 5, so the top-5 group has 36 team-tournaments instead of 35.
- Ranked teams that did not qualify for the World Cup count as missing the top 8.
- "Reached the top 8" does not separate a group-stage exit from a round-of-16 exit.

## Files

- `create_tables.sql`: table definitions for `fifa_ranking`, `results` and `shootouts`
- `analysis.sql`: the full query that produces the results table above
