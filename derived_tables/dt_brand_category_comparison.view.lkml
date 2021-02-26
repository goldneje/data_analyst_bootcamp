view: dt_brand_category_comparison {
  derived_table: {
    explore_source: brand_comparison {
      column: brand { field: products.brand }
      column: brand_category_id { field: products.brand_category_id}
      column: category_revenue_rank { field: order_items.category_revenue_rank }
      column: category_volume_rank { field: order_items.category_volume_rank }
      column: category_yoy_growth_rank { field:order_items.brand_yoy_growth_rank }
      column: category_yoy_pct_growth_rank { field:order_items.brand_yoy_pct_growth_rank }
      column: category { field: products.category }
    }
    # datagroup_trigger: data_analyst_bootcamp_default_datagroup
  }
  dimension: brand_category_id {
    primary_key: yes
    hidden: yes
  }

  dimension: brand {
    label: "Brand Details Brand"
  }
  dimension: category_revenue_rank {
    label: "Sales Measures Category Revenue Rank"
    description: "Rank based on revenue by category"
    type: number
  }
  dimension: category_volume_rank {
    label: "Sales Measures Category Volume Rank"
    description: "Rank based on order volume by category"
    type: number
  }

  dimension: category_yoy_growth_rank {
    type: number
  }

  dimension: category_yoy_pct_growth_rank {
    type: number
  }

  dimension: category {
    label: "Brand Details Category"
  }
}
