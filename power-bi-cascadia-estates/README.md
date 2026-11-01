# Cascadia Estates: King County housing market report

**Tools:** Power BI Desktop · Power Query · DAX
**Data:** about 4,600 home sales in King County, Washington, May–July 2014
**Audience:** the owner of Cascadia Estates, a real-estate brokerage
**File:** [`Cascadia_Estates.pbix`](Cascadia_Estates.pbix) (download and open in Power BI Desktop)

## Business question
Where, when and what kind of homes sell in King County, and which deals fall outside the normal price range?

## Report pages
1. **About the Project:** topic and research questions
2. **Market Overview:** KPIs, homes by region with Region → City drill-down, weekly sales trend with a 4-week forecast, price bands
3. **Location & Price:** city scatter on a log scale against the county median, top 10 cities
4. **Property Drivers:** waterfront, view and renovation premiums, size bands and bedrooms
5. **Time & Activity:** weekday × week sales-calendar heatmap, busiest weekdays, daily sales pace by month
6. **Price Landscape:** price distribution with bookmark tabs for all homes, standard deals and outliers
7. **Process Notes:** data, cleaning, model, analysis and key conclusions

## Technical highlights
- **Data model:** star schema with a `Sales` fact table and `Dim_Date` and `Dim_Location` dimensions; Location and Date hierarchies
- **DAX:** IQR outlier rule (Q3 + 1.5 × IQR), `TOPN` rankings, an SVG heatmap measure, and a linear-trend forecast built from two measures
- **Interactivity:** cross-filtering between visuals, a region slicer, bookmark tabs, drill-down, and a custom tooltip page
- **Design:** a custom theme with a consistent palette, logo strip and page navigator on every page

## Design decisions
- Visuals cross-filter each other instead of filling each page with slicers.
- July is a partial month, so months are compared by average sales per selling day.
- Partial first and last weeks are excluded from the weekly chart.
- Medians are used for city prices, with a minimum number of sales per city, so a few luxury deals do not distort the picture.
