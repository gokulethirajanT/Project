library(tidyverse)
setwd("C:/Users/sinag/Documents/Git/ifabi-2021/Project\ Week\ 6")


preAdj_tbl <- read_csv("preAdj_covHistogr.csv") %>%
  mutate(Time = "Pre-Adjustment")
posAdj_tbl <- read_csv("postAdj_covHistogr.csv")%>%
  mutate(Time = "Post-Adjustment")

cov_plt <- preAdj_tbl %>%
  bind_rows(posAdj_tbl) %>%
  ggplot(aes(x = start+500, y = cov))+
  facet_wrap("Time", ncol = 1, scales = "free_y")+
  geom_bar(stat = "identity", width = 1000)+
  labs(title = "Coverage of the Genome",
       subtitle = "Before and After Normalizing Sequncing Depth",
       y = "Coverage",
       x = "Position")
ggsave("coverage_plot.png")
