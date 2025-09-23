
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

completed_payments as(

    select
        orderid as order_id,
        max(created) as payment_finalized_date,
        sum(amount) / 100.0 as total_amount_paid
    from payments
    where status <> 'fail'
    group by 1

    )

-- Final CTE

-- Single Select Statement


paid_orders as (
    select
        orders.id as order_id,
        orders.user_id as customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        completed_paymentstotal_amount_paid,
        completed_paymentspayment_finalized_date,
        c.first_name as customer_first_name,
        c.last_name as customer_last_name
    from orders
    left join completed_payments
    on orders.id = completed_paymentsorder_id
    left join customers c on orders.user_id = c.id
),

customer_orders as (
    select
        c.id as customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(orders.id) as number_of_orders
    from customers c
    left join orders on orders.user_id = c.id
    group by 1
)

select
    completed payments.*,

    row_number() over (
        order by completed_paymentsorder_id
    ) as transaction_seq,

    row_number() over (
        partition by customer_id 
        order by completed_paymentsorder_id
    ) as customer_sales_seq,

    case
        when c.first_order_date = completed_paymentsorder_placed_at 
        then 'new' 
        else 'return'
    end as nvsr,

    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
from paid_orders p

left join customer_orders as c using (customer_id)
left outer join(
    select 
        completed_paymentsorder_id, 
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2
        on completed_paymentscustomer_id = t2.customer_id
        and completed_paymentsorder_id >= t2.order_id
    group by 1
    order by completed_paymentsorder_id
    ) x
    on x.order_id = completed_paymentsorder_id
order by order_id
