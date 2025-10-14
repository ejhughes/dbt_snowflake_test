{{
    config(
        materialized='table',
    )
}}

-- select *
-- from demo_db.raw_jaffle_shop.customers;

-- insert into raw_jaffle_shop__customers 
--     values 
--         (101, 'Michelle', 'B.'),
--         (102, 'Faith', 'L.');

select *
from raw_jaffle_shop__customers