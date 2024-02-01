# 01 - ggdemetra - Introduction ----

# The package is available on:
# - CRAN: https://cran.r-project.org/package=ggdemetra
# - GitHub: https://github.com/AQLT/ggdemetra
# - Website: https://aqlt.github.io/ggdemetra/


## Setup ----

# install.packages("ggdemetra")
library(ggdemetra)

citation("ggdemetra")


## Usage ----
library(ggplot2)
library(ggdemetra)

spec <- RJDemetra::x13_spec(
  spec = "RSA3", 
  tradingdays.option = "WorkingDays"
  )

p_ipi_fr <- ggplot(data = ipi_c_eu_df, mapping = aes(x = date, y = FR)) +
  geom_line(color = "#F0B400") +
  labs(
    title = "Seasonal adjustment of the French industrial production index",
    x = NULL, y = NULL
  ) +
  theme_light()

p_sa <- p_ipi_fr +
  geom_sa(
    component = "y_f", 
    linetype = 2, 
    spec = spec, 
    frequency = 12,
    color = "#F0B400"
    ) +
  geom_sa(
    component = "sa", 
    color = "#155692"
  ) +
  geom_sa(
    component = "sa_f",
    color = "#155692",
    linetype = 2
  )

p_sa

ggsave(filename = "figures/01_fr-ipi-sa.png", height = 8, width = 12)
graphics.off()


# To add outliers at the bottom of the plot with an arrow
# to the data point and the estimated coefficients
p_sa +
  geom_outlier(
    geom = "label_repel",
    coefficients = TRUE,
    ylim = c(NA, 65),
    arrow = arrow(length = unit(0.03, "npc"), type = "closed", ends = "last"), 
    digits = 2
  )

ggsave(filename = "figures/02_fr-ipi-sa-arrows.png", height = 8, width = 12)
graphics.off()


# To add the ARIMA model:
p_sa +
  geom_arima(
    geom = "label",
    x_arima = -Inf,
    y_arima = -Inf,
    vjust = -1,
    hjust = -0.1
  )

ggsave(filename = "figures/03_fr-ipi-sa-arima.png", height = 8, width = 12)
graphics.off()


# To add a table of diagnostics below the plot
diagnostics <- c(
  `Combined test` = "diagnostics.combined.all.summary",
  `Residual qs-test (p-value)` = "diagnostics.qs",
  `Residual f-test (p-value)` = "diagnostics.ftest"
)

p_diag <- ggplot(data = ipi_c_eu_df, mapping = aes(x = date, y = FR)) +
  geom_diagnostics(
    diagnostics = diagnostics,
    table_theme = gridExtra::ttheme_default(base_size = 8),
    spec = spec,
    frequency = 12
  ) +
  theme_light()

gridExtra::grid.arrange(p_sa, p_diag, nrow = 2, heights = c(4, 1.5))

ggsave(filename = "figures/04_fr-ipi-sa-diagnostics.png", height = 8, width = 12)
graphics.off()


# See the vignette for more details
# https://aqlt.github.io/ggdemetra/articles/ggdemetra.html


# Note that to use a `ts` object inside `ggplot2` functions,
# use the `ts2df()` function to convert `ts` or `mts` objects
# to `data.frame` objects.

ipi_c_eu_df <- ts2df(ipi_c_eu)


## Existing models ----

# The components of the seasonal adjustment models can
# be extracted through the functions
# - `calendar()`
# - `calendaradj()`
# - `irregular()`
# - `trendcycle()`
# - `seasonal()`
# - `seasonaladj()`
# - `raw()`


# If you already have a seasonally adjusted model,
# use the function `init_ggplot()`
spec <- RJDemetra::x13_spec(spec = "RSA3", tradingdays.option = "WorkingDays")

mod <- RJDemetra::x13(series = ipi_c_eu[ , "FR"], spec = spec)

init_ggplot(mod) +
  geom_line(color = "#F0B400") +
  geom_sa(component = "sa", color = "#155692") +
  theme_light()

ggsave(filename = "figures/05_fr-ipi-sa-init.png", height = 8, width = 12)
graphics.off()


# There exists an `outoplot()` function
autoplot(object = mod)
ggsave(filename = "figures/06_fr-ipi-sa-autoplot.png", height = 8, width = 12)
graphics.off()


# SI-ratio plots are obtained with `siratioplot()`
# or `ggsiratioplot()`
ggsiratioplot(mod)
ggsave(filename = "figures/06_fr-ipi-sa-ggsiratioplot.png", height = 8, width = 12)
graphics.off()

# END