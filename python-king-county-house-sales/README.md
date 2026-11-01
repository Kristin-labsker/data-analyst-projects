# What drives home prices in King County?

**Tools:** Python · pandas · matplotlib · seaborn · Jupyter
**Data:** 4,600 home sales in King County, Washington (USA), May 2 – July 10, 2014, 18 columns
**Notebook:** [`Washington_House_Sales.ipynb`](Washington_House_Sales.ipynb)

## Research question
Which physical and location features are most strongly related to home prices in King County?

## What I did
1. **Data overview:** checked data types, missing values and duplicates.
2. **Cleaning, with every decision explained:**
   - removed 49 sales with a price of $0 and 2 large homes listed with 0 bedrooms and 0 bathrooms
   - fixed rows where build year and renovation year were swapped, instead of deleting them
   - checked 171 homes whose living area is larger than the lot (all valid multi-floor homes)
   - excluded a few extreme values that would distort averages
   - in total, 55 of 4,600 rows removed (1.2%), leaving 4,545 sales
3. **Exploration:** distributions, cities, home age, weekly trends.
4. **What drives price:** correlation heatmap, Seattle vs. the rest of the county, size vs. price in the 10 most expensive cities.

## Key findings
- **Size is the strongest factor.** Living area has the highest correlation with price (**0.70**), followed by above-ground area (0.59) and bathrooms (0.52).
- **Location adds a premium on top of size.** Seattle has **34%** of all sales but ranks only 18th of 44 cities on median price. Medina's median price ($2.1M) is about **4.3×** Seattle's ($490K).
- **Size works the same everywhere.** Living area relates to price almost equally in Seattle (0.75) and in the other cities (0.73).
- **Waterfront and view** are linked to higher prices, but very few homes have them.
- **Condition, year built and lot size** show almost no linear relationship with price.
- **Busy weeks had lower prices** (r = −0.75 with the weekly median, 9 full weeks), most likely because more lower-priced homes sold in those weeks.

The notebook ends with practical recommendations for buyers, sellers and agents.

## How to run
Place `house_sales.csv` in the same folder as the notebook and run all cells.
