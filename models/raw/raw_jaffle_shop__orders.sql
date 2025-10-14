{{ config(
    materialized="table"

) }}

-- select *
-- from raw_orders;

-- insert into raw_jaffle_shop__orders 
--     values 
--         (100, 100, '2025-02-15', 'shipped', current_timestamp),
--         (101, 84, '2025-02-15', 'shipped', current_timestamp),
--         (102, 42, '2025-02-15', 'shipped', current_timestamp),
--         (103, 101, '2025-02-15', 'shipped', current_timestamp),
--         (104, 66, '2025-02-15', 'shipped', current_timestamp);

select *
from raw_jaffle_shop__orders