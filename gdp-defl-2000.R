library(dplyr)
library(readr)
library(WDI)
library(tidyr)
library(ggplot2)
library(readxl)
library(cellranger)
library(simputation)
library(imputeTS)
library(tinytex)
library(pandoc)

# Prepare income class 2000 classification
# Replace the pathname from your computer
Inc2000 <- read_excel("/Users/dayadau/Documents/Data/0_Portfolio/R_gdp deflator 2000/historical_classification_by_income.xlsx", "Country Analytical History")

income2000 <- Inc2000[c(1,11:238),c(1,2,16)]

income2000 <- income2000 %>% 
  rename(incomeold = ...16) %>%
  rename(iso3c = ...1) %>%
  filter(incomeold!="..")

income2000$incomeold <- factor(
  income2000$incomeold, 
  levels = c("L", "LM", "UM", "H"), 
  labels = c("Low income (2000)", 
             "Lower middle income (2000)", 
             "Upper middle income (2000)", 
             "High income (2000)"))

# Load data
if(!exists("WDI_df")) {
  WDI_df <- WDI(indicator = c("NY.GDP.DEFL.KD.ZG"),
                start = 2000,
                end = 2022,
                extra = TRUE)}

gdpdfl_2000 <- WDI_df %>%
  rename(GDPdefl = NY.GDP.DEFL.KD.ZG) %>% 
  select(country, iso3c, year, GDPdefl, income) %>% 
  subset(income != "Aggregates" & !(iso3c == "COD" & year == "2000" ))

# Data Processing
## Filter out NA
# income2000 is the data with the old income category
merge_gdpdefl <- merge(gdpdfl_2000, income2000, by="iso3c", all.x=FALSE)

# Check for missing values
statsNA(merge_gdpdefl$GDPdefl)

# Create group of countries only have 0 or 1 observations
many_na_countries_2000 <- merge_gdpdefl %>%
  filter(is.na(GDPdefl)) %>%
  group_by(country) %>%
  summarise(n()) %>%
  filter(`n()` >= 23)

# Filter out them from the main dataset
many_na_countries_list_2000 <- many_na_countries_2000$country

dataGDPdeflator_2000 <- merge_gdpdefl %>%
  mutate(drop = ifelse(country %in% many_na_countries_list_2000, T, F)) %>%
  filter(drop == F) %>%
  select(-drop)

statsNA(dataGDPdeflator_2000$GDPdefl)

## Imputation for NA
# Linear Regression approach

simpdataGDPdeflator_2000 <- impute_lm(dataGDPdeflator_2000, GDPdefl ~ year*country) 

## After imputation
ggplot(simpdataGDPdeflator_2000, aes(x = year, y = GDPdefl, color = country)) +
  geom_line(stat = "identity", show.legend = F) 

summary(simpdataGDPdeflator_2000)

# Visualisation
# Building Mean
GDPdeflmean_2000 <- simpdataGDPdeflator_2000 %>%
  group_by(year, incomeold) %>%
  summarise(mean_GDPdefl = mean(GDPdefl, na.rm=T))

# Plot
ggplot () + 
  geom_line(data=GDPdeflmean_2000, aes(x=year, y=mean_GDPdefl, color = incomeold), size= 1.2)+
  labs(title="Inflation, GDP deflator")+
  ylab("GDP deflator (annual %)")+xlim(2000, 2022)+ylim(-5,30)+
  xlab("Year")+
  theme_bw()+
  scale_colour_brewer (breaks=c("Low income (2000)", "Lower middle income (2000)", "Upper middle income (2000)", "High income (2000)"), palette = "Spectral")
