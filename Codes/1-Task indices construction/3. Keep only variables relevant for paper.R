# This code clears the task data to retain only the variables to be used in the 
# paper:

# If you use the codes for your research, please cite the paper listed above.

# This code requires running the code files "1. Create ESCO task indices.R" and 
# "2. Combine with ONET task indices.R" first.


##############################


# Groundhog will load the packages with their versions from the last time this code was run.
# The R version used at the time was 4.3.2.

# install.packages("groundhog")
groundhog::groundhog.library(c("dplyr", "stringr", "tidyr"), 
                             date = "2024-04-23")

# Set the path for your outputs (including from the previous code file)
outputs <- ""

# Load the data resulting from prior code file
full_set <- read.csv(paste0(outputs, "esco_onet_tasks.csv"))

#For the skills and wages paper
full_set <- full_set[, c("occupationCode", "isco08", "tasks_social_outward",
                         "tasks_social_inward", "tasks_social", 
                         "tasks_analytical", "tasks_routine", 
                         "tasks_nonroutine", "tasks_manual", 
                         "tasks_social_care", "tasks_social_mngmt",
                         "ess_tasks_social", "ess_tasks_social_outward",
                         "ess_tasks_social_inward", "ess_tasks_analytical",
                         "ess_tasks_routine", "ess_tasks_nonroutine", 
                         "ess_tasks_manual", "ess_tasks_social_care", 
                         "ess_tasks_social_mngmt", "opt_tasks_social", 
                         "opt_tasks_social_outward", "opt_tasks_social_inward",
                         "opt_tasks_analytical", "opt_tasks_routine", 
                         "opt_tasks_nonroutine", "opt_tasks_manual", 
                         "opt_tasks_social_care", "opt_tasks_social_mngmt", 
                         "t_4A2a4", "t_4A2b2", "t_4A4a1", "t_4A4a4", "t_4A4b4", 
                         "t_4A4b5", "t_4C3b7", "t_4C3b4", "t_4C3b8_rev", 
                         "t_4C3d3", "t_4A3a3", "t_4C2d1i", "t_4A3a4", 
                         "t_4C2d1g", "t_1A2a2", "t_1A1f1", "t_2B1a", 
                         "t_4C1a2l_rev", "t_4A4a5_rev", "t_4A4a8_rev", 
                         "t_4A1b2_rev", "t_4A3a2_rev", "t_4A3b4_rev", 
                         "t_4A3b5_rev"
                         )
                     ]

write.csv(full_set, paste0(outputs, "\\esco_onet_matysiaketal2024.csv"), row.names = FALSE, na = "")
