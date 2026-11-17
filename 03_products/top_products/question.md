# Case 05 — What Sells Where
*Top products in each category*

## The business question
> "The homepage has room for 3 products per category. Which ones should we show, and how much do our best sellers really matter?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| E-commerce / Merchandising | Which products deserve the best spots on the homepage and in emails? |
| Purchasing / Inventory | Which products must never run out of stock? |
| Category managers | How dependent is my category on one or two products? |
| Finance | Where does the money actually come from? |

## Why "best seller" needs a definition
"Best seller" can mean the product sold most often or the one that brought in the most money. A €12 lip balm can sell more units than a €65 perfume and still earn far less. The two rankings answer different questions, so the team has to agree which one decides the homepage before anyone writes a query.

## Data used
- `orders` — one row per order, with `amount` and `product_id` (one product per order in this dataset)
- `products` — `product_name`, `category` and `list_price`
- `users` — `country`, for the follow-up question by market

## Definitions (agree on these before writing SQL)
- **Revenue per product:** sum of order amounts for that product in 2025.
- **Rank in category:** position by revenue within the product's own category (1 = highest).
- **Top 3 share:** revenue of the top 3 products ÷ total revenue of their category.
- **Ties:** when two products have the same value, decide whether they share a rank (`RANK`, `DENSE_RANK`) or get different numbers (`ROW_NUMBER`).
