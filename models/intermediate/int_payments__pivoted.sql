with

payments as(

select * from {{ ref('stg_stripe__payments') }}

)

select 

    payment_id,

    {%- set payment_method -%}
        SELECT DISTINCT paymentmethod
        FROM {{ ref('stg_stripe__payments') }}
    {%- endset -%}

    {%- set rows = run_query(payment_method) -%}

    {%- if execute -%}
    {%- set column_headers = rows.columns[0].values() -%}
    {%- else -%}
    {%- set column_headers = [] -%}
    {%- endif -%}

    {% for header in column_headers %}

    sum(case when paymentmethod = '{{ header }}' then payment_amount ELSE 0 END) as {{ header }}_amount

        {%- if not loop.last -%}
            ,
        {%- endif -%}

    {% endfor %}

from payments
GROUP BY 1