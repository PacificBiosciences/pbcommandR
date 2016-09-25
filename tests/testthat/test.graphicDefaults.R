library(pbcommandR)
library(ggplot2)
context("Test for accessing and using the graphics defaults")

getData <- function(n) data.frame(y = rnorm(n), x = factor(1:n))


test_that("fillScaleWorks", {
  n = 7
  q = getPBFillScale(n)
  df = getData(n)
  ggplot(df, aes(x = x, y = y, fill = x)) + geom_bar(stat = "identity") + q

  n = 20
  q = getPBFillScale(n)
  df = getData(n)
  ggplot(df, aes(x = x, y = y, fill = x)) + geom_bar(stat = "identity") + q
  expect_equal(0, 0)
})


test_that("colorScaleWorks", {
  n = 7
  q = getPBColorScale(n)
  df = getData(n)
  ggplot(df, aes(x = x, y = y, color = x)) + geom_point() + q

  n = 20
  q = getPBColorScale(n)
  df = getData(n)
  ggplot(df, aes(x = x, y = y, color = x)) + geom_point() + q
  expect_equal(0, 0)
})


test_that("themeWorks", {
  n = 20
  q = getPBColorScale(n)
  df = getData(n)
  ggplot(df, aes(x = x, y = y, color = x)) + geom_point() + getPBTheme() + q
})
