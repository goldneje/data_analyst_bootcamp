view: top_10_brand_rev {
  derived_table: {
    sql: select p.brand, sum(sale_price), sum(o.sale_price)/(select sum(sale_price)
      from order_items) as revenue_p
      from order_items as o
      left join inventory_items as i
      on i.id = o.inventory_item_id
      left join products as p
      on i.product_id = p.id
      group by p.brand
      order by revenue_p DESC
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

  dimension: sumsale_price {
    type: number
    sql: ${TABLE}."SUM(SALE_PRICE)" ;;
  }

  dimension: revenue_p {
    type: number
    sql: ${TABLE}."REVENUE_P" ;;
    value_format_name: percent_2
  }

  set: detail {
    fields: [brand, sumsale_price, revenue_p]
  }
}
