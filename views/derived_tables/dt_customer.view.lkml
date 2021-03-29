
view: dt_customer {
  derived_table: {
    explore_source: order_items {
      column: total_revenue {}
      column: user_id { field: users.id }
     column: product_count { field: products.count }
    column: order_count {field: order_items.count}
      # column: created_date { field: inventory_items.created_date }
      column: first_order_time {}
      column: last_order_time {}
    }
  }
  dimension: total_revenue {
    value_format: "$#,##0.00"
    type: number
}
measure: new_revenue {
  type: sum
  sql: ${total_revenue} ;;
}

  dimension: user_id {
    type: number
    primary_key: yes
  }
  measure: user_id_count {
    type:  count
  }
  dimension: first_order_time {
    type: date
  }
  dimension: last_order_time {
    type: date
  }
#Part 1 Case Study
  dimension: customer_order_tier {
    type:  tier
    tiers:  [1,2,3,6,10]
    style:  integer
    sql: ${product_count} ;;
  }
  dimension: customer_revenue_tier {
    type:  tier
    tiers:  [1, 5, 20, 50, 100, 500, 1000]
    style:  integer
    sql: ${total_revenue} ;;
  }

   dimension: order_count {
     type: number
   }
  dimension: product_count {
    type: number
  }
  measure: order_count_num {
    type: number
    sql: ${order_count} ;;
  }
  measure: product_count_num {
    type: number
    sql: ${product_count} ;;
  }
  # dimension: created_date {
  #   type: date
  # }
  # measure: count_revenue_tiers {
  #   type:  count
  # # sql:  ${customer_revenue_tier} ;;
  # }
   measure: average_revenue {
     type: average
    value_format: "$#,##0.00"

     sql:  ${total_revenue} ;;
   }
  dimension: days_from_last_order {
    type:  duration_day
    sql_start: last_order_time;;
    sql_end: GETDATE();;
  }
  dimension: days_from_first_order {
    type:  duration_day
    sql_start: first_order_time;;
    sql_end: GETDATE();;
  }
  dimension: 90_day_purchasers {
    description: "Made an order within last 90 days"
    type:  yesno
    sql: ${days_from_last_order} < 90 ;;
  }
  dimension: 60_day_purchasers {
    description: "Made an order within last 60 days"
    type:  yesno
    sql: ${days_from_last_order} < 60 ;;
  }

  dimension: firstlast_order_day_diff {
    type:  duration_day
    sql_start: first_order_time;;
    sql_end: last_order_time;;
  }

  measure: average_since_last_order {
    type: average
    sql:  ${days_from_last_order} ;;
  }

  dimension: is_first_purchase {
    description: "Finding First time buyers"
    type: yesno
    sql: ${order_count} = 1  ;;
  }
  dimension: repeat_customer {
    description: "Customers who have purchased more than once"
    type: yesno
    sql: ${order_count} > 1  ;;
  }
  dimension: sign_up_tier {
    type:  tier
    tiers:  [1, 180, 360, 540, 720, 900]
    style:  integer
    sql: ${days_from_first_order} ;;
  }


#Skipped repeat customers for now



}
