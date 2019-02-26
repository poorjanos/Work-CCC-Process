library(dplyr)

# Check names in original
names(t_ccc_pa)

# Concat media and activity -------------------------------------------------------------
# Concat variables
t_ccc_pa_PG_export <- t_ccc_pa %>%
  mutate(ACTIVITY_COMB_EN = paste(EVENT_CHANNEL, ACTIVITY_EN)) %>%
  select(CASE_ID, EVENT_END, ACTIVITY_COMB_EN, CASE_TYPE_EN, CASE_TYPE_PROB_CAT, USER_ID) %>%
  arrange(CASE_ID, EVENT_END)


# Change to names to fit PG
names(t_ccc_pa_PG_export) <- c("Case ID", "Event end", "Activity", "Case type", "Case owner", "User")


# Save
write.table(t_ccc_pa_PG_export,
            here::here("Data", "t_ccc_pa_PG_export.csv"),
            row.names = FALSE, sep = ";", quote = FALSE)




# Separate media and activity -------------------------------------------------------------
t_ccc_pa_PG_export <- t_ccc_pa %>%
  select(CASE_ID, EVENT_END, ACTIVITY_EN, EVENT_CHANNEL,
         CASE_TYPE_EN, CASE_TYPE_PROB_CAT, USER_ID) %>%
  arrange(CASE_ID, EVENT_END)


# Change to names to fit PG
names(t_ccc_pa_PG_export) <- c("Case ID", "Event end", "Activity", "Supplier", "Case type", "Case owner", "User")


# Save
write.table(t_ccc_pa_PG_export,
            here::here("Data", "t_ccc_pa_PG_export_sepmedia.csv"),
            row.names = FALSE, sep = ";", quote = FALSE)