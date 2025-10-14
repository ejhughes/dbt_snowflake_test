with

source as (

    select * from {{ source('stripe', 'raw_stripe__payments') }}

),

transformed as (

    select
        id as payment_id,
        orderid as order_id,
        created as payment_created_at,
        status as payment_status,
        paymentmethod,
        --round(amount/100.0, 2) as payment_amount
        {{ cents_to_dollars("amount") }} as payment_amount


    from source

)


select * from transformed