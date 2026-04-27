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

# Analysis
## Total managers
dbGetQuery(conn, "
           SELECT COUNT(*) AS total_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL;
           ")

## Unique managers
dbGetQuery(conn, "
           SELECT COUNT(DISTINCT employee_id) AS unique_managers
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL;
           ")

## Managers (not originally hired as managers) by location
dbGetQuery(conn, "
           SELECT city, COUNT(*) AS managers_per_city
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE manager_hire = 'N' AND test_score IS NOT NULL
           GROUP BY city;
           ")

## Means and SDs of employment years by performance level
dbGetQuery(conn, "
           SELECT performance_group, AVG(yrs_employed) AS m_years, STDDEV(yrs_employed) AS sd_years
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score IS NOT NULL
           GROUP BY performance_group;
           ")

## Managers by urban/suburban (alphabetical), ID, test score (descending)
dbGetQuery(conn, "
           SELECT office_type, employee_id, test_score
           FROM datascience_employees
           INNER JOIN datascience_testscores
           USING (employee_id)
           INNER JOIN datascience_offices
           ON datascience_employees.city = datascience_offices.office
           WHERE test_score IS NOT NULL
           ORDER BY office_type ASC, test_score DESC;
           ")