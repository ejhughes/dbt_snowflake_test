{{
    config(
        materialized='table'
    )
}}

-- select *
-- from demo_db.raw_stripe.payment;

-- insert into raw_stripe__payments --(id, orderid, paymentmethod, status, amount, created, _batched_at)
--     values 
--         (121, 100, 'bank_transfer', 'success', 1000, '2025-02-14', current_timestamp),
--         (122, 101, 'credit_card', 'fail', 400, '2025-02-14', current_timestamp),
--         (123, 102, 'credit_card', 'success', 1900, '2025-02-14', current_timestamp),
--         (124, 103, 'credit_card', 'success', 1000,  '2025-02-15', current_timestamp),
--         (125, 104, 'coupon', 'success', 100, '2025-02-15', current_timestamp);

select *
from raw_stripe__payments