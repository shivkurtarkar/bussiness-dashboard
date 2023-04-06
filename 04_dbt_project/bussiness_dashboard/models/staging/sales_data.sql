
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='view') }}

-- partitioning over order_id, product_id and event as these combo defines unique entry
with sales_data as (
    select *,
        row_number() over(partition by order_id, product_id, event_time) as rn
    from {{ source('staging', 'sales') }}
    where price is not null
)

select
    cast(event_time as timestamp) as event_time,
    cast(order_id as integer) as order_id,
    cast(product_id as integer) as product_id,
    category_id,
    category_code,
    brand,
    price,    
    cast(user_id as integer) as user_id
from sales_data
where rn =1

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
