{#
    This macro returns last year given a date
#}

{% macro get_last_year_date(datestring) -%}
    date_add({{ datestring}} , INTERVAL -52 WEEK)
{%- endmacro %}