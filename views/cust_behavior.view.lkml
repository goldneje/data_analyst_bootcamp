view: cust_behavior {
  derived_table: {
    explore_source: order_items {
      column: id { field: users.id }
      column: name { field: users.name }
      column: gender { field: users.gender }
      column: traffic_source { field: users.traffic_source }
      column: total_gross_revenue {}
      column: count_order_id {}
      column: first_order_date {}
      column: last_order_date {}
      column: sign_up_orig { field: users.created_date }
    }
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
  }

  dimension: sign_up_orig {
    hidden: yes
  }

  dimension_group: sign_up {
    type: time
    timeframes: [
      raw,
      date,
      month
    ]
    sql: ${sign_up_orig} ;;
  }

  dimension: days_since_signup {
    type: duration_day
    sql_start: ${sign_up_raw} ;;
    sql_end: getdate() ;;
  }

  dimension: months_since_signup {
    type: duration_month
    sql_start: ${sign_up_raw} ;;
    sql_end: getdate() ;;
  }

  dimension: avg_number_days_since_signup {
    label: "Average Number of Days Since Signup"
    type: number
    sql: (select round(avg(${days_since_signup})) from ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: avg_number_months_since_signup {
    label: "Average Number of Months Since Signup"
    type: number
    sql: (select round(avg(${months_since_signup})) from ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: day_signup_cohorts {
    type: tier
    style: integer
    tiers: [10,20,30,50,100,500]
    sql: ${days_since_signup} ;;
  }

  dimension: month_signup_cohorts {
    type: tier
    style: integer
    tiers: [1,3,6,9,12,24]
    sql: ${months_since_signup} ;;
  }

  dimension: count_order_id {
    description: "Number of orders per customer"
    type:  number
  }

  dimension: cust_lifetime_orders {
    label: "Customer Lifetime Orders"
    type: tier
    style: integer
    tiers: [1,2,3,6,10]
    sql: ${count_order_id} ;;
  }

  dimension: total_gross_revenue {
    hidden: yes
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    value_format: "$#,##0.00"
    type: number
  }

  dimension: cust_lifetime_rev {
    label: "Customer Lifetime Revenue"
    type: tier
    style: integer
    tiers: [0,5,20,50,100,500,1000]
    sql: ${total_gross_revenue} ;;
    value_format_name: usd
  }

  dimension: first_order_date {
    type: date
  }

  dimension: last_order_date {
    type: date
  }

  dimension: days_since_last_order {
    description: "The number of days since a customer placed his or her most recent order on the website"
    type: duration_day
    sql_start: ${last_order_date} ;;
    sql_end: getdate() ;;
  }

  dimension: is_active {
    description: "Identifies whether a customer is active or not (has purchased from the website within the last 90 days)"
    type: yesno
    sql: ${days_since_last_order} <= 90 ;;
  }

  dimension: is_repeat_customer {
    description: "Identifies whether a customer was a repeat customer or not"
    type: yesno
    sql: ${count_order_id} > 1 ;;
  }

  dimension: total_lifetime_orders {
    description: "The total number of orders placed over the course of customers’ lifetimes."
    type: number
    sql: (SELECT sum(${count_order_id}) FROM ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: average_lifetime_orders {
    description: "The average number of orders that a customer places over the course of their lifetime as a customer."
    type: number
    sql:(select round(avg(${count_order_id})) from ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: total_lifetime_revenue {
    description: "The total amount of revenue brought in over the course of customers’ lifetimes."
    type: number
    sql: (select sum(${total_gross_revenue}) from ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: average_lifetime_revenue {
    description: "The average amount of revenue that a customer brings in over the course of their lifetime as a customer."
    type: number
    sql: (select avg(${total_gross_revenue}) from ${cust_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: average_days_since_last_order {
    description: "The average number of days since customers have placed their most recent orders on the website"
    type: number
    sql: (select round(avg(${days_since_last_order})) from ${cust_behavior.SQL_TABLE_NAME});;
  }

  measure: total_gross_revenue_measure {
    label: "Total Gross Revenue"
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql: ${total_gross_revenue} ;;
    value_format_name: usd
  }

  measure: average_gross_revenue_measure {
    label: "Average Gross Revenue"
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    type: average
    sql: ${total_gross_revenue} ;;
    value_format_name: usd
  }

  measure: count_still_active {
    type: count
    filters: [is_active: "Yes"]
  }

  measure: pct_still_active {
    label: "Percent of Active Customers"
    type: number
    sql: ${count_still_active} / NULLIF(count(${id}), 0) ;;
    value_format_name: percent_1
  }

  measure: count_is_repeat_customer {
    type: count
    filters: [is_repeat_customer: "Yes"]
  }

  measure: pct_repeat_customer {
    type: number
    sql: ${count_is_repeat_customer}/NULLIF(count(${id}), 0);;
    value_format_name: percent_1
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

# view: cust_behavior {
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
