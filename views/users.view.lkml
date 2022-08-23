view: users {
  sql_table_name: `looker-partners.thelook.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    style: integer
    tiers: [15, 26, 36, 51, 66]
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_num,
      day_of_month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: days_since_signup {
    type: duration_day
    sql_start: min(${created_date}) ;;
    sql_end: GETDATE() ;;
  }

  dimension: is_before_current_day {
    hidden: yes
    description: "Flag for whether something is at or below the current day for Month to Date analysis"
    type: yesno
    sql: ${created_day_of_month} <= DAY(CURRENT_DATE()) ;;
  }

  dimension: is_new_customer {
    type: yesno
    description: "Flag for whether a customer is new within the last 90 days"
    sql: ${created_date} > DATEADD('day', -90, CURRENT_DATE()) ;;
  }

  dimension: new_customer_label {
    type: string
    case: {
      when: {
        sql: ${is_new_customer} = 1 ;;
        label: "New Customer"
      }
      else: "Long-term Customer"
    }
    drill_fields: [age_tier, gender]
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    hidden: no
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    hidden: no
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: name {
    label: "Full Name"
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: latitude {
    hidden: yes
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    hidden: yes
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.state ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    map_layer_name: us_zipcode_tabulation_areas
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    label: "Number of Customers"
    type: count
    drill_fields: [default_count_drill*]
  }

  measure: count_CMTD {
    label: "Number of Customers CMTD"
    type: count
    drill_fields: [default_count_drill*]
    filters: [
      is_before_current_day: "Yes",
      created_date: "after 1 month ago"
    ]
  }

  measure: count_LMTD {
    label: "Number of Customers LMTD"
    type: number
    drill_fields: [default_count_drill*]
    sql: LAG(${count_CMTD}, 1) OVER(ORDER BY ${created_month}) ;;
  }

  set: default_count_drill {
    fields: [id, last_name, first_name, events.count, order_items.count]
  }
}
