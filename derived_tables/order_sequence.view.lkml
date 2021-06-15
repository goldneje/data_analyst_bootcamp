view: order_sequence {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: created_date {}
      column: order_sequence {}
      column: order_id {}
    }
  }

  dimension: user_id {
    type: number
  }

  dimension: order_id {
    primary_key: yes
    type: number
  }

  dimension: created_date {
    type: date
  }

  dimension: order_sequence {
    type: number
  }

  measure: previous_order_date {
    type: date
    sql: CASE
          WHEN LAG(${user_id}, 1) OVER(ORDER BY ${user_id}, ${order_sequence}) = ${user_id}
            THEN LAG(${created_date}, 1) OVER(ORDER BY ${user_id}, ${order_sequence})
          ELSE NULL
          END;;
  }

  measure: subsequent_order_date {
    type: date
    sql: CASE
          WHEN LEAD(${user_id}, 1) OVER(ORDER BY ${user_id}, ${order_sequence}) = ${user_id}
            THEN LEAD(${created_date}, 1) OVER(ORDER BY ${user_id}, ${order_sequence})
          ELSE NULL
          END ;;
  }

  measure: is_first_purchase {
    type: yesno
    sql: ${previous_order_date} IS NULL;;
  }

  measure: has_subsequent_order {
    type: yesno
    sql: ${subsequent_order_date} IS NOT NULL ;;
  }




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

# view: order_sequence {
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
