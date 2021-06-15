view: top_10_brands {
  derived_table: {
    sql: select p.brand, sum(o.sale_price-i.cost)/sum(o.sale_price) as margin_p
      from order_items as o
      left join inventory_items as i
      on i.id = o.inventory_item_id
      left join products as p
      on i.product_id = p.id
      group by p.brand
      order by margin_p DESC
      limit 10
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
    primary_key: yes
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

  dimension: margin_p {
    type: number
    sql: ${TABLE}."MARGIN_P" ;;
    value_format_name: percent_2
    drill_fields: [detail*]
  }

  set: detail {
    fields: [brand, margin_p]
  }
}
