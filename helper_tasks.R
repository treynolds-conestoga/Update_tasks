# Drop table
# vrtoolbox::sql.initialize_connector("data_science") %>% #vrtoolbox::sql.display_all_tables()
#   vrtoolbox::sql.run_query(
#     .CON = .,
#     .QUERY = "drop table scheduled_tasks"
#   )


# Check if data is correct
vrtoolbox::scheduler.show_tasks() |>
  dplyr::mutate(
    Location = "Kansas"
  ) |>
  dplyr::glimpse()



# Initial add data
vrtoolbox::sql.initialize_connector("data_science") %>%
  vrtoolbox::sql.create_table(
    .CON = .,
    .TABLE_NAME = "scheduled_tasks",
    .DATA = vrtoolbox::scheduler.show_tasks() |>
      dplyr::mutate(
        Location = "Kansas"
      )
  )




vrtoolbox::scheduler.show_tasks("all")
vrtoolbox::scheduler.set_task(
  .TASKNAME = "Update_task_db",
  .FILENAME = "main.R",
  .SCHEDULE = "WEEKLY",
  .START_DATE = "09/11/2022",
  .START_TIME = "06:00",
  .DAYS = c("Mon", "TUE", "WED", "THU", "FRI")
)
vrtoolbox::scheduler.delete("Update_task_db")
vrtoolbox::scheduler.run_now("Update_task_db")



vrtoolbox::sql.initialize_connector('data_science') %>%
  vrtoolbox::sql.run_query(
    .CON = .,
    .QUERY = "select * from scheduled_tasks"
  )










