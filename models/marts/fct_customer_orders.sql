
-- Import CTEs

with

customers as (

    select * from {{ source('jaffle_shop', 'customers') }}

),

orders as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

payments as (

    select * from {{ source('stripe', 'payments') }}

),

-- Logical CTEs

completed_payments. as(

    select
        orderid as order_id,
        max(created) as payment_finalized_date,
        sum(amount) / 100.0 as total_amount_paid
    from payments
    where status <> 'fail'
    group by 1

    )

---


paid_orders as (
    select
        orders.id as order_id,
        orders.user_id as customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        completed_payments.total_amount_paid,
        completed_payments.payment_finalized_date,
        customers.first_name as customer_first_name,
        customers.last_name as customer_last_name
    from orders
    left join completed_payments.
    on orders.id = completed_payments.order_id
    left join customers on orders.user_id = customers.id
),

customer_orders as (
    select
        customers.id as customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(orders.id) as number_of_orders
    from customers
    left join orders on orders.user_id = customers.id
    group by 1
),

---

-- Final CTE

final as(
    
    select
        completed payments.*,

        -- sales transaction sequence
        row_number() over (
            order by completed_payments.order_id
        ) as transaction_seq,

        -- customer sales sequence
        row_number() over (
            partition by customer_id 
            order by completed_payments.order_id
        ) as customer_sales_seq,

        -- new vs returning customer
        case
            when customers.first_order_date = completed_payments.order_placed_at 
            then 'new' 
            else 'return'
        end as nvsr,

        -- customer lifetime value
        sum(total_amount_paid) over(
            partition by paid_orders.customer_id
            order by paid_orders.order_placed_at
        ) as customer_lifetime_value

        -- first order date
        customers.first_order_date as fdos

    from paid_orders

    left join customer_orders as on paid_orders.customer_id = customer_orders.customer_id

    order by order_id
)

-- Single Select Statement

select * from final


