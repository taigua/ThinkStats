library(conflicted)
library(tidyverse)
library(duckplyr)
library(arrow)

conflicts_prefer(dplyr::filter)

t <- tibble(value = c(1.0, 2.0, 2.0, 3.0, 5.0))

ftab <- count(t, value)
ftab

ggplot(ftab, aes(x = value, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Value", y = "Frequency")

ftab$value

ftab$n

for (i in 1:nrow(ftab)) {
  cat(ftab[[i, "value"]], ftab[[i, "n"]], "\n")
}

preg <- read_parquet("../data/2002FemPregCleaned.parquet")

live <- preg |>
  filter(outcome == 1)

ftab_lb <- count(live, birthwgt_lb)
ggplot(ftab_lb, aes(x = birthwgt_lb, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Pounds", y = "Frequency")

ftab_lb$birthwgt_lb[which.max(ftab_lb$n)]

ftab_oz <- count(live, birthwgt_oz)
ggplot(ftab_oz, aes(x = birthwgt_oz, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Ounces", y = "Frequency")

ftab_age <- count(live, agepreg)
ggplot(ftab_age, aes(x = agepreg, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Age", y = "Frequency")

ftab_length <- count(live, prglngth)
ggplot(ftab_length, aes(x = prglngth, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Weeks", y = "Frequency")

ftab_length |> slice_head(n = 10)
ftab_length |> slice_tail(n = 10)

firsts <- live |> filter(birthord == 1)
others <- live |> filter(birthord != 1)

ftab_firsts <- count(firsts, prglngth)
ftab_others <- count(others, prglngth)

two_bar_plots <- function(name1, ftab1, name2, ftab2, ...) {
  ftab1 <- ftab1 |> mutate(cat = name1)
  ftab2 <- ftab2 |> mutate(cat = name2)
  ftab <- bind_rows(ftab1, ftab2)

  names <- colnames(ftab)

  g <- ggplot(ftab, aes_string(x = names[1], y = names[2], fill = names[3])) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(...)

  extra <- list(...)
  if ("xlim" %in% names(extra)) {
    g <- g + xlim(extra$xlim[1], extra$xlim[2])
  }


  return(g)
}

two_bar_plots("firsts", ftab_firsts, "others", ftab_others,
  x = "Weeks", y = "Frequency", xlim = c(20, 50)
)


cat(nrow(firsts), nrow(others))

first_mean <- mean(firsts$prglngth)
other_mean <- mean(others$prglngth)
cat(first_mean, other_mean)

diff <- first_mean - other_mean
cat(diff, diff * 7 * 24)

diff / mean(live$prglngth) * 100

diff / sd(live$prglngth)

group1 <- firsts$prglngth
group2 <- others$prglngth

v1 <- var(group1)
v2 <- var(group2)

n1 <- length(group1)
n2 <- length(group2)

pooled_var <- (n1 * v1 + n2 * v2) / (n1 + n2)
sqrt(pooled_var)

cat(sd(firsts$prglngth), sd(others$prglngth))

cohen_effect_size <- function(group1, group2) {
  diff <- mean(group1) - mean(group2)
  v1 <- var(group1)
  v2 <- var(group2)
  n1 <- length(group1)
  n2 <- length(group2)
  pooled_var <- (n1 * v1 + n2 * v2) / (n1 + n2)
  diff / sqrt(pooled_var)
}

cohen_effect_size(firsts$prglngth, others$prglngth)


# Exercises
# For the exercises in this chapter, we'll load the NSFG female respondent file,
# which contains one row for # each female respondent. Instructions for downloading
# the data and the codebook are in the notebook for this chapter.

resp <- read_parquet("../data/2002FemResp.parquet")
dim(resp)

# This DataFrame contains 3092 columns, but we'll use just a few of them.

# Exercise 2.1
# We'll start with totincr, which records the total income for the respondent's family,
# encoded with a value # from 1 to 14. You can read the codebook for the respondent
# file to see what income level each value represents.

# Make a FreqTab object to represent the distribution of this variable and plot it as a bar chart.

ftab_income <- count(resp, totincr)
ggplot(ftab_income, aes(x = totincr, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Income (category)", y = "Frequency")

# Exercise 2.2
# Make a frequency table of the parity column, which records the number of
# children each respondent has borne. How would you describe the shape of this distribution?

ftab_parity <- count(resp, parity)
ggplot(ftab_parity, aes(x = parity, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Parity", y = "Frequency")

# The distribution is skewed to the right.

slice_tail(ftab_parity, n = 10)

# Exercise 2.3
# Let's investigate whether women with higher or lower income bear more children.
# Use the query method to select the respondents with the highest income (level 14).
# Plot the frequency table of parity for just the high income respondents.

rich <- resp |> filter(totincr == 14)
ftab_parity <- count(rich, parity)
ggplot(ftab_parity, aes(x = parity, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "Parity", y = "Frequency")

# Compare the mean parity for high income respondents and others.
not_rich <- resp |> filter(totincr < 14)
cat(mean(rich$parity), mean(not_rich$parity))

# Compute Cohen's effect size for this difference. 
# How does it compare with the difference in pregnancy length for first babies and others?

cohen_effect_size(rich$parity, not_rich$parity)

# Solution

# The NSFG includes respondents born in different years and
# interviewed at different ages.
# Income and parity depend on both of these factors.

# To check whether people with higher income have more
# children, we need to compare people from the same generation
# interviewed at the same ages.
