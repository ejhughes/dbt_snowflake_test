{{
    config(
        materialized='view'
    )
}}

select *
from {{ ref('fct_customer_orders') }}