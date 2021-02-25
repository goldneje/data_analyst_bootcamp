view: order_sequence {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: created_date {}
      column: order_id {}
      column: order_sequence {}
    }
  }

  dimension: user_id {
    type: number
  }

  dimension: created_date {
    type: date
  }

  dimension: order_id {
    type: number
  }

  dimension: order_sequence {
    description: "Sequence number showing the order that a customer's purchases took place. Requires user_id and created_date fields"
    type: number
  }

  measure: previous_order_date {
    type: date
    sql: CASE
          WHEN LAG(${user_id}, 1) OVER(ORDER BY ${user_id}, ${order_sequence}) = ${user_id}
            THEN LAG(${created_date}, 1) OVER(ORDER BY ${order_id}, ${order_sequence})
          ELSE NULL
          END ;;
  }

  measure: subsequent_order_date {
    type: date
    sql: CASE
          WHEN LEAD(${user_id}, 1) OVER(ORDER BY ${user_id}, ${order_sequence}) = ${user_id}
            THEN LEAD(${created_date}, 1) OVER(ORDER BY ${order_id}, ${order_sequence})
          ELSE NULL
          END ;;
  }

  measure: has_subsequent_purchase {
    type: yesno
    sql: ${subsequent_order_date} IS NOT NULL ;;
  }

  measure: is_first_purchase {
    type: yesno
    sql: ${previous_order_date} IS NULL ;;
  }
}
