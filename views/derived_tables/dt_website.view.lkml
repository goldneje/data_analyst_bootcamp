view: dt_website {
    derived_table: {
      explore_source: users {
        column: website_first_time {}
        column: id {}
        column: gender {}
        column: created_date { field: users.created_date }

      }
    }
  dimension: created_date {
    type: date
  }
    dimension: website_first_time {
      type: date
    }

    dimension: id {
      type: number
    }
    dimension: gender {}


dimension: days_since_creation {
  type:  duration_day
  sql_start: website_first_time;;
  sql_end: GETDATE();;
}

  dimension: months_since_creation {
    type:  duration_month
    sql_start: website_first_time;;
    sql_end: GETDATE();;
  }
  measure: count {
    type: count
    drill_fields: [users.created_date]
  }
  measure: avg_of_days_since_website_creation {
    type: average
    sql:  ${days_since_creation} ;;
  }
  measure: avg_of_months_since_website_creation {
    type: average
    sql:  ${months_since_creation} ;;
  }
}
