connection: "snowlooker"
label: "Fashion.ly Case Study - EH"

# include all the views
include: "/views/**/*.view"
include: "/derived_tables/*.view"

datagroup: data_analyst_bootcamp_default_datagroup {
  sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: data_analyst_bootcamp_default_datagroup

# explore: distribution_centers {}

# explore: etl_jobs {}

explore: brand_comparison {
  from: order_items
  view_name: order_items
  view_label: "Sales Measures"
  fields: [
    order_items.brand_comparison_set*,
    products.brand,
    products.category,
    products.brand_category_id,
    dt_brand_category_comparison.brand_category_id,
    dt_brand_category_comparison.category_revenue_rank,
    dt_brand_category_comparison.category_volume_rank,
    dt_brand_category_comparison.category_yoy_growth_rank,
    dt_brand_category_comparison.category_yoy_pct_growth_rank,
    dt_brand_comparison.brand_revenue_rank,
    dt_brand_comparison.brand_volume_rank,
    dt_brand_comparison.brand_yoy_growth_rank,
    dt_brand_comparison.brand_yoy_pct_growth_rank,
  ]

  join: inventory_items {
    view_label: "Brand Details"
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
    fields: [inventory_items.id, inventory_items.cost_hidden]
  }

  join: products {
    view_label: "Brand Details"
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
    fields: [products.brand, products.category, products.id, products.brand_category_id]
  }

  join: dt_brand_category_comparison {
    view_label: "Brand/Category Rankings"
    sql_on: ${products.brand_category_id} = ${dt_brand_category_comparison.brand_category_id} ;;
    relationship: many_to_one
    fields: [
    dt_brand_category_comparison.brand_category_id,
    dt_brand_category_comparison.category_revenue_rank,
    dt_brand_category_comparison.category_volume_rank,
    dt_brand_category_comparison.category_yoy_growth_rank,
    dt_brand_category_comparison.category_yoy_pct_growth_rank
    ]
  }

  join: dt_brand_comparison {
    view_label: "Brand/Category Rankings"
    sql_on: ${products.brand} = ${dt_brand_comparison.brand} ;;
    relationship: many_to_one
    fields: [
    dt_brand_comparison.brand_revenue_rank,
    dt_brand_comparison.brand_volume_rank,
    dt_brand_comparison.brand_yoy_growth_rank,
    dt_brand_comparison.brand_yoy_pct_growth_rank
    ]
  }
}

explore: customer_order_patterns {
  from: order_items
  view_label: "Order Details"
  fields: [
    ALL_FIELDS*
  ]

  join: order_sequence_2 {
    view_label: "Customer Order Patterns"
    sql_on: ${customer_order_patterns.order_id} = ${order_sequence_2.order_id} ;;
    relationship: many_to_one
    }

  join: customer_behavior {
    sql_on: ${customer_behavior.id} = ${order_sequence_2.user_id} ;;
    relationship: many_to_one
  }

  join: order_sequence_3 {
    view_label: "Customer Order Patterns"
    sql_on: ${order_sequence_2.user_id} = ${order_sequence_3.user_id} ;;
    relationship: many_to_one
  }

# Necessary for revenue calculations in the order_items view
  join: inventory_items {
    view_label: "Product Details"
    sql_on: ${customer_order_patterns.inventory_item_id} = ${inventory_items.id};;
    relationship: many_to_one
    fields: [inventory_items.cost_hidden, inventory_items.product_id]
  }

  join: products {
    view_label: "Product Details"
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

# This is here only to generate the derived table order_sequence_2
explore: order_sequence_1 {
  hidden: yes
}

# This is here only to generate the derived table order_sequence_3
explore: order_sequence_2 {
  hidden: yes
}

# explore: events {
#   join: users {
#     type: left_outer
#     sql_on: ${events.user_id} = ${users.id} ;;
#     relationship: many_to_one
#   }
# }

# explore: inventory_items {
#   join: products {
#     type: left_outer
#     sql_on: ${inventory_items.product_id} = ${products.id} ;;
#     relationship: many_to_one
#   }

#   join: distribution_centers {
#     type: left_outer
#     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
#     relationship: many_to_one
#   }
# }

explore: order_items {
  # sql_always_where: ${returned_raw} IS NULL AND ${status} = 'Complete' ;;
  # sql_always_having: ${total_sale_price} > 200 AND ${count} > 2 ;;
  # always_filter: {
  #   filters: [order_items.created_date: "after 30 days ago"]
  # }
  # conditionally_filter: {
  #   filters: [order_items.created_year: "after 2 years ago"]
  #   unless: [users.id]
  # }
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

# explore: products {
#   join: distribution_centers {
#     type: left_outer
#     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
#     relationship: many_to_one
#   }
# }

explore: customers {
  view_name: customer_behavior
  view_label: "Customer Behavior"

  # join: order_items {
  #   view_label: "Customer Behavior"
  #   type: left_outer
  #   sql_on: ${customer_behavior.order_id} = ${order_items.order_id} ;;
  #   relationship: one_to_one
  # }

  join: users {
    view_label: "Customer Attributes"
    type: left_outer
    sql_on: ${customer_behavior.id} = ${users.id} ;;
    relationship: many_to_one
  }
}

  # conditionally_filter: {
  #   filters: [users.created_date: "after 90 days ago"]
  #   unless: [users.id, users.state]
  # }
# }
