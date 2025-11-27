with base as (

    select *
    from {{ ref('stg_loads') }}

),

joined_shipper as (
    select b.*, s.shipper_id
    from base b
    left join {{ ref('dim_shipper') }} s
        on s.shipper_name = b.shipper_name
),

joined_carrier as (
    select b.*, c.carrier_id
    from joined_shipper b
    left join {{ ref('dim_carrier') }} c
        on c.carrier_name = b.carrier_name
)

select
    -- grain
    loadsmart_id,

    -- dimension FKs
    shipper_id,
    carrier_id,

    -- date FKs (para dim_date), derivadas dos *_time
    date(quote_time)    as quote_date,
    date(book_time)     as book_date,
    date(source_time)   as source_date,
    date(pickup_time)   as pickup_date,
    date(delivery_time) as delivery_date,

    -- location attributes (denormalized for easier BI consumption)
    lane,
    pickup_city,
    pickup_state,
    delivery_city,
    delivery_state,

    -- derived location attributes
    pickup_city || ', ' || pickup_state as pickup_location,
    delivery_city || ', ' || delivery_state as delivery_location,

    case 
        when pickup_state = delivery_state then 'Intra-State'
        else 'Cross-State'
    end as load_type,

    -- descriptive attributes
    equipment_type,
    sourcing_channel,

    -- timestamps originais (full precision)
    quote_time,
    book_time,
    source_time,
    pickup_time,
    delivery_time,
    pickup_appointment_time,
    delivery_appointment_time,

    -- metrics
    book_price,
    source_price,
    pnl,
    mileage,
    carrier_rating,

    -- booleans & flags
    vip_carrier,
    carrier_dropped_us_count,
    carrier_on_time_to_pickup,
    carrier_on_time_to_delivery,
    carrier_on_time_overall,
    has_mobile_app_tracking,
    has_macropoint_tracking,
    has_edi_tracking,
    contracted_load,
    load_booked_autonomously,
    load_sourced_autonomously,
    load_was_cancelled,

    -- calculated relevant metrics for the business
    
    -- quote → book
    extract(epoch from (book_time - quote_time)) / 3600.0
        as quote_to_book_hours,
    extract(epoch from (book_time - quote_time)) / 86400.0
        as quote_to_book_days,

    -- book → source
    extract(epoch from (source_time - book_time)) / 3600.0
        as book_to_source_hours,
    extract(epoch from (source_time - book_time)) / 86400.0
        as book_to_source_days,

    -- source → pickup
    extract(epoch from (pickup_time - source_time)) / 3600.0
        as source_to_pickup_hours,
    extract(epoch from (pickup_time - source_time)) / 86400.0
        as source_to_pickup_days,

    -- pickup → delivery (transit time)
    extract(epoch from (delivery_time - pickup_time)) / 3600.0
        as pickup_to_delivery_hours,
    extract(epoch from (delivery_time - pickup_time)) / 86400.0
        as pickup_to_delivery_days,

    -- lead times maiores
    extract(epoch from (delivery_time - quote_time)) / 3600.0
        as quote_to_delivery_hours,
    extract(epoch from (delivery_time - book_time)) / 3600.0
        as book_to_delivery_hours

from joined_carrier

