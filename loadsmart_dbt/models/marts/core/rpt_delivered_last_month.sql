{{
    config(
        materialized='view'
    )
}}


with max_delivery as (
    select max(delivery_date)::date as max_delivery_date
    from {{ ref('fact_loads') }}
),

month_bounds as (
    select 
        date_trunc('month', max_delivery_date) as month_start,
        (date_trunc('month', max_delivery_date) + interval '1 month') as month_end
    from max_delivery
)

select
    f.loadsmart_id,
    s.shipper_name,
    f.delivery_date,
    f.pickup_city,
    f.pickup_state,
    f.delivery_city,
    f.delivery_state,
    f.book_price,
    c.carrier_name
from {{ ref('fact_loads') }} f
left join {{ ref('dim_shipper') }} s on f.shipper_id = s.shipper_id
left join {{ ref('dim_carrier') }} c on f.carrier_id = c.carrier_id
cross join month_bounds mb
where f.delivery_date >= mb.month_start
  and f.delivery_date < mb.month_end
order by f.delivery_date desc, f.loadsmart_id

