-- Follow-up question: WHERE did the bigger baskets come from?
-- Share of orders in each price band, per variant.
-- If the threshold works, orders should move from just below 60 EUR
-- to just above it.
SELECT variant,
       CASE WHEN order_amount < 35 THEN '1 under 35'
            WHEN order_amount < 60 THEN '2 35-59.99'
            WHEN order_amount < 80 THEN '3 60-79.99'
            ELSE                        '4 80 and over' END          AS basket_band,
       COUNT(*)                                                      AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY variant), 1) AS pct_of_variant_orders
FROM ab_test
WHERE converted = 1
GROUP BY variant, basket_band
ORDER BY variant, basket_band;
