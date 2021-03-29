view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
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
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
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
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
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
  ##BootCamp
  dimension_group: diff_shipping_days {
    type: duration
    intervals:  [hour, day, week]
    sql_start: ${shipped_raw} ;;
    sql_end:  ${delivered_raw} ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
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

    #Part 0 of Case Study
}
  measure: total_sale_price {
    type:  sum
    sql: ${sale_price};;
    value_format_name: usd
  }
  measure: average_sale_price {
    type:  average
    sql: ${sale_price};;
    value_format_name: usd
  }
  measure: total_revenue {
    type:  sum
    sql: ${sale_price};;
    value_format_name: usd
    filters: [status : "-Cancelled, -Returned"]
    }

  measure: total_gross_margin_amount {
    type:  number
    sql: ${total_revenue} - ${inventory_items.total_cost};;
    value_format_name: usd
  }
  measure: average_gross_margin_amount {
    type:  number
    sql: ${total_gross_margin_amount} / ${products.count} ;;
    value_format_name: usd
    #filters: [status : "-Cancelled, -Returned"]

  }
  measure: returned_items_count {
    type:  count
    filters: [order_items.status: "Returned"]
  }

  measure: all_item_count {
    type:  count
  }
  measure: item_return_rate {
    type:  number
    sql:  ${returned_items_count} / ${all_item_count} ;;

  }

  measure: gross_margin_percentage {
    type: number
    sql: ${total_gross_margin_amount} / ${total_revenue} ;;
    value_format_name: percent_2
  }
  measure: revenue_percent {
    type:  number
    sql: ${sale_price} / ${total_revenue};;
    drill_fields: [product.category, product.brand]

  }
  measure: sale_per_customer {
    type:  number
    sql: ${total_sale_price} / ${users.count} ;;
    value_format_name: usd
    drill_fields: [users.age_tiers, users.genders]
   # customer information, such as customer age groups and genders.
  }
  dimension: age_tier {
    type:  tier
    tiers:  [15,26,36,51,66]
    style:  integer
    sql: ${users.age} ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${distribution_centers.latitude} ;;
    sql_longitude: ${distribution_centers.longitude} ;;
  }

  measure: first_order_time{
    type: date
    sql:  min(${created_date}) ;;
  }
  measure: last_order_time{
    type: date
    sql:  max(${created_date}) ;;
  }



}
