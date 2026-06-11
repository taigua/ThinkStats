library(conflicted)
library(tidyverse)
library(duckplyr)
library(arrow)

conflicts_prefer(dplyr::filter)

preg <- read_parquet("../data/2002FemPreg.parquet")

dim(preg)

slice_head(preg, n = 5)

names(preg)

pregordr <- preg$pregordr
class(pregordr)

pregordr[1:5]


d <- list(
  Value = c("1", "2", "3", "4", "5", "6", "Total"),
  Label = c(
    "LIVE BIRTH",
    "INDUCED ABORTION",
    "STILLBIRTH",
    "MISCARRIAGE",
    "ECTOPIC PREGNANCY",
    "CURRENT PREGNANCY",
    ""
  ),
  Total = c(9148, 1862, 120, 1921, 190, 352, 13593)
)

as_tibble(d)

preg |> 
  count(outcome)

d <- list(
    Value = c(".", "0-5", "6", "7", "8", "9-95", "97", "98", "99", "Total"),
    Label = c(
        "inapplicable",
        "UNDER 6 POUNDS",
        "6 POUNDS",
        "7 POUNDS",
        "8 POUNDS",
        "9 POUNDS OR MORE",
        "Not ascertained",
        "REFUSED",
        "DON'T KNOW",
        ""
    ),
    Total = c(4449, 1125, 2223, 3049, 1889, 799, 1, 1, 57, 13593)
)
as_tibble(d)

counts <- preg |> count(birthwgt_lb)
counts

slice_head(counts, n = 6)

counts |> 
  slice_head(n = 6) |> 
  pull(n) |> 
  sum()

preg <- preg |> 
  mutate(
    birthwgt_lb = ifelse(birthwgt_lb %in% c(51, 97, 98, 99), NA, birthwgt_lb)
  )

preg |> 
  pull(agepreg) |> 
  mean(na.rm = TRUE)

preg <- preg |> 
  mutate(
    agepreg = agepreg / 100.0
  )
mean(preg$agepreg, na.rm = TRUE)

preg |> count(birthwgt_oz)

preg <- preg |> 
  mutate(
    birthwgt_oz = ifelse(birthwgt_oz %in% c(97, 98, 99), NA, birthwgt_oz)
  )

preg <- preg |> 
  mutate(
    totalwgt_lb = birthwgt_lb + birthwgt_oz / 16.0
  )
mean(preg$totalwgt_lb, na.rm = TRUE)

weights <- preg$totalwgt_lb
n <- sum(!is.na(wts))

mean <- sum(weights, na.rm = TRUE) / n
mean

mean(weights, na.rm = TRUE)

squared_deviations = (weights - mean) ^ 2
var <- sum(squared_deviations, na.rm = TRUE) / n
var

var(weights, na.rm = TRUE)

std <- sqrt(var)
std

sd(weights, na.rm = TRUE)

subset <- preg |> 
  filter(caseid == 10229)
dim(subset)

subset$outcome

# Exercises
# Exercise 1.1
# Select the birthord column from preg, print the value counts, and compare to results published
# in the codebook at 
# https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NSFG/Cycle6Codebook-Pregnancy.pdf.
preg |> count(birthord)

# Exercise 1.2
# Create a new column named totalwgt_kg that contains birth weight in kilograms 
# (there are approximately 2.2 pounds per kilogram). 
# Compute the mean and standard deviation of the new column.
subset <- preg |> filter(caseid == 2298)
subset$prglngth

# What was the birth weight of the first baby born to the respondent with caseid 5013? 
# Hint: You can use and to check more than one condition in a query.
subset <- preg |> filter(caseid == 5013)
subset$totalwgt_lb

subset <- preg |> filter(caseid == 5013, birthord == 1)
subset$totalwgt_lb
