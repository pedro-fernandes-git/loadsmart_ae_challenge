with base as (

    select distinct
        shipper_name
    from {{ ref('stg_loads') }}
    where shipper_name is not null

),

final as (

    select
        md5(shipper_name) as shipper_id,
        shipper_name
    from base

)

select * from final

