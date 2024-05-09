# This code combines the task indices based on the ESCO classifications with the 
# ONET task indices based on Autor et al. (2011) - https://www.sciencedirect.com/science/article/pii/S0169721811024105

# The data is available directly from: to be included
# It was used for the paper: to be included

# If you use the codes for your research, please cite the paper listed above.

# This code requires running the code file "1. Create ESCO task indices.R" first.


##############################


# Groundhog will load the packages with their versions from the last time this code was run.
# The R version used at the time was 4.3.2.

# install.packages("groundhog")
groundhog::groundhog.library(c("dplyr", "stringr", "tidyr"), 
                             date = "2024-04-23")

# Set the path to the crosswalk file
crosswalk_path <- "" 

# Set the path for your outputs (including from the previous code file)
outputs <- ""

# Load the data resulting from prior code file
full_set <- read.csv(paste0(outputs, "esco_tasks.csv"))

# Set the path to the O*NET files, this code is based on version 25.0. 
# You can download them from here: https://www.onetcenter.org/database.html .
# You'll need the following files: 
# - Abilities.xlsx, 
# - Skills.xlsx, 
# - Work Activities.xlsx, 
# - Work Context.xlsx

onet_path <- ""

# Load crosswalk for occupation classifications and merge with data from previous code
crosswalk <- read.csv(paste0(crosswalk_path, "\\esco_onet_crosswalk.csv"))
colnames(crosswalk)[9] <- "occupationUri"
full_set <- left_join(full_set, crosswalk, by="occupationUri")

# Load and prepare the ONET data (these steps follow the codes of Autor et al., 2011)
abilities <- readxl::read_xlsx(paste0(onet_path, "Abilities.xlsx"))
skills <- readxl::read_xlsx(paste0(onet_path, "Skills.xlsx"))
work_activities <- readxl::read_xlsx(paste0(onet_path, "Work Activities.xlsx"))
work_context <- readxl::read_xlsx(paste0(onet_path, "Work Context.xlsx"))

colnames(abilities)[1] <- "ONET-SOC CODE"
colnames(skills)[1] <- "ONET-SOC CODE"
colnames(work_activities)[1] <- "ONET-SOC CODE"
colnames(work_context)[1] <- "ONET-SOC CODE"

onet_data <- rbind(
  abilities[c("Scale ID", "Data Value", "ONET-SOC CODE", "Element ID")],
  skills[c("Scale ID", "Data Value", "ONET-SOC CODE", "Element ID")],
  work_activities[c("Scale ID", "Data Value", "ONET-SOC CODE", "Element ID")],
  work_context[c("Scale ID", "Data Value", "ONET-SOC CODE", "Element ID")]
)

onet_data <- onet_data[onet_data$`Scale ID`=="IM" | onet_data$`Scale ID`=="CX",]
onet_data$`Scale ID` <- NULL
colnames(onet_data)[1] <- "score"
onet_data$`Element ID` <- onet_data$`Element ID` %>% str_replace_all("\\.", "")
onet_data$`Element ID` <- paste0("t_", onet_data$`Element ID`)

onet_data <- pivot_wider(onet_data, names_from = `Element ID`, values_from = score)
onet_data$t_4C3b8_rev=6-onet_data$t_4C3b8
onet_data$t_4C1a2l_rev=6-onet_data$t_4C1a2l
onet_data$t_4C2a3_rev=6-onet_data$t_4C2a3
onet_data$t_4A4a4_rev=6-onet_data$t_4A4a4
onet_data$t_4A4a5_rev=6-onet_data$t_4A4a5
onet_data$t_4A4a8_rev=6-onet_data$t_4A4a8
onet_data$t_4A4b5_rev=6-onet_data$t_4A4b5
onet_data$t_4A1b2_rev=6-onet_data$t_4A1b2
onet_data$t_4A3a2_rev=6-onet_data$t_4A3a2
onet_data$t_4A3a3_rev=6-onet_data$t_4A3a3
onet_data$t_4A3a4_rev=6-onet_data$t_4A3a4
onet_data$t_4A3b4_rev=6-onet_data$t_4A3b4
onet_data$t_4A3b5_rev=6-onet_data$t_4A3b5

onet_data <- onet_data[c("ONET-SOC CODE",
                         "t_4A2a4",
                         "t_4A2b2",
                         "t_4A4a1",
                         "t_4A4a4",
                         "t_4A4b4",
                         "t_4A4b5",
                         "t_4C3b7",
                         "t_4C3b4",
                         "t_4C3b8_rev",
                         "t_4C3d3",
                         "t_4A3a3",
                         "t_4C2d1i",
                         "t_4A3a4",
                         "t_4C2d1g",
                         "t_1A2a2",
                         "t_1A1f1",
                         "t_2B1a",
                         "t_4C1a2l_rev",
                         "t_4A4a5_rev",
                         "t_4A4a8_rev",
                         "t_4A1b2_rev",
                         "t_4A3a2_rev",
                         "t_4A3b4_rev",
                         "t_4A3b5_rev"
)
]

colnames(onet_data)[1] <- "onet_code"

# Combine ESCO and ONET tasks
full_set <- left_join(full_set, onet_data, by="onet_code")

# Save the data
write.csv(full_set, paste0(outputs, "\\esco_onet_tasks.csv"), row.names = FALSE, na = "")

