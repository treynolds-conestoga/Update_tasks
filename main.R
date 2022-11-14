#' @title
#' ======
#' main.R
#'
#' @description
#' ============
#' Sends out pending trades that are overdue
#'
#' @method
#' =========
#' main()
#'
#' @author
#' =======
#' Troy Reynolds <treynolds@victoryrenewables.com>

##### Packages #################################################################
cat(sprintf("\n\nRun Time: %s", Sys.time()))
cat(sprintf("\nCurrent working directory: %s", getwd()))
args <- commandArgs(trailingOnly=TRUE)

if (getwd() == "C:/Windows/system32") {
  # Change this to project directory
  setwd(args[1])

  # Print New Directory
  cat(sprintf("\nNew Directory Set: %s\n", getwd()))

}

if (!"vrtoolbox" %in% rownames(installed.packages())) {
  devtools::install_github(
    "treynolds-conestoga/vrtoolbox",
    auth_token = "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",
    force = T
  )
}

# Libraries
if(!require(magrittr)) {
  library(magrittr)
}

##### Functions ################################################################
update_tasks_in_database <- function(.VM_NAME, .AUTHOR) {

  # Delete
  vrtoolbox::sql.initialize_connector("data_science") %>%
    vrtoolbox::sql.run_query(
      .CON = .,
      .QUERY = sprintf("delete from scheduled_tasks where HostName = '%s' and Author = '%s'", .VM_NAME, .AUTHOR)
    )

  # Update table
  vrtoolbox::sql.initialize_connector("data_science") %>%
    vrtoolbox::sql.append_table(
      .CON = .,
      .TABLE_NAME = "scheduled_tasks",
      .DATA = vrtoolbox::scheduler.show_tasks() |>
        dplyr::mutate(
          Location = "Kansas"
        )
    )
}

main <- function(.DURATION = 10) {

  # Constants
  .VM_NAME <- "TROY-VM"
  .AUTHOR <- "treynolds"

  # Set End time
  END_TIME <- Sys.time() + lubridate::hours(12)

  # Print durations
  cat(sprintf("\nScript Runs Every %s Minutes and will end at %s", .DURATION, END_TIME))

  # Set data
  TASKS <- vrtoolbox::sql.initialize_connector("data_science") %>%
    vrtoolbox::sql.run_query(
      .CON = .,
      .QUERY = sprintf("select * from scheduled_tasks where HostName = '%s' and Author = '%s'", .VM_NAME, .AUTHOR)
    ) |>
    dplyr::mutate(
      Status = Status |> factor(levels = c("Ready", "Disabled")),
      `Schedule Type` = `Schedule Type` |> factor(levels = c("One Time Only", "Minute", "Hourly", "Daily", "Weekly", "Monthly"))
    )

  # Create while condition to update database
  while(Sys.time() <= END_TIME) {

    # Print Last Runtime
    cat(sprintf("\nLast Runtime: %s", Sys.time()))

    # Get data again
    NEW_DATA <- vrtoolbox::scheduler.show_tasks() |>
      dplyr::mutate(
        Location = "Kansas"
      )

    # Check to see if data changed
    if (!identical(TASKS , NEW_DATA)) {

      # Set data
      TASKS <- NEW_DATA

      # Update table
      update_tasks_in_database(.VM_NAME = .VM_NAME, .AUTHOR = .AUTHOR)

      # Print result
      cat(" - Database updated...")
    }
    else{cat(" - No changes...")}

    # Sleep for 10 minutes
    Sys.sleep(.DURATION * 60)
  }
}

##### RUN ######################################################################
if (!interactive()) {
  main(60)
}









