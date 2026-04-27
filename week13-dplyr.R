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