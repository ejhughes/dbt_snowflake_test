
-- sum the amount of successful payments

-- my solution

-- select sum(payment_amount) 
-- from {{ ref('stg_stripe__payments') }}
-- where payment_status = 'success'

-- suggested solution

with payments as(

    select * from {{ ref('stg_stripe__payments') }}

),

aggregated as (
    select sum(payment_amount) as total_revenue
    from payments
    where payment_status = 'success'
)

select * from aggregated
