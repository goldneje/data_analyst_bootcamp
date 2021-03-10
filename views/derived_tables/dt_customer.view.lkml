
view: dt_customer {
  derived_table: {
    explore_source: order_items {
      column: total_revenue {}
      column: user_id { field: events.user_id }
      column: count { field: products.count }
      column: created_date { field: inventory_items.created_date }
    }
  }
  dimension: total_revenue {
    value_format: "$#,##0.00"
    type: number

  }
  dimension: user_id {
    type: number
  }
  dimension: customer_revenue_tier {
    type:  tier
    tiers:  [1, 5, 20, 50, 100, 500, 1000]
    style:  integer
    sql: ${total_revenue} ;;
  }
  dimension: count {
    type: number
  }
  dimension: created_date {
    type: date
  }
  measure: count_revenue_tiers {
    type:  count
   # sql:  ${customer_revenue_tier} ;;
  }
  # measure: average_revenue {
  #   type: number
  #   sql:  ${total_revenue} / ${count} ;;
  # }

  measure: order_first_time{
    type: date
    sql:  min(${created_date}) ;;
  }
  measure: order_last_time{
    type: date
    sql:  max(${created_date}) ;;
  }
 # measure: days_from_last_order {
 #   type:  number
 ##   sql: DATEDIFF(day, ${now}, ${order_last_time} ;;
 # }
 ## measure: 90_day_purchasers {
 #   description: "Made an order within last 90 days"
 #   type:  yesno
 #   sql: ${days_from_last_order} < 90 ;;
 # }
  measure: firstlast_order_day_diff {
    type: number
    sql: DATEDIFF( day, ${order_first_time}, ${order_last_time}) ;;
  }
  measure: current_date {
    type:  date
    sql:  Now() ;;
  }
  }
  # dimension: is_first_purchase {
  #  description: "First time buyer"
  #  type; yesno
  #  sql:  ${} ;;
  # }
#
