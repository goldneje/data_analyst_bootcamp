# If necessary, uncomment the line below to include explore_source.
# include: "data_analyst_bootcamp.model.lkml"

view: order_sequence_2 {
  derived_table: {
    explore_source: order_sequence_1 {
      column: created_date {}
      column: order_id {}
      column: order_sequence {}
      column: user_id {}
      column: has_subsequent_purchase {}
      column: is_first_purchase {}
      column: previous_order_date {}
      column: subsequent_order_date {}
    }
  }
  dimension: created_date {
    label: "Order Date"
    type: date
  }

  dimension: order_id {
    primary_key: yes
    hidden: yes
    type: number
  }

  dimension: order_sequence {
    description: "Sequence number showing the order that a customer's purchases took place. Requires user_id and created_date fields"
    type: number
  }

  dimension: user_id {
    hidden: yes
    type: number
  }

  dimension: has_subsequent_purchase {
    label: "Has Subsequent Purchase (Yes / No)"
    type: number
  }

  dimension: is_first_purchase {
    label: "Is First Purchase (Yes / No)"
    type: number
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
    sql_end: ${created_date} ;;
  }

  dimension: is_repeat_purchase_flag {
    type: number
    sql: CASE
            WHEN ${days_between_orders} <= 60
            THEN 1
            ELSE 0
            END ;;
  }

  measure: average_days_between_orders {
    type: average
    sql: ${days_between_orders} ;;
  }

  measure: has_repeat_purchases {
    hidden: yes
    type: yesno
    sql: SUM(${is_repeat_purchase_flag}) > 0 ;;
  }

  # Mainly for debugging
  # measure: number_of_orders{
  #   type: count
  # }
}
