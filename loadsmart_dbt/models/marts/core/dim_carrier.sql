with base as (

    select distinct
        carrier_name,
        vip_carrier
    from {{ ref('stg_loads') }}
    where carrier_name is not null

),

final as (

    select
        md5(carrier_name) as carrier_id,
        carrier_name,
        vip_carrier
    from base

)

select * from final

