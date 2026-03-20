{{ config(materialized='table') }}

with countries as (

    select distinct
        country_iso,
        country_name
    from {{ ref('stg_world_bank_indicators') }}
    where country_iso is not null

)

select
    country_iso,
    country_name
from countries