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

dbListTables(conn) # find out which tables I have access to

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

# Analysis

## Total managers
week13_tbl %>%
  summarize(total_managers = n()) %>%
  print()

## Unique managers
week13_tbl %>%
  summarize(unique_managers = n_distinct(employee_id)) %>%
  print() # same as total managers

## Managers (not originally hired as managers) by location
week13_tbl %>%
  filter(manager_hire == "N") %>%
  group_by(city) %>%
  summarize(managers_per_city = n()) %>%
  print()

## Means and SDs of employment years by performance level
week13_tbl %>%
  mutate(performance_level = factor(performance_group, levels = c("Bottom", "Middle", "Top"))) %>%
  group_by(performance_level) %>%
  summarize(m_years = mean(yrs_employed), sd_years = sd(yrs_employed)) %>%
  print()

## Managers by urban/suburban (alphabetical), ID, test score (descending)
week13_tbl %>%
  select(office_type, employee_id, test_score) %>%
  arrange(office_type, desc(test_score)) %>%
  print()