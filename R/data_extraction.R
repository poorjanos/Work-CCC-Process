library(config)
library(here)
library(dplyr)
library(tidyr)


#########################################################################################
# Data Extraction #######################################################################
#########################################################################################

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME = "C:\\Program Files\\Java\\jre1.8.0_171")
options(java.parameters = "-Xmx2g")
library(rJava)

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)

# Get credentials
datamnr <-
  config::get("datamnr", file = "C:\\Users\\PoorJ\\Projects\\config.yml")

# Create connection driver
jdbcDriver <-
  JDBC(driverClass = "oracle.jdbc.OracleDriver", classPath = "C:\\Users\\PoorJ\\Desktop\\ojdbc7.jar")

# Open connection: kontakt---------------------------------------------------------------
jdbcConnection <-
  dbConnect(
    jdbcDriver,
    url = datamnr$server,
    user = datamnr$uid,
    password = datamnr$pwd
  )

# Fetch data
query_ccc_process <- "select distinct * from T_CCC_PA_OUTPUT_TOP3"
t_ccc_pa_raw <- dbGetQuery(jdbcConnection, query_ccc_process)

# Close db connection: kontakt
dbDisconnect(jdbcConnection)


# Write raw data to csv
# write.table(t_ccc_pa_raw, here::here("Data" ,"t_ccc_pa_raw_2.csv"), row.names = FALSE, sep = ";", quote = FALSE)
# 
# t_ccc_pa <- read.csv(here::here("Data" ,"t_ccc_pa_raw_2.csv"), sep = ";", stringsAsFactors = FALSE)


# Concat media and activity -------------------------------------------------------------
# Concat variables
t_ccc_pa_PG_export <- t_ccc_pa_raw %>%
  mutate(ACTIVITY_COMB_EN = paste(EVENT_CHANNEL, ACTIVITY_EN)) %>%
  replace_na(list(PRODUCT_LINE = "UNKNOWN", PRODUCT_CODE = "UNKNOWN")) %>%
  select(CASE_ID, EVENT_END, ACTIVITY_COMB_EN, ACTIVITY_EN, EVENT_CHANNEL,
         CASE_TYPE_EN, CASE_TYPE_PROB_CAT, USER_ID, PRODUCT_CODE, PRODUCT_LINE) %>%
  arrange(CASE_ID, EVENT_END)

# Change to names to fit PG
names(t_ccc_pa_PG_export) <- c("Case ID", "Event end", "Activity", "Activity separate", "Channel", "Case type", "Case owner", "User", "Customer", "Customer type")


# Gen local export for EDA
t_ccc_pa_local_export <- t_ccc_pa_raw %>%
  mutate(ACTIVITY_COMB_EN = paste(EVENT_CHANNEL, ACTIVITY_EN)) %>%
  replace_na(list(PRODUCT_LINE = "UNKNOWN", PRODUCT_CODE = "UNKNOWN", CALL_TIME = 0)) %>%
  select(CASE_ID, EVENT_END, ACTIVITY_COMB_EN, ACTIVITY_EN, EVENT_CHANNEL,
         CASE_TYPE_EN, CASE_TYPE_PROB_CAT, USER_ID, PRODUCT_CODE, PRODUCT_LINE, CALL_TIME) %>%
  arrange(CASE_ID, EVENT_END)




# Write PG ready data to csv
write.table(t_ccc_pa_PG_export,
            here::here("Data", "t_ccc_pa_PG_export_top3.csv"),
            row.names = FALSE, sep = ";", quote = FALSE)



# Write EDA
write.table(t_ccc_pa_local_export,
            here::here("Data", "t_ccc_pa_local_export_top3.csv"),
            row.names = FALSE, sep = ";", quote = FALSE)


   