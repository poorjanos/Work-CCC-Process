library(config)
library(here)


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
query_ccc_process <- "select distinct * from T_CCC_PA_OUTPUT4"
t_ccc_pa_raw <- dbGetQuery(jdbcConnection, query_ccc_process)

# Close db connection: kontakt
dbDisconnect(jdbcConnection)


# Write to csv
write.table(t_ccc_pa_raw, here::here("Data" ,"t_ccc_pa_raw_2.csv"), row.names = FALSE, sep = ";", quote = FALSE)

t_ccc_pa <- read.csv(here::here("Data" ,"t_ccc_pa_raw_2.csv"), sep = ";", stringsAsFactors = FALSE)


   