with src as (

    select *
    from {{ source('loadsmart', 'cleaned_loads') }}

),

deduped as (

    select *
    from (
        select
            *,
            row_number() over (
                partition by loadsmart_id
                order by coalesce(source_date, book_date, quote_date) desc
            ) as rn
        from src
        where loadsmart_id is not null
    ) s
    where rn = 1

),

renamed as (

    select
        -- identifiers
        loadsmart_id,

        -- raw categoricals
        shipper_name,
        carrier_name,
        equipment_type,
        sourcing_channel,

        -- location fields (already split in Python)
        lane,
        pickup_city,
        pickup_state,
        delivery_city,
        delivery_state,

        -- timestamps
        quote_date as quote_time,
        book_date as book_time,
        source_date as source_time,
        pickup_date as pickup_time,
        delivery_date as delivery_time,
        pickup_appointment_time,
        delivery_appointment_time,

        -- metrics
        book_price,
        source_price,
        pnl,
        mileage,
        carrier_rating,
        carrier_dropped_us_count,

        -- booleans
        vip_carrier,
        carrier_on_time_to_pickup,
        carrier_on_time_to_delivery,
        carrier_on_time_overall,
        has_mobile_app_tracking,
        has_macropoint_tracking,
        has_edi_tracking,
        contracted_load,
        load_booked_autonomously,
        load_sourced_autonomously,
        load_was_cancelled

    from deduped
)

select * from renamed
