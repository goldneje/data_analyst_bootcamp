# If necessary, uncomment the line below to include explore_source.
# include: "data_analyst_bootcamp.model.lkml"

view: order_sequence_3 {
  derived_table: {
    explore_source: order_sequence_2 {
      column: user_id {}
      column: has_repeat_purchases {}
    }
  }
  dimension: user_id {
    type: number
  }
  dimension: has_repeat_purchases {
    label: "Order Sequence 2 Has Repeat Purchases (Yes / No)"
    type: number
  }
}
