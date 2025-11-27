with time_bounds as (

    select
        -- menor data entre todos os timestamps relevantes
        min(
            least(
                quote_time,
                book_time,
                source_time,
                pickup_time,
                delivery_time,
                pickup_appointment_time,
                delivery_appointment_time
            )
        )::date as min_date,

        -- maior data entre todos os timestamps relevantes
        max(
            greatest(
                quote_time,
                book_time,
                source_time,
                pickup_time,
                delivery_time,
                pickup_appointment_time,
                delivery_appointment_time
            )
        )::date as max_date

    from {{ ref('stg_loads') }}

),

dates as (

    select
        generate_series(
            (select min_date from time_bounds),
            (select max_date from time_bounds),
            interval '1 day'
        )::date as date_day

),

final as (

    select
        date_day,

        -- componentes básicos
        extract(year  from date_day)::int as year,
        extract(month from date_day)::int as month,
        extract(day   from date_day)::int as day,

        extract(week    from date_day)::int as week_of_year,
        extract(quarter from date_day)::int as quarter,

        extract(isodow from date_day)::int as day_of_week_iso, -- 1=Mon .. 7=Sun
        to_char(date_day, 'Dy')      as day_name_short,
        to_char(date_day, 'FMDay')   as day_name,

        to_char(date_day, 'Mon')     as month_name_short,
        to_char(date_day, 'FMMonth') as month_name,

        case when extract(isodow from date_day) in (6, 7) then true else false end as is_weekend
    from dates
)

select * from final

