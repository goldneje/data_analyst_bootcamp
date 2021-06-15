view: order_facts {
  derived_table: {
    sql: select order_id
      , sum(sale_price) as order_cost
      , count(*) as items_in_order
      from public.order_items
      group by order_id
       ;;
  }

#  measure: count {
#    type: count
#    drill_fields: [detail*]
#  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: order_cost {
    type: number
    sql: ${TABLE}."ORDER_COST" ;;
    hidden: yes
  }

  dimension: items_in_order {
    type: number
    sql: ${TABLE}."ITEMS_IN_ORDER" ;;
  }

  measure: avg_order_cost {
    type: average
    sql: ${order_cost} ;;
    value_format_name: usd
  }

  measure: avg_items_in_order{
    type: average
    sql: ${items_in_order} ;;
    value_format_name: decimal_1
  }

  set: detail {
    fields: [order_id, order_cost, items_in_order]
  }
}
