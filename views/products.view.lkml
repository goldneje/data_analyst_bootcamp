view: products {
  sql_table_name: `looker-partners.thelook.products`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
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
    sql: ${TABLE}.category ;;
  }

  dimension: brand_category_id {
    hidden: yes
    description: "Creating a primary key for brand and category rankings to join tables"
    type: string
    sql: CONCAT(${brand}, ${category}) ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
    value_format_name: usd
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    label: "Item Name"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
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
  }

  measure: average_cost {
    description: "Average cost of items sold from inventory"
    type: average
    sql: ${cost} ;;
    value_format_name: usd
  }
}
