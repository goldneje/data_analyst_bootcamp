view: order_sequence_two {
  derived_table: {
    explore_source: order_sequence {
      column: created_date {}
      column: order_id {}
      column: order_sequence {}
      column: user_id {}
      column: has_subsequent_order {}
      column: is_first_purchase {}
      column: previous_order_date {}
      column: subsequent_order_date {}
    }
  }

  dimension: created_date {
    type: date
  }

  dimension: order_id {
    primary_key: yes
    type: number
  }

  dimension: order_sequence {
    type: number
  }

  dimension: user_id {
    type: number
  }

  dimension: has_subsequent_order {
    label: "Has Subsequent Purchase (Yes / No)"
    type: number
  }

  dimension: has_subsequent_order_new {
    type: yesno
    sql: ${has_subsequent_order} = TRUE ;;
  }

  dimension: is_first_purchase {
    label: "Is First Purchase (Yes / No)"
    type: number
  }

  dimension: is_first_purchase_new {
    type: yesno
    sql: ${is_first_purchase} = TRUE ;;
  }

  dimension: previous_order_date {
    type: date
  }

  dimension: subsequent_order_date {
    type: date
  }

  dimension: days_between_orders {
    type: duration_day
    sql_start: ${previous_order_date} ;;
    sql_end: ${created_date};;
  }

  dimension: is_60_day {
    type: yesno
    sql: ${days_between_orders} < 60 ;;
  }

  measure: avgerage_days_between_orders {
    type: average
    sql: ${days_between_orders} ;;
  }

  measure: number_60_day {
    type: count
    filters: [is_60_day: "Yes"]
  }

  measure: count_users {
    type: count
  }

  measure: 60_day_repeat_purchase_rate {
    type: number
    sql: ${number_60_day}/${count_users} ;;
    value_format_name: percent_1
  }


  measure: count_subsequent_order {
    type: count
    filters: [has_subsequent_order_new: "Yes"]
  }

  measure: count_no_subsequent_order {
    type: count
    filters: [has_subsequent_order_new: "No"]
  }

  measure: subsequent_rate {
    type: number
    sql: ${count_subsequent_order}/(${count_subsequent_order} + ${count_no_subsequent_order}) ;;
  }

  measure: count_is_first_purchase {
    type: count
    filters: [is_first_purchase_new: "Yes"]
  }

  measure: pct_first_purchase {
    type: number
    sql: ${count_is_first_purchase}/${count_users} ;;
    value_format_name: percent_1
  }

  #measure: rev_from_new_customers {
  #  type: sum
  #  sql: ${order_items.sale_price} ;;
  #  filters: [is_first_purchase_new: "Yes"]
  #}
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: order_sequence_two {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
