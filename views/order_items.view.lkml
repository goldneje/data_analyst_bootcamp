view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

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
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: is_current_day {
    type: yesno
    sql: ${created_day_of_month} <= EXTRACT('day', GETDATE()) ;;
  }

  dimension: is_current_month {
    type: yesno
    sql: ${created_month_num} = EXTRACT('month', GETDATE()) ;;
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
    hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: is_completed_sale {
    description: "Flag for referencing completed sales, a completed sale is any sale that is not returned or cancelled"
    type: yesno
    sql: ${status} IN ('Complete', 'Processing', 'Shipped');; # SQL needed single quotes for this conditional
  }

  measure: count {
    label: "Number of Items Sold"
    type: count
    drill_fields: [detail*]
  }

  measure: count_order_id {
    label: "Number of Orders"
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: total_sale_price {
    description: "Total sales from items sold"
    group_label: "Sales Calculations"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    description: "Average sale price of items sold"
    group_label: "Sales Calculations"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    description: "Cumulative total sales from items sold (also known as a running total)"
    group_label: "Sales Calculations"
    type: running_total
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    group_label: "Sales Calculations"
    type: sum
    sql: ${sale_price} ;;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
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

  measure: total_gross_margin_amount {
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold"
    group_label: "Sales Calculations"
    type: sum
    sql: ${sale_price} - ${inventory_items.cost_hidden} ;;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
    drill_fields: [products.category, products.brand, total_gross_margin_amount]
  }

  measure: average_gross_margin_amount {
    description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
    group_label: "Sales Calculations"
    type: average
    sql: ${sale_price} - ${inventory_items.cost_hidden};;
    filters: [is_completed_sale: "Yes"]
    value_format_name: usd
  }

  measure: gross_margin_pct {
    label: "Gross Margin %"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    group_label: "Sales Calculations"
    type: number
    sql: ${total_gross_margin_amount} / NULLIF(${total_gross_revenue}, 0) ;;
    value_format_name: percent_2
  }

  measure: count_returned_items {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: count
    filters: [status: "Returned"]
    drill_fields: [detail*]
  }

  measure: item_return_rate {
    description: "Number of items returned over total number of items sold"
    type: number
    sql: ${count_returned_items} / ${count} ;;
    value_format_name: percent_2
  }

  measure: count_users_return {
    label: "Number of Customers Returning Items"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: count_users {
    label: "Number of Customers"
    type: count_distinct
    sql: ${user_id} ;;
    }

  measure: user_return_pct {
    label: "Customers with Returns %"
    description: "Number of Customers Returning Items / Total number of customers"
    type: number
    sql: ${count_users_return} / ${count_users} ;;
    value_format_name: percent_2
  }

  measure: average_spend_per_user {
    label: "Average Spend per Customer"
    description: "Total Sale Price / Total Number of Customers"
    type: number
    sql: ${total_sale_price} / ${count_users} ;;
    value_format_name: usd
  }

  measure: first_order_date {
    type: date
    sql: min(${created_date}) ;;
  }

  measure: last_order_date {
    type: date
    sql: max(${created_date}) ;;
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
}
