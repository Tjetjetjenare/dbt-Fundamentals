WITH customers as (
    SELECT * 
    FROM {{ ref('stg_jaffle_shop__customers') }}
),

orders as (
    SELECT * 
    FROM {{ ref('stg_jaffle_shop__orders') }}
),

customer_orders as (
    SELECT
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders
    FROM orders
    GROUP BY customer_id
),

order_payments as (
    SELECT
        o.customer_id,
        sum(f.amount) as lifetime_value
    FROM {{ ref('fct_orders') }} f
    join orders o ON f.order_id = o.order_id
    GROUP BY o.customer_id
),

final as (
    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(order_payments.lifetime_value, 0) as lifetime_value
    FROM customers
    left join customer_orders USING (customer_id)
    left join order_payments USING (customer_id)
)

SELECT * FROM final