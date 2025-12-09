# NYC 311 Noise – figures (bars, percentages, types) + borough heatmaps (image export)
# Requires: dplyr, readr, ggplot2, lubridate, scales
# Optional (only if you regenerate basemap heatmaps): ggmap + a Google Maps API key

library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(scales)

# ---- paths ----
input_file <- "C:/Users/bhutt/OneDrive/Documents/ny/Filtered_311_Service_Requests1.csv"
dir.create("assets/plots", showWarnings = FALSE, recursive = TRUE)

# ---- load & prep ----
noise <- read_csv(input_file, show_col_types = FALSE) %>%
  mutate(
    Complaint.Type = as.character(Complaint.Type),
    Created.Date = parse_date_time(as.character(Created.Date),
                                   orders = c("mdy HMS", "mdy HM", "mdy"),
                                   tz = "America/New_York"),
    year = year(Created.Date)
  ) %>%
  filter(grepl("noise", tolower(Complaint.Type))) %>%
  filter(is.finite(Latitude), is.finite(Longitude))

# ---- yearly counts ----
complaints_per_year <- noise %>%
  group_by(year) %>%
  summarize(num_complaints = n(), .groups = "drop") %>%
  arrange(year) %>%
  mutate(year = as.factor(year))

p_year <- ggplot(complaints_per_year, aes(x = year, y = num_complaints, fill = year)) +
  geom_col() +
  scale_y_continuous(labels = label_comma()) +
  labs(x = "Year", y = "Number of complaints",
       title = "NYC 311 — Noise complaints by year") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")
ggsave("assets/plots/nyc_noise_by_year.png", p_year, width = 12, height = 6, dpi = 200)

# ---- yearly percentages ----
complaints_per_year <- complaints_per_year %>%
  mutate(percent = num_complaints / sum(num_complaints) * 100)

p_pct <- ggplot(complaints_per_year, aes(x = year, y = percent, fill = year)) +
  geom_col() +
  geom_text(aes(label = paste0(round(percent, 1), "%")), vjust = -0.25, size = 3) +
  labs(x = "Year", y = "Share of total (%)",
       title = "NYC 311 — Share of noise complaints by year") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")
ggsave("assets/plots/nyc_noise_pct_by_year.png", p_pct, width = 12, height = 6, dpi = 200)

# ---- by type ----
complaints_by_type <- noise %>%
  count(Complaint.Type, sort = TRUE)

p_type <- ggplot(complaints_by_type,
                 aes(x = reorder(Complaint.Type, n), y = n, fill = Complaint.Type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_y_continuous(labels = label_comma()) +
  labs(x = "Noise type", y = "Number of complaints",
       title = "NYC 311 — Noise complaints by type") +
  theme_minimal(base_size = 12)
ggsave("assets/plots/nyc_noise_by_type.png", p_type, width = 12, height = 8, dpi = 200)

# ---- borough counts (optional table) ----
noise_boro <- noise %>% count(Borough, sort = TRUE)
write_csv(noise_boro, "assets/plots/noise_by_borough_counts.csv")

# ---- NOTE on heatmaps ----
# Your images are already generated—great. If you ever need to re-generate:
#   Prefer Leaflet + OSM tiles for web use, or ensure Google Maps terms are respected
#   if using ggmap basemaps. Save with ggsave(...) into assets/plots/:
# ggsave("assets/plots/heat_manhattan.png", mp1, width = 10, height = 8, dpi = 200)
# ggsave("assets/plots/heat_brooklyn.png",  mp2, width = 10, height = 8, dpi = 200)
# ggsave("assets/plots/heat_bronx.png",     mp3, width = 10, height = 8, dpi = 200)
# ggsave("assets/plots/heat_queens.png",    mp4, width = 10, height = 8, dpi = 200)
# ggsave("assets/plots/heat_staten.png",    mp5, width = 10, height = 8, dpi = 200)
