# If necessary, uncomment the line below to include explore_source.
# include: "data_analyst_bootcamp.model.lkml"

view: customer_behavior {
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
      column: sign_up_date { field: users.created_date }
    }
  }
  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
  }

  dimension: name {}

  dimension: gender {}

  dimension: traffic_source {}

  dimension: sign_up_date {}

  # These "since signup" dimensions need to be in a derived table because they use an aggregation in their calculation
  # To get the average, I need to derive the sign-up date, but this might be a good use case for adding this dimension
  # to the DWH
  dimension: days_since_signup {
    type: duration_day
    sql_start: ${sign_up_date} ;;
    sql_end: GETDATE() ;;
  }

  dimension: days_since_signup_cohorts {
    type: tier
    tiers: [10, 20, 30, 50, 100, 500]
    sql: ${days_since_signup} ;;
  }

  dimension: months_since_signup {
    type: duration_month
    sql_start: ${sign_up_date} ;;
    sql_end: GETDATE() ;;
  }

  dimension: months_since_signup_cohorts {
    type: tier
    tiers: [1, 3, 6, 9, 12, 24]
  }

  dimension: total_gross_revenue {
    hidden: yes
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    value_format: "$#,##0.00"
    type: number
  }

  dimension: count_order_id {
    label: "Number of Orders"
    type: number
  }

  dimension: first_order_date {
    type: date
  }

  dimension: last_order_date {
    type: date
  }

  dimension: customer_lifetime_orders_tier {
    description: "Breakdown of customer lifetime orders into buckets"
    type: tier
    style: integer
    tiers: [1, 2, 3, 6, 10]
    sql: ${count_order_id} ;;
  }

  dimension: customer_lifetime_revenue_tier {
    description: "Breakdown of customer lifetime revenue into buckets"
    type: tier
    style: integer
    tiers: [0, 5, 20, 50, 100, 500, 1000]
    sql: ${total_gross_revenue} ;;
  }

  dimension: days_since_latest_order {
    type: duration_day
    sql_start: ${last_order_date} ;;
    sql_end: GETDATE() ;;
  }

  dimension: total_lifetime_orders {
    description: "The total number of orders placed across all customers"
    type: number
    sql: (SELECT SUM(${count_order_id}) FROM ${customer_behavior.SQL_TABLE_NAME}) ;;
  }

  dimension: average_lifetime_orders {
    description: "The average number of orders placed by customer over the course of all customers' lifetimes"
    type: number
    sql: (SELECT ROUND(AVG(${count_order_id})) FROM ${customer_behavior.SQL_TABLE_NAME});;
  }

  dimension: total_lifetime_revenue {
    description: "Total revenue across all customers and all time"
    type: number
    sql: (SELECT SUM(${total_gross_revenue}) FROM ${customer_behavior.SQL_TABLE_NAME}) ;;
    value_format_name: usd
  }

  dimension: average_lifetime_revenue {
    description: "Average revenue per customer across all customers and all time"
    type: number
    sql: (SELECT AVG(${total_gross_revenue}) FROM ${customer_behavior.SQL_TABLE_NAME}) ;;
    value_format_name: usd
  }

  measure: total_gross_revenue_measure {
    label: "Total Gross Revenue"
    description: "Total Revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql: ${total_gross_revenue} ;;
    value_format_name: usd
  }

  dimension: is_active {
    description: "Flag identifying whether a customer is active or not (has purchased from the website within the last 90 days)"
    type: yesno
    sql: ${days_since_latest_order} <= 90 ;;
  }

  dimension: is_repeat_customer {
    description: "Flag identifying whether a customer has more than 1 order"
    type: yesno
    sql: ${count_order_id} > 1 ;;
  }

  measure: average_days_since_latest_order {
    type: number
    sql: (SELECT AVG(${days_since_latest_order}) FROM ${customer_behavior.SQL_TABLE_NAME}) ;;
  }

  measure: average_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
    value_format_name: decimal_1
  }

  measure: average_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
    value_format_name: decimal_1
  }
}
