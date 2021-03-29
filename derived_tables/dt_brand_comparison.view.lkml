view: dt_brand_comparison {
  derived_table: {
    explore_source: brand_comparison {
      column: brand { field: products.brand }
      column: brand_volume_rank { field: order_items.brand_volume_rank }
      column: brand_revenue_rank { field: order_items.brand_revenue_rank }
      column: brand_yoy_growth_rank { field:order_items.brand_yoy_growth_rank }
      column: brand_yoy_pct_growth_rank { field:order_items.brand_yoy_pct_growth_rank }
    }
    # datagroup_trigger: data_analyst_bootcamp_default_datagroup
  }
  dimension: brand {
    primary_key: yes
    label: "Brand Details Brand"
  }
  dimension: brand_volume_rank {
    label: "Sales Measures Brand Volume Rank"
    description: "Rank based on order volume by category"
    type: number
  }
  dimension: brand_revenue_rank {
    label: "Sales Measures Brand Revenue Rank"
    description: "Rank based on revenue by brand"
    type: number
  }

  dimension: brand_yoy_growth_rank {
    type: number
  }

  dimension: brand_yoy_pct_growth_rank {
    type: number
  }
}
