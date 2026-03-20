-- ============================================================
-- STAGING: World Bank Indicators
-- Source: african_economics_raw.world_bank_indicators
-- Deduplicates, casts types, filters nulls
-- ============================================================

with source as (

    select * from {{ source('world_bank_raw', 'world_bank_indicators') }}

),

deduplicated as (

    -- If the pipeline ran twice, ingestion_id will be duplicated
    -- We keep only the most recently ingested version of each row
    select *,
        row_number() over (
            partition by ingestion_id
            order by ingested_at desc
        ) as row_num

    from source

),

cleaned as (

    select
        ingestion_id,
        cast(country_iso      as string)  as country_iso,
        cast(country_name     as string)  as country_name,
        cast(indicator_code   as string)  as indicator_code,
        cast(indicator_name   as string)  as indicator_name,
        cast(year             as int64)   as year,
        cast(value            as float64) as value,
        cast(ingested_at      as timestamp) as ingested_at,
        pipeline_version

    from deduplicated
    where row_num = 1                  -- keep only latest duplicate
      and country_iso is not null      -- drop regional aggregates

)

select * from cleaned