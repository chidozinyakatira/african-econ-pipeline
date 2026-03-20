{{ config(materialized='table') }}

with indicators as (

    select * from {{ ref('stg_world_bank_indicators') }}

),

countries as (

    select * from {{ ref('dim_countries') }}

),

joined as (

    select
        i.country_iso,
        c.country_name,
        c.region,
        i.indicator_name,
        i.year,
        i.value

    from indicators i
    left join countries c
        on i.country_iso = c.country_iso

),

gdp as (

    select
        country_iso,
        year,
        value as gdp_usd,
        lag(value) over (
            partition by country_iso
            order by year
        ) as gdp_prev_year

    from joined
    where indicator_name = 'gdp_current_usd'

)

select
    j.country_iso,
    j.country_name,
    j.region,
    j.year,
    g.gdp_usd,
    round(
        safe_divide(g.gdp_usd - g.gdp_prev_year, g.gdp_prev_year) * 100,
        2
    ) as gdp_yoy_growth_pct,
    j.indicator_name,
    j.value

from joined j
left join gdp g
    on j.country_iso = g.country_iso
    and j.year = g.year

order by j.country_iso, j.year