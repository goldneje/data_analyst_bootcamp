view: etl_jobs {
  sql_table_name: "PUBLIC"."ETL_JOBS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: completed {
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
    sql: ${TABLE}.completed_at ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
