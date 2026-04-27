# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(tidyverse)
library(DBI)
library(RPostgres)
library(usethis)

# Data Import and Cleaning
conn <- DBI::dbConnect(
  RPostgres::Postgres(),
  user = Sys.getenv("NEON_USER"),
  password = Sys.getenv("NEON_PW"),
  dbname = "neondb",
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech",
  port = 5432,
  sslmode = "require")

dbListTables(conn) # Find out which tables I have access to

## Download data science datasets
employees_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_employees")
testscores_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_testscores")
offices_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_offices")

## Save as .csv
write_csv(employees_tbl, "../out/employees.csv")
write_csv(testscores_tbl, "../out/testscores.csv")
write_csv(offices_tbl, "../out/offices.csv")

## Combine data such that employees without test scores are removed
week13_tbl <- employees_tbl %>%
  inner_join(testscores_tbl, by = "employee_id") %>%
  left_join(offices_tbl, by = c("city" = "office"))

write_csv(week13_tbl, "../out/week13.csv")
