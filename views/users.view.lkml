view: users {
  sql_table_name: "PUBLIC"."USERS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: age {
    group_label: "Customer Info"
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: city {
    group_label: "Address Info"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: country {
    group_label: "Address Info"
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: email {
    group_label: "Customer Info"
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: first_name {
    group_label: "Customer Info"
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gender {
    group_label: "Customer Info"
    type: string
    sql: ${TABLE}."GENDER" ;;
  }

  dimension: last_name {
    group_label: "Customer Info"
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: latitude {
    hidden: yes
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    hidden: yes
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: state {
    group_label: "Address Info"
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  dimension: zip {
    group_label: "Address Info"
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, events.count, order_items.count]
  }
  measure: website_first_time{
    type: date
    sql:  min(${created_date}) ;;
  }
}
