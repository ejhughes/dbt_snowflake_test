
 {{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
 }}

-- Import CTEs

with

customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),


paid_orders as (

    select * from {{ ref('int_orders') }}
),


---

-- Final CTE

final as (
    
    select
        order_id,
        paid_orders.customer_id,
        order_placed_at,
        order_status,
        total_amount_paid,
        payment_finalized_date,
        customer_first_name,
        customer_last_name,

        -- sales transaction sequence
        row_number() over (
            order by order_id
        ) as transaction_seq,

        -- customer sales sequence
        row_number() over (
            partition by paid_orders.customer_id 
            order by order_id
        ) as customer_sales_seq,

        -- new vs returning customer
        case
            when (
                rank() over(
                    partition by paid_orders.customer_id
                    order by order_placed_at, order_id
                    ) = 1
                ) 
            then 'new'
            else 'return'
        end as nvsr,

        -- customer lifetime value
        sum(total_amount_paid) over(
            partition by paid_orders.customer_id
            order by order_placed_at
        ) as customer_lifetime_value,

        -- first order date
        first_value(order_placed_at) over(
            partition by paid_orders.customer_id
            order by order_placed_at
        ) as fdos

    from paid_orders

    left join customers on paid_orders.customer_id = customers.customer_id

    order by order_id
)

-- Single Select Statement

select * from final
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    -- {{ this }} is a way of referencing the current model you are working in, i.e.: it's a shortcut for __ref fct_customer_orders which alos prevents issues from circular dependecies
    where order_placed_at > date('2025-01-01')--(select max(order_placed_at) from {{ this }} -- this would be the dynamic code used if the data were being updated) 
{% endif %}
