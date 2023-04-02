
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}

{% set current_date = var("current_date")  %}


with sales_data as (
    select * from {{ ref('sales_data') }}
    where brand != 'unknown'
),



total_sales_data as (
    select
        brand,
        sum(price) as total_sale
    from sales_data
    group by brand
),


total_sales_data_4w as (
    select 
        brand,
        sum(price) as sale_last_4_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
        '{{ var("current_date")}}'
        , INTERVAL -4 WEEK)    
    group by brand    
),

total_sales_data_12w as (
    select 
        brand,
        sum(price) as sale_last_12_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(        
        '{{ var("current_date")}}'
        , INTERVAL -12 WEEK)
    group by brand
),
total_sales_data_24w as (
    select 
        brand,
        sum(price) as sale_last_24_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
        '{{ var("current_date")}}'
        , INTERVAL -24 WEEK)
    group by brand
),
total_sales_data_52w as (
    select 
        brand,
        sum(price) as sale_last_52_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
        '{{ var("current_date")}}'
        , INTERVAL -52 WEEK)
    group by brand
),



total_sales_data_y_ago as (
    select
        brand,
        sum(price) as total_sale
    from sales_data
    where 
        CAST(event_time AS DATE) <
        {{  get_last_year_date('current_date') }}
    group by brand
),

total_sales_data_4w_y_ago as (
    select 
        brand,
        sum(price) as sale_last_4_weeks
    from sales_data as sales_change
    where 
        CAST(event_time AS DATE) >= date_add(
            {{  get_last_year_date("current_date") }}
            , INTERVAL -4 WEEK)
        and CAST(event_time AS DATE) <
        {{  get_last_year_date('current_date') }}
    group by brand    
),

total_sales_data_12w_y_ago as (
    select 
        brand,
        sum(price) as sale_last_12_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
            {{  get_last_year_date("current_date") }}
            , INTERVAL -12 WEEK)
        and CAST(event_time AS DATE) <
        {{  get_last_year_date('current_date') }}
    group by brand
),
total_sales_data_24w_y_ago as (
    select 
        brand,
        sum(price) as sale_last_24_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
            {{  get_last_year_date("current_date") }}
            , INTERVAL -24 WEEK)
        and CAST(event_time AS DATE) <
        {{  get_last_year_date('current_date') }}
    group by brand
),
total_sales_data_52w_y_ago as (
    select 
        brand,
        sum(price) as sale_last_52_weeks
    from sales_data as sales_change
    where CAST(event_time AS DATE) >= date_add(
            {{  get_last_year_date("current_date") }}
            , INTERVAL -52 WEEK)
        and CAST(event_time AS DATE) <
        {{  get_last_year_date('current_date') }}
    group by brand
)

select 
    total_sales_data.brand,
    total_sales_data.total_sale,
    IFNULL(total_sales_data_4w.sale_last_4_weeks, 0) as sale_last_4_weeks_cy,
    IFNULL(total_sales_data_12w.sale_last_12_weeks, 0) as sale_last_12_weeks_cy,
    IFNULL(total_sales_data_24w.sale_last_24_weeks, 0) as sale_last_24_weeks_cy,
    IFNULL(total_sales_data_52w.sale_last_52_weeks, 0) as sale_last_52_weeks_cy,
    IFNULL(total_sales_data_y_ago.total_sale, 0) as total_sale_y_ago,
    IFNULL(total_sales_data_4w_y_ago.sale_last_4_weeks, 0) as sale_last_4_weeks_y_ago,
    IFNULL(total_sales_data_12w_y_ago.sale_last_12_weeks, 0) as sale_last_12_weeks_y_ago,
    IFNULL(total_sales_data_24w_y_ago.sale_last_24_weeks, 0) as sale_last_24_weeks_y_ago,
    IFNULL(total_sales_data_52w_y_ago.sale_last_52_weeks, 0) as sale_last_52_week_y_agos,
    (100*IFNULL(total_sales_data_4w.sale_last_4_weeks, 0)/(IFNULL(total_sales_data_4w_y_ago.sale_last_4_weeks, 0.0000000001))-1) as sale_last_4_weeks_chg,
    (100*IFNULL(total_sales_data_12w.sale_last_12_weeks, 0)/(IFNULL(total_sales_data_12w_y_ago.sale_last_12_weeks, 0.0000000001))-1) as sale_last_12_weeks_chg,
    (100*IFNULL(total_sales_data_24w.sale_last_24_weeks, 0)/(IFNULL(total_sales_data_24w_y_ago.sale_last_24_weeks, 0.0000000001))-1) as sale_last_24_weeks_chg,
    (100*IFNULL(total_sales_data_52w.sale_last_52_weeks, 0)/(IFNULL(total_sales_data_52w_y_ago.sale_last_52_weeks, 0.0000000001))-1) as sale_last_52_week_chg
from total_sales_data 
left join total_sales_data_4w
on total_sales_data.brand = total_sales_data_4w.brand
left join total_sales_data_12w
on total_sales_data.brand = total_sales_data_12w.brand
left join total_sales_data_24w
on total_sales_data.brand = total_sales_data_24w.brand
left join total_sales_data_52w
on total_sales_data.brand = total_sales_data_52w.brand
left join total_sales_data_y_ago
on total_sales_data.brand = total_sales_data_y_ago.brand
left join total_sales_data_4w_y_ago
on total_sales_data.brand = total_sales_data_4w_y_ago.brand
left join total_sales_data_12w_y_ago
on total_sales_data.brand = total_sales_data_12w_y_ago.brand
left join total_sales_data_24w_y_ago
on total_sales_data.brand = total_sales_data_24w_y_ago.brand
left join total_sales_data_52w_y_ago
on total_sales_data.brand = total_sales_data_52w_y_ago.brand

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
