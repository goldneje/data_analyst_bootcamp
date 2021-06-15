view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  parameter: time_frames {
    type: unquoted
    allowed_value: {
      label: "Date"
      value: "date"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
    allowed_value: {
      label: "Month"
      value: "month"
    }
  }

  dimension: time_frame_selected {
    type: string
    sql: {% if time_frames._paramter == 'date' %} ${created_date}
    {% elsif time_frames._paramter_value == 'week' %} ${created_week}
    {% else %} ${created_month}
    {% endif %};;
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    group_label: "IDs"
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_num,
      day_of_month,
      day_of_year,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: is_before_current_day_in_year {
    hidden: yes
    type: yesno
    sql: ${created_day_of_year} <= EXTRACT('day', GETDATE()) ;;
  }

  dimension: is_current_month {
    hidden: yes
    type: yesno
    sql: ${created_month_num} = EXTRACT('month', GETDATE()) ;;
  }

  dimension: is_current_year {
    hidden: yes
    type: yesno
    sql: ${created_year} = EXTRACT('year', GETDATE()) ;;
  }

  dimension: is_previous_year {
    hidden: yes
    type: yesno
    sql: ${created_year} = EXTRACT('year', GETDATE()) - 1 ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    group_label: "IDs"
    hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: product_id {
    type:  number
    group_label: "IDs"
    hidden: yes
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: order_id {
    type: number
    group_label: "IDs"
    sql: ${TABLE}."ORDER_ID" ;;
  }


  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
    value_format_name: usd
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: shipping_days {
    type: number
    sql: DATEDIFF(day, ${shipped_raw}, ${delivered_raw}) ;;
  }

  dimension_group: from_ship_to_deliver {
    type:  duration
    intervals: [hour, day, week]
    sql_start: ${shipped_raw} ;;
    sql_end: ${delivered_raw} ;;
  }

  dimension_group: fulfillment {
    description: "How long an order took to be shipped."
    type: duration
    intervals: [
      day,
      hour,
      week,
    ]
    sql_start: ${created_raw} ;;
    sql_end: ${shipped_raw} ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    group_label: "IDs"
    hidden: no
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: is_prev_month {
    type: yesno
    hidden: no
    sql: ${created_month_num} = month(getdate()) - 1;;
  }

  measure: order_sequence {
    description: "Sequence number showing the order that a customer's purchases took place. Requires user_id and created_date fields"
    type: number
    sql: ROW_NUMBER() OVER(PARTITION BY ${user_id} ORDER BY ${created_date}) ;;
  }

  dimension: is_completed_sale {
    description: "Flag for referencing completed sales, a completed sale is any sale that is not returned or cancelled"
    type: yesno
    sql: ${status} IN ('Complete', 'Processing', 'Shipped');; # SQL needed single quotes for this conditional
  }

  measure: total_sale_price {
    description: "Titak sakes from items sold"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    description: "Average sale price of items sold"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    description: "Cumulative tital sales from items sold"
    type: running_total
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    description: "Total revenue from completed sales"
    type: sum
    sql: ${sale_price} ;;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
  }

  measure: total_gross_margin_amount {
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold"
    type: sum
    sql: ${sale_price} - ${inventory_items.cost_hidden} ;;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
    drill_fields: [products.category, products.brand]
  }

  measure: average_gross_margin {
    description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
    type: average
    sql: ${sale_price} - $(inventory_items.cost_hidden) ;;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
  }

  measure: gross_margin_pct {
    label: "Gross Marign %"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    type: number
    sql: ${total_gross_margin_amount} / nullif(${total_gross_revenue},0);;
    value_format_name: percent_2
  }

  measure: count_items_returned {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: count
    filters: [status: "Returned"]
    drill_fields: [detail*]
  }

  measure: count {
    label: "Number of Items Sold"
    type: count
    drill_fields: [detail*]
  }

  measure: item_return_rate {
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: ${count_items_returned} / ${count} ;;
    value_format_name: percent_2
  }

  measure: customers_return {
    label: "Number of Customers Returning Items"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
    drill_fields: [detail*]
  }

  measure: count_customers {
    label: "Total number of customers"
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: pct_user_returns {
    label: "% of Users with Returns"
    description: "Number of Customer Returning Items / total number of customers"
    type: number
    sql: ${customers_return} / ${count_customers} ;;
    value_format_name: percent_2
  }

  measure: avg_spend_customer {
    label: "Average Spend per Customer"
    description: "Total Sale Price / total number of customers"
    type: number
    sql: ${total_sale_price} / ${count_customers} ;;
    value_format_name: usd
    drill_fields: [users.gender, users.age_demographic]
  }

  measure: count_order_id {
    label: "Number of Orders"
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: pct_of_total_gross_revenue {
    description: "Percent of the total gross revenue made up by a row. Calculated in a derived table"
    label: "Percent of Total Gross Revenue"
    group_label: "Sales Calculations"
    type: percent_of_total
    direction: "column"
    sql: ${total_gross_revenue} ;;
    value_format: "0.000\%"
  }

  measure: cytd_revenue {
    label: "CYTD Revenue"
    type: sum
    sql: ${sale_price} ;;
    filters: [
      is_current_year: "Yes",
      is_before_current_day_in_year: "Yes"
    ]
    value_format_name: usd
  }

  measure: lytd_revenue {
    label: "LYTD Revenue"
    type: sum
    sql: ${sale_price} ;;
    filters: [
      is_previous_year: "Yes",
      is_before_current_day_in_year: "Yes"
    ]
    value_format_name: usd
  }

  measure: yoy_growth {
    label: "Gross Revenue - Year over Year Growth"
    type: number
    sql: ${cytd_revenue} - ${lytd_revenue} ;;
    value_format_name: usd
  }

  measure: yoy_pct_growth {
    label: "Gross Revenue - Year over Year Growth (%)"
    type: number
    sql:
      CASE
        WHEN ${lytd_revenue} = 0 THEN -999 ELSE ${yoy_growth} / ${lytd_revenue} END;;
    value_format_name: percent_2
  }

  measure: first_order_date {
    type: date
    sql: min(${created_date}) ;;
  }

  measure: last_order_date {
    type: date
    sql: max(${created_date}) ;;
  }

  measure: brand_rank {
    description: "Ranks brand by % margin"
    type: number
    sql: RANK() OVER(ORDER BY ${gross_margin_pct} DESC) ;;
  }

  measure: category_revenue_rank {
    hidden: yes
    description: "Rank based on revenue by category"
    type: number
    sql: RANK() OVER(PARTITION BY ${products.category} ORDER BY ${total_gross_revenue} DESC) ;;
  }

  measure: brand_revenue_rank {
    description: "Rank based on revenue by brand"
    type: number
    sql: RANK() OVER(ORDER BY ${total_gross_revenue} DESC) ;;
  }

  measure: category_yoy_growth_rank{
    hidden: no
    description: "Rank based on Year-over-year growth per category"
    type: number
    sql: RANK() OVER(PARTITION BY ${products.category} ORDER BY ${yoy_growth} DESC) ;;
  }

  measure: brand_yoy_growth_rank {
    hidden: no
    description: "Rank based on year-over-year growth per brand"
    type: number
    sql: RANK() OVER(ORDER BY ${yoy_growth} DESC) ;;
  }

  measure: category_yoy_pct_growth_rank{
    hidden: no
    description: "Rank based on Year-over-year growth per category"
    type: number
    sql: RANK() OVER(PARTITION BY ${products.category} ORDER BY ${yoy_pct_growth} DESC) ;;
  }

  measure: brand_yoy_pct_growth_rank {
    hidden: no
    description: "Rank based on year-over-year growth per brand"
    type: number
    sql: CASE
            WHEN ${yoy_pct_growth} IS NOT NULL
            THEN RANK() OVER(ORDER BY ${yoy_pct_growth} DESC)
            ELSE -9999
            END;;
  }

  measure: category_volume_rank {
    hidden: yes
    description: "Rank based on order volume by category"
    type: number
    sql: RANK() OVER(PARTITION BY ${products.category} ORDER BY ${count} DESC) ;;
  }

  measure: brand_volume_rank {
    hidden: yes
    description: "Rank based on order volume by category"
    type: number
    sql: RANK() OVER(ORDER BY ${count} DESC) ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      inventory_items.product_name,
      inventory_items.id,
      users.last_name,
      users.id,
      users.first_name
    ]
  }

  set: user_behavior {
    fields: [
      total_sale_price
      , order_items.average_sale_price
      , order_items.count_returned_items
      , order_items.item_return_rate
      , order_items.count_users_return
    ]
  }

  set: brand_comparison_set {
    fields: [
      cytd_revenue,
      lytd_revenue,
      yoy_growth,
      yoy_pct_growth,
      is_current_year,
      is_previous_year,
      is_before_current_day_in_year,
      created_date,
      created_month,
      created_year,
      created_month_num,
      brand_yoy_growth_rank,
      brand_yoy_pct_growth_rank,
      brand_revenue_rank,
      brand_volume_rank,
      category_yoy_growth_rank,
      category_yoy_pct_growth_rank,
      category_revenue_rank,
      category_volume_rank,
      order_items.id,
      order_items.count,
      order_items.status,
      order_items.is_completed_sale,
      order_items.sale_price,
      order_items.total_gross_revenue,
      order_items.pct_of_total_gross_revenue,
    ]
  }
}
