view: products {
  sql_table_name: "PUBLIC"."PRODUCTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
    drill_fields: [category, name]
    link: {
      label: "Search for {{ value }}"
      url: "https://www.google.com/search?q={{ value | url_encode }}"
      icon_url: "https://www.google.com/favicon.ico"
    }
    link: {
      label: "Find {{ value }} on Facebook"
      url: "https://www.facebook.com/search/top?q={{ value | url_encode }}"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/F_icon.svg/1024px-F_icon.svg.png"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: brand_category_id {
    hidden: yes
    description: "Creating a primary key for brand and category rankings to join tables"
    type: string
    sql: CONCAT(${brand}, ${category}) ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
    value_format_name: usd
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}."DISTRIBUTION_CENTER_ID" ;;
  }

  dimension: name {
    label: "Item Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}."RETAIL_PRICE" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  measure: count {
    label: "Number of Products"
    type: count
    drill_fields: [id, name, distribution_centers.name, distribution_centers.id, inventory_items.count]
  }

  measure: total_cost {
    description: "Total cost of items sold from inventory"
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
    drill_fields: [default_product_drill*]
  }

  measure: average_cost {
    description: "Average cost of items sold from inventory"
    type: average
    sql: ${cost} ;;
    value_format_name: usd
    drill_fields: [default_product_drill*]
  }

  set: default_product_drill {
    fields: [brand, name, retail_price]
  }
}
