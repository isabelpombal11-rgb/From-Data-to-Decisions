-- ROW_NUMBER vs RANK vs DENSE_RANK: what happens with ties?
-- Question: which are the 10 most expensive products in the catalogue?
-- Several products share the same list price, so the three functions differ.
SELECT product_name,
       category,
       list_price,
       ROW_NUMBER() OVER (ORDER BY list_price DESC) AS row_number,  -- always 1,2,3,4: breaks ties arbitrarily
       RANK()       OVER (ORDER BY list_price DESC) AS rank,        -- ties share a number, then it skips: 1,2,2,4
       DENSE_RANK() OVER (ORDER BY list_price DESC) AS dense_rank   -- ties share a number, no gap:      1,2,2,3
FROM products
ORDER BY list_price DESC
LIMIT 12;
