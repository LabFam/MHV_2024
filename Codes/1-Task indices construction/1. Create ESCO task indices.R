# This code creates the task indices based on the ESCO classifications. 
# The data is available directly from: to be included
# It was used for the paper: to be included

# If you use the codes for your research, please cite the paper listed above.


##############################


# Groundhog will load the packages with their versions from the last time this code was run.
# The R version used at the time was 4.3.2.

# install.packages("groundhog")
groundhog::groundhog.library(c("dplyr", "stringr", "tidyr"), 
                             date = "2024-04-23")

# Set the path to the ESCO v1.0.8 files. You can download them from here: https://esco.ec.europa.eu/en/use-esco/download .
# You'll need the following files: 
# - occupationSkillRelations.csv, 
# - skills_en.csv, 
# - occupations_en.csv, 
# - broaderRelationsSkillPillar.csv

esco_108 <- "" 

# Set the path for your outputs.
outputs <- ""

# Import occupation-skills relations (unique ids)
occupations_skills <- read.csv(paste0(esco_108, "/occupationSkillRelations.csv"))

# Import skill information
skills <- read.csv(paste0(esco_108, "/skills_en.csv"))
skills <- cbind(skills$conceptUri, skills$reuseLevel, skills$preferredLabel) %>% data.frame(stringsAsFactors = FALSE)
colnames(skills) <- c("skillUri", "reuseLevel", "preferred_skillLabel")

# Combine the relations with the skills information
full_set <- left_join(occupations_skills, skills, by=c("skillUri"))

# Import occupations info
occupations <- read.csv(paste0(esco_108, "/occupations_en.csv"))
occupations <- cbind(occupations$conceptUri, 
                     occupations$preferredLabel,
                     occupations$code) %>% data.frame(stringsAsFactors = FALSE)
colnames(occupations) <- c("occupationUri", "occupationDesc", "occupationCode")

# Add the information on occupations
full_set <- left_join(full_set, occupations, by="occupationUri")
full_set$isco08 <- str_sub(full_set$occupationCode, 1, 4)

# Import skills hierarchy
skills <- read.csv(paste0(esco_108, "/broaderRelationsSkillPillar.csv"))
skills <- skills[skills$broaderType=="SkillGroup", ]

skills$conceptType <- NULL
skills$broaderType <- NULL
colnames(skills) <- c("skillUri", "broaderSkillUri")
skills <- skills[str_length(skills$broaderSkillUri)<50, ]

# Add the information on skills hierarchy
full_set <- left_join(full_set, skills, by="skillUri")

# Derive skill group codes of different levels
full_set$skill_group_3 <- str_sub(full_set$broaderSkillUri,start = str_locate(full_set$broaderSkillUri, "skill/")[, 2]+1)
full_set$skill_group_2 <- str_sub(full_set$skill_group_3, 1, str_length(full_set$skill_group_3)-2)
full_set$skill_group_1 <- str_sub(full_set$skill_group_3, 1, 2)

###################################
# Group tasks by broad categories #
###################################

# For category definitions see Matysiak et al. (2024)

# Social Outward (as in Matysiak et al., 2024)
full_set$tasks_social_outward <- (
  (full_set$skill_group_3=="S1.1.0" | 
     full_set$skill_group_3=="S1.1.2" | 
     full_set$skill_group_3=="S1.1.3" | 
     full_set$skill_group_2=="S1.0" | 
     full_set$skill_group_2=="S1.3" | 
     full_set$skill_group_3=="S1.4.1" | 
     full_set$skill_group_3=="S1.4.3" | 
     full_set$skill_group_2=="S1.5" | 
     full_set$skill_group_2=="S1.6" | 
     full_set$skill_group_2=="S1.7" | 
     full_set$skill_group_3=="S1.2.4" | 
     full_set$skill_group_2=="S3.0" | 
     full_set$skill_group_2=="S3.1" | 
     full_set$skill_group_2=="S3.4" | 
     full_set$skill_group_3=="S3.6.0" | 
     full_set$skill_group_3=="S3.6.2" | 
     full_set$skill_group_3=="S3.6.3" | 
     full_set$skill_group_3=="A1.12.3" | 
     full_set$skill_group_2=="A2.1" | 
     full_set$skill_group_2=="A2.2" | 
     grepl("obtain concert funding", full_set$preferred_skillLabel) | 
     grepl("communicate with a non-scientific audience", full_set$preferred_skillLabel) | 
     grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) | 
     grepl("speak about your work in public", full_set$preferred_skillLabel) | 
     grepl("apply technical communication skills", full_set$preferred_skillLabel) | 
     grepl("work with different target groups", full_set$preferred_skillLabel) | 
     grepl("work with healthcare users under medication", full_set$preferred_skillLabel) | 
     grepl("build rapport with people from different cultural backgrounds", full_set$preferred_skillLabel) | 
     grepl("work in a multicultural environment in fishery", full_set$preferred_skillLabel) | 
     grepl("establish communication with foreign cultures", full_set$preferred_skillLabel) | 
     grepl("inform drivers of detour routes", full_set$preferred_skillLabel) | 
     grepl("communicate verbal instructions", full_set$preferred_skillLabel) | 
     grepl("reinforce positive behaviour", full_set$preferred_skillLabel) | 
     grepl("give constructive feedback", full_set$preferred_skillLabel) | 
     grepl("provide feedback on patient's communication style", full_set$preferred_skillLabel) | 
     grepl("build helping relationship with social service users", full_set$preferred_skillLabel) | 
     grepl("develop a collaborative therapeutic relationship", full_set$preferred_skillLabel) | 
     grepl("develop therapeutic relationships", full_set$preferred_skillLabel) | 
     grepl("establish customer rapport", full_set$preferred_skillLabel) | 
     grepl("establish relationship with the media", full_set$preferred_skillLabel) | 
     grepl("improve customer interaction", full_set$preferred_skillLabel) | 
     grepl("maintain the trust of service users", full_set$preferred_skillLabel) | 
     grepl("manage psychotherapeutic relationships", full_set$preferred_skillLabel) | 
     grepl("manage student relationships", full_set$preferred_skillLabel) | 
     grepl("represent the organization", full_set$preferred_skillLabel) | 
     grepl("engage local communities in the management of natural protected areas", full_set$preferred_skillLabel) | 
     grepl("prospect new customers", full_set$preferred_skillLabel) | 
     grepl("maintain relationship with customers", full_set$preferred_skillLabel) | 
     grepl("maintain relations with local representatives", full_set$preferred_skillLabel) | 
     grepl("represent the company", full_set$preferred_skillLabel) | 
     grepl("book cargo", full_set$preferred_skillLabel) | 
     grepl("communicate in specialized nursing care", full_set$preferred_skillLabel) | 
     grepl("communicate in healthcare", full_set$preferred_skillLabel) | 
     grepl("communicate with beneficiaries", full_set$preferred_skillLabel) | 
     grepl("communicate with elderly groups", full_set$preferred_skillLabel) | 
     grepl("communicate with local residents", full_set$preferred_skillLabel) | 
     grepl("communicate with media", full_set$preferred_skillLabel) | 
     grepl("communicate with social service users", full_set$preferred_skillLabel) | 
     grepl("communicate with tenants", full_set$preferred_skillLabel) | 
     grepl("consult with business clients", full_set$preferred_skillLabel) | 
     grepl("manage animal adoption", full_set$preferred_skillLabel) | 
     grepl("organise entry to attractions", full_set$preferred_skillLabel) | 
     grepl("organise group music therapy sessions", full_set$preferred_skillLabel) | 
     grepl("perform dunning activities", full_set$preferred_skillLabel) | 
     grepl("maintain relations with children's parents", full_set$preferred_skillLabel) | 
     grepl("deliver social services in diverse cultural communities", full_set$preferred_skillLabel) | 
     grepl("communicate technicalities with clients", full_set$preferred_skillLabel) | 
     grepl("communicate clearly with passengers", full_set$preferred_skillLabel) | 
     grepl("communicate with park visitors", full_set$preferred_skillLabel) | 
     grepl("contact customers", full_set$preferred_skillLabel) | 
     grepl("communicate by telephone", full_set$preferred_skillLabel) | 
     grepl("initiate contact with sellers", full_set$preferred_skillLabel) | 
     grepl("support sport in media", full_set$preferred_skillLabel) | 
     grepl("work with healthcare users' social network", full_set$preferred_skillLabel) | 
     grepl("communicate with target community", full_set$preferred_skillLabel) | 
     grepl("collaborate with stakeholders in leading community arts", full_set$preferred_skillLabel) | 
     grepl("operate in a specific field of nursing care", full_set$preferred_skillLabel) | 
     grepl("respond to healthcare users' extreme emotions", full_set$preferred_skillLabel) | 
     grepl("apply nursing care in long-term care", full_set$preferred_skillLabel) | 
     grepl("handle patient trauma", full_set$preferred_skillLabel) | 
     grepl("provide care for the mother during labour", full_set$preferred_skillLabel) | 
     grepl("provide professional care in nursing", full_set$preferred_skillLabel) | 
     grepl("provide specialist pharmaceutical care", full_set$preferred_skillLabel) | 
     grepl("detect drug abuse", full_set$preferred_skillLabel) | 
     grepl("answer emergency calls", full_set$preferred_skillLabel) | 
     grepl("control crowd", full_set$preferred_skillLabel) | 
     grepl("deal with aggressive behaviour", full_set$preferred_skillLabel) | 
     grepl("deal with challenging people", full_set$preferred_skillLabel) | 
     grepl("evacuate people from buildings", full_set$preferred_skillLabel) | 
     grepl("help to control passenger behaviour during emergency situations", full_set$preferred_skillLabel) | 
     grepl("maintain order at scenes of accidents", full_set$preferred_skillLabel) | 
     grepl("implement fundamentals of nursing", full_set$preferred_skillLabel) | 
     grepl("implement nursing care", full_set$preferred_skillLabel) | 
     grepl("work within communities", full_set$preferred_skillLabel) | 
     grepl("assist in the administration of medication to elderly", full_set$preferred_skillLabel) | 
     grepl("assist on pregnancy abnormality", full_set$preferred_skillLabel) | 
     grepl("assist patients with rehabilitation", full_set$preferred_skillLabel) | 
     grepl("assist passengers in emergency situations", full_set$preferred_skillLabel) | 
     grepl("assist people in contaminated areas", full_set$preferred_skillLabel)) & 
    !grepl("chair a meeting", full_set$preferred_skillLabel) & 
    !grepl("present storyboard", full_set$preferred_skillLabel) & 
    !grepl("brief staff on daily menu", full_set$preferred_skillLabel) & 
    !grepl("increase the impact of science on policy and society", full_set$preferred_skillLabel) & 
    !grepl("apply quality standards in social services", full_set$preferred_skillLabel) & 
    !grepl("apply quality standards in youth services", full_set$preferred_skillLabel) & 
    !grepl("provide protective equipment against infectious diseases", full_set$preferred_skillLabel) & 
    !grepl("describe your artistic aspirations in relation to artistic trend", full_set$preferred_skillLabel) & 
    !grepl("apply frequency management", full_set$preferred_skillLabel) & 
    !grepl("buy groceries", full_set$preferred_skillLabel) &
    !grepl("communicate problems to senior colleagues", full_set$preferred_skillLabel) & 
    !grepl("confer with event staff", full_set$preferred_skillLabel) & 
    !grepl("consult with sound editor", full_set$preferred_skillLabel) & 
    !grepl("consult with technical staff", full_set$preferred_skillLabel) & 
    !grepl("identify performers' needs", full_set$preferred_skillLabel) & 
    !grepl("confer with library colleagues", full_set$preferred_skillLabel) & 
    !grepl("participate as a performer in the creative process", full_set$preferred_skillLabel) & 
    !grepl("listen actively to sport players", full_set$preferred_skillLabel) 
)

# Social Inward (as in Matysiak et al., 2024)
full_set$tasks_social_inward <- (
  (full_set$skill_group_3=="S1.1.1" |  
     full_set$skill_group_3=="S1.2.1" | 
     full_set$skill_group_3=="S1.2.3" | 
     full_set$skill_group_3=="S1.4.2" | 
     full_set$skill_group_2=="S1.8" | 
     full_set$skill_group_2=="S4.5" | 
     full_set$skill_group_3=="S4.8.1" | 
     grepl("chair a meeting", full_set$preferred_skillLabel) | 
     grepl("present storyboard", full_set$preferred_skillLabel) | 
     grepl("brief staff on daily menu", full_set$preferred_skillLabel) |
     grepl("increase the impact of science on policy and society", full_set$preferred_skillLabel) | 
     grepl("coordinate security", full_set$preferred_skillLabel) | 
     grepl("network within the writing industry", full_set$preferred_skillLabel) | 
     grepl("share good practices across subsidiaries", full_set$preferred_skillLabel) | 
     grepl("maintain relationships with doctors", full_set$preferred_skillLabel) | 
     grepl("involve volunteers", full_set$preferred_skillLabel) | 
     grepl("manage volunteers in second-hand shop", full_set$preferred_skillLabel) | 
     grepl("manage agricultural staff", full_set$preferred_skillLabel) | 
     grepl("manage chiropractic staff", full_set$preferred_skillLabel) | 
     grepl("manage human resources", full_set$preferred_skillLabel) | 
     grepl("instruct kitchen personnel", full_set$preferred_skillLabel) | 
     grepl("manage physiotherapy staff", full_set$preferred_skillLabel) | 
     grepl("communicate problems to senior colleagues", full_set$preferred_skillLabel) | 
     grepl("confer with event staff", full_set$preferred_skillLabel) | 
     grepl("consult with sound editor", full_set$preferred_skillLabel) | 
     grepl("consult with technical staff", full_set$preferred_skillLabel) | 
     grepl("identify performers' needs", full_set$preferred_skillLabel) | 
     grepl("confer with library colleagues", full_set$preferred_skillLabel) | 
     grepl("participate as a performer in the creative process", full_set$preferred_skillLabel) | 
     grepl("listen actively to sport players", full_set$preferred_skillLabel)) & 
    !grepl("perform lectures", full_set$preferred_skillLabel) & 
    !grepl("circulate information", full_set$preferred_skillLabel) & 
    !grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) & 
    !grepl("deliver visual presentation of data", full_set$preferred_skillLabel) & 
    !grepl("apply frequency management", full_set$preferred_skillLabel) & 
    !grepl("ensure compliance with warranty contracts", full_set$preferred_skillLabel) & 
    !grepl("book cargo", full_set$preferred_skillLabel) & 
    !grepl("communicate in specialized nursing care", full_set$preferred_skillLabel) & 
    !grepl("communicate in healthcare", full_set$preferred_skillLabel) & 
    !grepl("communicate with beneficiaries", full_set$preferred_skillLabel) & 
    !grepl("communicate with elderly groups", full_set$preferred_skillLabel) & 
    !grepl("communicate with local residents", full_set$preferred_skillLabel) & 
    !grepl("communicate with media", full_set$preferred_skillLabel) & 
    !grepl("communicate with social service users", full_set$preferred_skillLabel) & 
    !grepl("communicate with tenants", full_set$preferred_skillLabel) & 
    !grepl("consult with business clients", full_set$preferred_skillLabel) & 
    !grepl("manage animal adoption", full_set$preferred_skillLabel) & 
    !grepl("organise entry to attractions", full_set$preferred_skillLabel) & 
    !grepl("organise group music therapy sessions", full_set$preferred_skillLabel) & 
    !grepl("perform dunning activities", full_set$preferred_skillLabel) & 
    !grepl("maintain relations with children's parents", full_set$preferred_skillLabel) & 
    !grepl("deliver social services in diverse cultural communities", full_set$preferred_skillLabel) & 
    !grepl("communicate technicalities with clients", full_set$preferred_skillLabel) & 
    !grepl("communicate clearly with passengers", full_set$preferred_skillLabel) & 
    !grepl("communicate with park visitors", full_set$preferred_skillLabel) & 
    !grepl("contact customers", full_set$preferred_skillLabel) &
    !grepl("build helping relationship with social service users", full_set$preferred_skillLabel) & 
    !grepl("develop a collaborative therapeutic relationship", full_set$preferred_skillLabel) & 
    !grepl("develop therapeutic relationships", full_set$preferred_skillLabel) & 
    !grepl("establish customer rapport", full_set$preferred_skillLabel) & 
    !grepl("establish relationship with the media", full_set$preferred_skillLabel) & 
    !grepl("improve customer interaction", full_set$preferred_skillLabel) & 
    !grepl("maintain the trust of service users", full_set$preferred_skillLabel) & 
    !grepl("manage psychotherapeutic relationships", full_set$preferred_skillLabel) & 
    !grepl("manage student relationships", full_set$preferred_skillLabel) & 
    !grepl("represent the organization", full_set$preferred_skillLabel) & 
    !grepl("engage local communities in the management of natural protected areas", full_set$preferred_skillLabel) & 
    !grepl("prospect new customers", full_set$preferred_skillLabel) & 
    !grepl("maintain relationship with customers", full_set$preferred_skillLabel) & 
    !grepl("maintain relations with local representatives", full_set$preferred_skillLabel) & 
    !grepl("represent the company", full_set$preferred_skillLabel) &
    !grepl("work with different target groups", full_set$preferred_skillLabel) & 
    !grepl("work with healthcare users under medication", full_set$preferred_skillLabel) & 
    !grepl("build rapport with people from different cultural backgrounds", full_set$preferred_skillLabel) & 
    !grepl("work in a multicultural environment in fishery", full_set$preferred_skillLabel) & 
    !grepl("establish communication with foreign cultures", full_set$preferred_skillLabel) & 
    !grepl("inform drivers of detour routes", full_set$preferred_skillLabel) & 
    !grepl("communicate verbal instructions", full_set$preferred_skillLabel) & 
    !grepl("reinforce positive behaviour", full_set$preferred_skillLabel) & 
    !grepl("give constructive feedback", full_set$preferred_skillLabel) & 
    !grepl("provide feedback on patient's communication style", full_set$preferred_skillLabel) &
    !grepl("communicate with a non-scientific audience", full_set$preferred_skillLabel) & 
    !grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) & 
    !grepl("speak about your work in public", full_set$preferred_skillLabel) & 
    !grepl("apply technical communication skills", full_set$preferred_skillLabel) &
    full_set$skill_group_3!="S1.8.5"
)

# Social (all) (as in Matysiak et al., 2024)
full_set$tasks_social <- (full_set$tasks_social_outward | 
                            full_set$tasks_social_inward | 
                            grepl("use internet chat", full_set$preferred_skillLabel) | 
                            grepl("relay messages through radio and telephone systems", full_set$preferred_skillLabel) | 
                            grepl("perform lectures", full_set$preferred_skillLabel) |
                            grepl("circulate information", full_set$preferred_skillLabel) |
                            grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) |
                            grepl("deliver visual presentation of data", full_set$preferred_skillLabel) | 
                            full_set$skill_group_3=="S1.4.0"
                          )

# Technical (subcomponent of Analytical in Matysiak et al., 2024)
full_set$tasks_technical <- (
   (full_set$skill_group_2=="S2.0" | 
    full_set$skill_group_2=="S2.1" | 
    full_set$skill_group_2=="S2.3" | 
    full_set$skill_group_2=="S2.4" | 
    full_set$skill_group_2=="S2.6" | 
    full_set$skill_group_2=="S2.7" | 
    full_set$skill_group_2=="S2.8" | 
    full_set$skill_group_2=="S2.9" | 
    full_set$skill_group_2=="S5.0" | 
    full_set$skill_group_2=="S5.1" | 
    full_set$skill_group_2=="S5.2" | 
    full_set$skill_group_2=="S5.5" | 
    full_set$skill_group_2=="S5.6" | 
    full_set$skill_group_2=="S1.11" | 
    full_set$skill_group_3=="S4.3.0" | 
    full_set$skill_group_3=="S3.2.4" | 
    full_set$skill_group_3=="S4.3.2" | 
    grepl("perform currency reserve management", full_set$preferred_skillLabel) | 
    grepl("perform financial market business", full_set$preferred_skillLabel) | 
    grepl("apply for external funding for physical activity", full_set$preferred_skillLabel) | 
    grepl("manage operational budgets", full_set$preferred_skillLabel) | 
    grepl("recognise patients' reaction to therapy", full_set$preferred_skillLabel) | 
    grepl("provide pre-natal care", full_set$preferred_skillLabel) | 
    grepl("develop patient treatment strategie", full_set$preferred_skillLabel) | 
    grepl("perform orthopaedic examination", full_set$preferred_skillLabel) | 
    grepl("correct potentially harmful movement", full_set$preferred_skillLabel) | 
    grepl("cover a variety of health condition", full_set$preferred_skillLabel) | 
    grepl("develop chiropractic treatment plan", full_set$preferred_skillLabel) | 
    grepl("develop osteopathic treatment plan", full_set$preferred_skillLabel) | 
    grepl("perform pathology consultations", full_set$preferred_skillLabel) | 
    grepl("adapt hearing test", full_set$preferred_skillLabel) | 
    grepl("determine imaging techniques to be performe", full_set$preferred_skillLabel) | 
    grepl("develop long-term treatment course for disorders in the glandular syste", full_set$preferred_skillLabel) | 
    grepl("develop personalised massage pla", full_set$preferred_skillLabel) | 
    grepl("formulate a treatment pla", full_set$preferred_skillLabel) | 
    grepl("make referrals to ophthalmolog", full_set$preferred_skillLabel) | 
    grepl("perform on-treatment revie", full_set$preferred_skillLabel) |
    grepl("prescribe advanced nursing car", full_set$preferred_skillLabel) | 
    grepl("prescribe corrective lense", full_set$preferred_skillLabel) | 
    grepl("prescribe exercise", full_set$preferred_skillLabel) | 
    grepl("prescribe exercises for controlled health condition", full_set$preferred_skillLabel) | 
    grepl("prescribe healthcare product", full_set$preferred_skillLabel) | 
    grepl("prescribe medicatio", full_set$preferred_skillLabel) | 
    grepl("prescribe psychotherapeutic treatmen", full_set$preferred_skillLabel) | 
    grepl("prescribe tests for physiotherap", full_set$preferred_skillLabel) | 
    grepl("prescribe topical therap", full_set$preferred_skillLabel) | 
    grepl("prescribe treatment for musculoskeletal injurie", full_set$preferred_skillLabel) | 
    grepl("forecast products' demand", full_set$preferred_skillLabel) | 
    grepl("forecast timber production", full_set$preferred_skillLabel) | 
    grepl("budget for financial needs", full_set$preferred_skillLabel) |
    grepl("create annual marketing budget", full_set$preferred_skillLabel) |
    grepl("evaluate budgets", full_set$preferred_skillLabel) |
    grepl("exert expenditure control", full_set$preferred_skillLabel) |
    grepl("follow up awarded grants", full_set$preferred_skillLabel) |
    grepl("forecast dividend trends", full_set$preferred_skillLabel) |
    grepl("handle quotes from prospective shippers", full_set$preferred_skillLabel) |
    grepl("identify financial resources", full_set$preferred_skillLabel) |
    grepl("manage a healthcare unit budget", full_set$preferred_skillLabel) |
    grepl("perform forensic accounting", full_set$preferred_skillLabel) |
    grepl("manage brand assets", full_set$preferred_skillLabel) |
    grepl("manage budgets", full_set$preferred_skillLabel) |
    grepl("manage school budget", full_set$preferred_skillLabel) |
    grepl("update budget", full_set$preferred_skillLabel) |
    grepl("manage budgets for social services programs", full_set$preferred_skillLabel) |
    grepl("manage financial aspects of a company", full_set$preferred_skillLabel) |
    grepl("manage hospitality revenue", full_set$preferred_skillLabel) |
    grepl("advise on loans of art work for exhibitions", full_set$preferred_skillLabel) |
    grepl("select loan objects", full_set$preferred_skillLabel) |
    grepl("manage personal finances", full_set$preferred_skillLabel) |
    grepl("manage securities", full_set$preferred_skillLabel) |
    grepl("manage sport facility finances", full_set$preferred_skillLabel) |
    grepl("optimise financial performance", full_set$preferred_skillLabel) |
    grepl("perform asset recognition", full_set$preferred_skillLabel) |
    grepl("perform cost accounting activities", full_set$preferred_skillLabel) |
    grepl("contribute to quality physiotherapy services", full_set$preferred_skillLabel) |
    grepl("prepare audit activities", full_set$preferred_skillLabel) |
    grepl("prepare audit schemes for ships", full_set$preferred_skillLabel) |
    grepl("understand budgetary limits"  , full_set$preferred_skillLabel) |
    grepl("prescribe treatments related to surgical procedure", full_set$preferred_skillLabel) ) & 
    !grepl("analyse the artistic concept based on stage actions", full_set$preferred_skillLabel) & 
    !grepl("identify innovative concepts in packaging", full_set$preferred_skillLabel) & 
    !grepl("create innovative desserts", full_set$preferred_skillLabel) & 
    !grepl("seek innovation in current practices", full_set$preferred_skillLabel) & 
    !grepl("think creatively about food and beverages", full_set$preferred_skillLabel) & 
    !grepl("think creatively about jewellery", full_set$preferred_skillLabel) & 
    !grepl("plan new packaging design", full_set$preferred_skillLabel) & 
    !grepl("involve volunteers", full_set$preferred_skillLabel) & 
    !grepl("manage volunteers in second-hand shop", full_set$preferred_skillLabel) & 
    !grepl("manage agricultural staff", full_set$preferred_skillLabel) & 
    !grepl("manage chiropractic staff", full_set$preferred_skillLabel) & 
    !grepl("manage human resources", full_set$preferred_skillLabel) & 
    !grepl("instruct kitchen personnel", full_set$preferred_skillLabel) & 
    !grepl("manage physiotherapy staff", full_set$preferred_skillLabel) & 
    !grepl("manage the use of additives in food manufacturing", full_set$preferred_skillLabel) & 
    !grepl("staff game shifts", full_set$preferred_skillLabel) & 
    !grepl("schedule shifts", full_set$preferred_skillLabel) & 
    !grepl("position musicians", full_set$preferred_skillLabel)
)
  
# Artistic / Creative (subcomponent of Analytical in Matysiak et al., 2024)
full_set$tasks_artistic_creative <- (
    full_set$skill_group_2=="S1.9" | 
    full_set$skill_group_2=="S1.12" | 
    full_set$skill_group_2=="S1.13" | 
    full_set$skill_group_2=="S1.14" | 
    grepl("think creative", full_set$preferred_skillLabel) | 
    grepl("create concept of digital gam", full_set$preferred_skillLabel) | 
    grepl("create musical form", full_set$preferred_skillLabel) | 
    grepl("define artistic approac", full_set$preferred_skillLabel) | 
    grepl("develop creative idea", full_set$preferred_skillLabel) | 
    grepl("identify innovative concepts in packagin", full_set$preferred_skillLabel) | 
    grepl("plan new packaging design", full_set$preferred_skillLabel) | 
    grepl("practice innovative thinking in the footwear and leather goods industrie", full_set$preferred_skillLabel) | 
    grepl("seek innovation in current practice", full_set$preferred_skillLabel) | 
    grepl("stimulate creative processe", full_set$preferred_skillLabel) | 
    grepl("stimulate creativity in the tea", full_set$preferred_skillLabel) | 
    grepl("think creatively about food and beverage", full_set$preferred_skillLabel) | 
    grepl("think creatively about jeweller", full_set$preferred_skillLabel) | 
    grepl("write musical score", full_set$preferred_skillLabel) | 
    grepl("formulate game rule", full_set$preferred_skillLabel) | 
    grepl("define an approach to your fight diciplin", full_set$preferred_skillLabel) | 
    grepl("describe your artistic aspirations in relation to artistic trend", full_set$preferred_skillLabel) | 
    grepl("develop an artistic approach to your interpretatio", full_set$preferred_skillLabel) | 
    grepl("analyse the artistic concept based on stage action", full_set$preferred_skillLabel) | 
    grepl("develop musical idea", full_set$preferred_skillLabel) | 
    grepl("develop program idea", full_set$preferred_skillLabel) | 
    grepl("transcribe ideas into musical notatio", full_set$preferred_skillLabel) | 
    grepl("create innovative dessert", full_set$preferred_skillLabel) | 
    grepl("innovate in IC", full_set$preferred_skillLabel) | 
    grepl("practice innovative thinking in the footwear and leather goods industrie", full_set$preferred_skillLabel) | 
    grepl("complete final musical score", full_set$preferred_skillLabel) | 
    grepl("create musical form", full_set$preferred_skillLabel) | 
    grepl("rewrite musical score", full_set$preferred_skillLabel) | 
    grepl("position musicians", full_set$preferred_skillLabel)
)

# Routine (subcomponent of final Routine measure in Matysiak et al., 2024)
full_set$tasks_routine <- (
  (full_set$skill_group_3=="A1.13.0" | 
    full_set$skill_group_3=="A1.13.1" | 
    full_set$skill_group_3=="A1.13.3" | 
    full_set$skill_group_3=="S1.8.5" | 
    full_set$skill_group_2=="S2.2" | 
    full_set$skill_group_2=="S2.5" | 
    full_set$skill_group_2=="S4.4" | 
    full_set$skill_group_3=="S3.3.1" | 
    full_set$skill_group_3=="S3.3.2" | 
    full_set$skill_group_3=="S3.3.3" | 
    full_set$skill_group_3=="S3.3.4"  | 
    full_set$skill_group_3=="S4.3.3"  | 
    grepl("apply quality standards in social services", full_set$preferred_skillLabel) | 
    grepl("apply quality standards in youth services", full_set$preferred_skillLabel) | 
    grepl("provide protective equipment against infectious diseases", full_set$preferred_skillLabel) | 
    grepl("ensure compliance with warranty contracts", full_set$preferred_skillLabel) | 
    grepl("budget set costs", full_set$preferred_skillLabel) | 
    grepl("complete administration", full_set$preferred_skillLabel) | 
    grepl("control financial resources", full_set$preferred_skillLabel) | 
    grepl("manage vehicle services' financial resources", full_set$preferred_skillLabel) | 
    grepl("enforce financial policies", full_set$preferred_skillLabel) | 
    grepl("examine budgets", full_set$preferred_skillLabel) | 
    grepl("establish investment funds", full_set$preferred_skillLabel) | 
    grepl("give out grants", full_set$preferred_skillLabel) | 
    grepl("handle external financing", full_set$preferred_skillLabel) | 
    grepl("keep track of shipment payments", full_set$preferred_skillLabel) | 
    grepl("maintain trusts", full_set$preferred_skillLabel) | 
    grepl("manage accounts", full_set$preferred_skillLabel) | 
    grepl("check accounting records", full_set$preferred_skillLabel) | 
    grepl("ensure compliance with accounting conventions", full_set$preferred_skillLabel) | 
    grepl("manage bank vault", full_set$preferred_skillLabel) | 
    grepl("oversee the facilities services budget", full_set$preferred_skillLabel) | 
    grepl("manage corporate bank accounts", full_set$preferred_skillLabel) | 
    grepl("create banking accounts", full_set$preferred_skillLabel) | 
    grepl("manage government funding", full_set$preferred_skillLabel) | 
    grepl("manage profitability", full_set$preferred_skillLabel) | 
    grepl("manage loans", full_set$preferred_skillLabel) | 
    grepl("determine loan conditions", full_set$preferred_skillLabel) | 
    grepl("manage loan administration", full_set$preferred_skillLabel) | 
    grepl("manage loan applications", full_set$preferred_skillLabel) | 
    grepl("manage pension funds", full_set$preferred_skillLabel) | 
    grepl("manage recycling program budget", full_set$preferred_skillLabel) | 
    grepl("manage revenue", full_set$preferred_skillLabel) | 
    grepl("minimise shipping cost", full_set$preferred_skillLabel) | 
    grepl("perform balance sheet operations", full_set$preferred_skillLabel) |
    grepl("prepare intravenous pack", full_set$preferred_skillLabel) | 
    grepl("prepare medication from prescriptio", full_set$preferred_skillLabel) | 
    grepl("prepare radiopharmaceutical", full_set$preferred_skillLabel) | 
    grepl("prepare airport annual budget", full_set$preferred_skillLabel) | 
    grepl("audit HACCP", full_set$preferred_skillLabel) | 
    grepl("assess HACCP implementation in plants", full_set$preferred_skillLabel) | 
    grepl("perform HACCP inspections for aquatic organisms", full_set$preferred_skillLabel) | 
    grepl("implement the airside safety auditing system", full_set$preferred_skillLabel) | 
    grepl("implement airside vehicle control provisions", full_set$preferred_skillLabel) | 
    grepl("participate in medical records' auditing activities", full_set$preferred_skillLabel) | 
    grepl("prepare financial auditing reports", full_set$preferred_skillLabel) | 
    grepl("prepare casting budget", full_set$preferred_skillLabel) | 
    grepl("support development of annual budget", full_set$preferred_skillLabel) | 
    grepl("use accounting systems", full_set$preferred_skillLabel) | 
    grepl("manage the use of additives in food manufacturing", full_set$preferred_skillLabel) | 
    grepl("tune instruments on stage", full_set$preferred_skillLabel) | 
    grepl("staff game shifts", full_set$preferred_skillLabel) | 
    grepl("schedule shifts"  , full_set$preferred_skillLabel) ) & 
    !grepl("forecast products' demand", full_set$preferred_skillLabel) &
    !grepl("forecast timber production", full_set$preferred_skillLabel) &
    !grepl("prepare fishing equipment", full_set$preferred_skillLabel) &
    !grepl("prepare instruments for performance", full_set$preferred_skillLabel) &
    !grepl("prepare personal work environment", full_set$preferred_skillLabel) &
    !grepl("prepare the floor for performance", full_set$preferred_skillLabel) &
    !grepl("supply rigging equipment", full_set$preferred_skillLabel) &
    !grepl("restock towels", full_set$preferred_skillLabel) &
    !grepl("rehearse artist fly movements", full_set$preferred_skillLabel) &
    !grepl("practise flying movements" , full_set$preferred_skillLabel) 
  )

# Non-routine (subcomponent of final Routine measure in Matysiak et al., 2024)
full_set$tasks_nonroutine <- (
  (full_set$skill_group_2=="S4.0" | 
    full_set$skill_group_2=="S4.1" | 
    full_set$skill_group_2=="S4.2" | 
    full_set$skill_group_2=="S4.6" | 
    full_set$skill_group_3=="S4.8.2" | 
    full_set$skill_group_3=="S4.8.3" | 
    full_set$skill_group_2=="S4.9" | 
    full_set$skill_group_2=="A1.1" | 
    full_set$skill_group_2=="A1.5" | 
    full_set$skill_group_2=="A1.16" | 
    full_set$skill_group_2=="A1.8" | 
    full_set$skill_group_2=="A1.6" | 
    full_set$skill_group_3=="A1.13.2" ) & 
    !grepl("work within communities", full_set$preferred_skillLabel))

# Manual (as in Matysiak et al., 2024)
full_set$tasks_manual <- (
  full_set$skill_group_2=="S6.0" | 
    full_set$skill_group_2=="S6.1" | 
    full_set$skill_group_2=="S6.2" | 
    full_set$skill_group_2=="S6.3" | 
    full_set$skill_group_2=="S6.4" | 
    full_set$skill_group_2=="S6.5" | 
    full_set$skill_group_2=="S6.6" | 
    full_set$skill_group_2=="S6.7" | 
    full_set$skill_group_2=="S6.8" | 
    full_set$skill_group_2=="S6.9" | 
    full_set$skill_group_2=="S6.11" | 
    full_set$skill_group_2=="S6.12" | 
    full_set$skill_group_2=="S6.13" | 
    full_set$skill_group_2=="S7.0" | 
    full_set$skill_group_2=="S7.1" | 
    full_set$skill_group_2=="S7.2" | 
    full_set$skill_group_2=="S7.3" | 
    full_set$skill_group_2=="S8.0" | 
    full_set$skill_group_2=="S8.1" | 
    full_set$skill_group_2=="S8.2" | 
    full_set$skill_group_2=="S8.3" | 
    full_set$skill_group_2=="S8.4" | 
    full_set$skill_group_2=="S8.5" | 
    full_set$skill_group_2=="S8.6" | 
    full_set$skill_group_2=="S8.7" | 
    full_set$skill_group_2=="S8.8" | 
    full_set$skill_group_2=="S8.9" | 
    full_set$skill_group_3=="S3.5.0" | 
    full_set$skill_group_3=="S3.5.1" | 
    full_set$skill_group_3=="S3.5.2" | 
    full_set$skill_group_3=="S3.6.1" | 
    full_set$skill_group_3=="S3.6.4" |
    grepl("restrain individual", full_set$preferred_skillLabel) | 
    grepl("immobilise patients for emergency interventio", full_set$preferred_skillLabel) | 
    grepl("adjust feeder tube", full_set$preferred_skillLabel) | 
    grepl("clean patients' ear canal", full_set$preferred_skillLabel) | 
    grepl("embalm bodie", full_set$preferred_skillLabel) | 
    grepl("perform body wrappin", full_set$preferred_skillLabel) | 
    grepl("provide stabilisation care in emergency", full_set$preferred_skillLabel) | 
    grepl("apply deep tissue massag", full_set$preferred_skillLabel) | 
    grepl("apply massage therap", full_set$preferred_skillLabel) | 
    grepl("apply sports massag", full_set$preferred_skillLabel) | 
    grepl("conduct pregnancy massage", full_set$preferred_skillLabel) | 
    grepl("perform shiatsu massage", full_set$preferred_skillLabel) | 
    grepl("evacuate people from flooded areas", full_set$preferred_skillLabel) | 
    grepl("apply self-defenc", full_set$preferred_skillLabel) | 
    grepl("conduct fris", full_set$preferred_skillLabel) | 
    grepl("contain fire", full_set$preferred_skillLabel) | 
    grepl("disarm land min", full_set$preferred_skillLabel) | 
    grepl("extinguish fire", full_set$preferred_skillLabel) | 
    grepl("handle fragile item", full_set$preferred_skillLabel) | 
    grepl("handle surveillance equipmen", full_set$preferred_skillLabel) | 
    grepl("patrol area", full_set$preferred_skillLabel) | 
    grepl("perform body searche", full_set$preferred_skillLabel) | 
    grepl("perform first fire interventio", full_set$preferred_skillLabel) | 
    grepl("perform military operation", full_set$preferred_skillLabel) | 
    grepl("perform playground surveillanc", full_set$preferred_skillLabel) | 
    grepl("perform search and rescue mission", full_set$preferred_skillLabel) | 
    grepl("provide door securit", full_set$preferred_skillLabel) | 
    grepl("provide protective escor", full_set$preferred_skillLabel) | 
    grepl("provide secured transportatio", full_set$preferred_skillLabel) | 
    grepl("provide security in detention centre", full_set$preferred_skillLabel) | 
    grepl("rescue bather", full_set$preferred_skillLabel) | 
    grepl("restrain individual", full_set$preferred_skillLabel) | 
    grepl("use different types of fire extinguisher", full_set$preferred_skillLabel) | 
    grepl("use firearm", full_set$preferred_skillLabel) | 
    grepl("buy groceries", full_set$preferred_skillLabel) |
    grepl("prepare fishing equipment", full_set$preferred_skillLabel) |
    grepl("prepare instruments for performance", full_set$preferred_skillLabel) |
    grepl("prepare personal work environment", full_set$preferred_skillLabel) |
    grepl("prepare the floor for performance", full_set$preferred_skillLabel) |
    grepl("supply rigging equipment", full_set$preferred_skillLabel) |
    grepl("restock towels", full_set$preferred_skillLabel) |
    grepl("rehearse artist fly movements", full_set$preferred_skillLabel) |
    grepl("practise flying movements" , full_set$preferred_skillLabel) | 
    grepl("assist the dentist during the dental treatment procedure", full_set$preferred_skillLabel) | 
    grepl("assist with hemostasis", full_set$preferred_skillLabel) | 
    grepl("assist in maritime rescue operations", full_set$preferred_skillLabel) | 
    grepl("assist with reconstructing the body after autopsy", full_set$preferred_skillLabel) | 
    grepl("assist with vaccination procedures", full_set$preferred_skillLabel)
)

# Analytical (as in Matysiak et al., 2024)
full_set$tasks_analytical <- (full_set$tasks_artistic_creative | full_set$tasks_technical)

# Social Outward (care-focus variant) (robustness check definition for Matysiak et al., 2024)
full_set$tasks_social_care <- (
  (  full_set$skill_group_2=="S3.0" | 
       full_set$skill_group_2=="S3.1" | 
       full_set$skill_group_3=="S3.4.2" | 
       full_set$skill_group_3=="S3.4.4" | 
       full_set$skill_group_3=="S3.6.0" | 
       full_set$skill_group_3=="S3.6.2" | 
       full_set$skill_group_3=="S3.6.3" | 
       grepl("operate in a specific field of nursing care", full_set$preferred_skillLabel) | 
       grepl("respond to healthcare users' extreme emotions", full_set$preferred_skillLabel) | 
       grepl("apply nursing care in long-term care", full_set$preferred_skillLabel) | 
       grepl("provide care for the mother during labour", full_set$preferred_skillLabel) | 
       grepl("provide postnatal care", full_set$preferred_skillLabel) | 
       grepl("provide professional care in nursing", full_set$preferred_skillLabel) | 
       grepl("work with healthcare users under medication", full_set$preferred_skillLabel) | 
       grepl("reinforce positive behaviour", full_set$preferred_skillLabel) | 
       grepl("develop a collaborative therapeutic relationship", full_set$preferred_skillLabel) | 
       grepl("develop therapeutic relationships", full_set$preferred_skillLabel) | 
       grepl("provide stabilisation care in emergency", full_set$preferred_skillLabel) | 
       grepl("provide pre-natal care", full_set$preferred_skillLabel) | 
       grepl("handle patient trauma", full_set$preferred_skillLabel) | 
       grepl("provide specialist pharmaceutical care", full_set$preferred_skillLabel) | 
       grepl("implement fundamentals of nursing", full_set$preferred_skillLabel) | 
       grepl("implement nursing care", full_set$preferred_skillLabel) | 
       grepl("assist in the administration of medication to elderly", full_set$preferred_skillLabel) | 
       grepl("assist on pregnancy abnormality", full_set$preferred_skillLabel) | 
       grepl("assist patients with rehabilitation", full_set$preferred_skillLabel)) & 
    !grepl("chair a meeting", full_set$preferred_skillLabel) & 
    !grepl("present storyboard", full_set$preferred_skillLabel) & 
    !grepl("brief staff on daily menu", full_set$preferred_skillLabel) & 
    !grepl("increase the impact of science on policy and society", full_set$preferred_skillLabel) & 
    !grepl("apply quality standards in social services", full_set$preferred_skillLabel) & 
    !grepl("apply quality standards in youth services", full_set$preferred_skillLabel) & 
    !grepl("provide protective equipment against infectious diseases", full_set$preferred_skillLabel) & 
    !grepl("describe your artistic aspirations in relation to artistic trend", full_set$preferred_skillLabel) & 
    !grepl("apply frequency management", full_set$preferred_skillLabel) & 
    !grepl("buy groceries", full_set$preferred_skillLabel) &
    !grepl("communicate problems to senior colleagues", full_set$preferred_skillLabel) & 
    !grepl("confer with event staff", full_set$preferred_skillLabel) & 
    !grepl("consult with sound editor", full_set$preferred_skillLabel) & 
    !grepl("consult with technical staff", full_set$preferred_skillLabel) & 
    !grepl("identify performers' needs", full_set$preferred_skillLabel) & 
    !grepl("confer with library colleagues", full_set$preferred_skillLabel) & 
    !grepl("participate as a performer in the creative process", full_set$preferred_skillLabel) & 
    !grepl("listen actively to sport players", full_set$preferred_skillLabel) 
)

# Social Inward (management-focus variant) (robustness check definition for Matysiak et al., 2024)
full_set$tasks_social_mngmt <- (
  (full_set$skill_group_3=="S1.1.1" | 
     grepl("communicate analytical insights", full_set$preferred_skillLabel) |  
     grepl("communicate with construction crews", full_set$preferred_skillLabel) |  
     grepl("communicate with customer service department", full_set$preferred_skillLabel) |  
     grepl("communicate with external laboratories", full_set$preferred_skillLabel) | 
     grepl("communicate with nursing staff", full_set$preferred_skillLabel) | 
     grepl("communicate with shipment forwarders", full_set$preferred_skillLabel) | 
     grepl("communicate on merchandise visual display", full_set$preferred_skillLabel) | 
     grepl("communicate with waste collectors", full_set$preferred_skillLabel) | 
     grepl("conduct inter-shift communication", full_set$preferred_skillLabel) | 
     (full_set$skill_group_3=="S1.2.1" & 
        grepl("coordinate ", full_set$preferred_skillLabel) & 
        !grepl("coordinate with", full_set$preferred_skillLabel)) |
     grepl("ensure cross-department cooperation", full_set$preferred_skillLabel) | 
     grepl("maintain operational communications", full_set$preferred_skillLabel) | 
     grepl("manage communications with food industry governmental bodies", full_set$preferred_skillLabel) | 
     grepl("manage fitness communication", full_set$preferred_skillLabel) | 
     grepl("communicate production plan", full_set$preferred_skillLabel) | 
     grepl("impart business plans to collaborators", full_set$preferred_skillLabel) | 
     full_set$skill_group_3=="S1.8.2" | 
     full_set$skill_group_3=="S1.8.3" | 
     full_set$skill_group_2=="S4.5" | 
     full_set$skill_group_3=="S4.8.1" | 
     grepl("coordinate security", full_set$preferred_skillLabel) | 
     grepl("involve volunteers", full_set$preferred_skillLabel) | 
     grepl("manage volunteers in second-hand shop", full_set$preferred_skillLabel) | 
     grepl("manage agricultural staff", full_set$preferred_skillLabel) | 
     grepl("manage chiropractic staff", full_set$preferred_skillLabel) | 
     grepl("manage human resources", full_set$preferred_skillLabel) | 
     grepl("instruct kitchen personnel", full_set$preferred_skillLabel) | 
     grepl("manage physiotherapy staff", full_set$preferred_skillLabel) | 
     grepl("chair a meeting", full_set$preferred_skillLabel) | 
     grepl("brief staff on daily menu", full_set$preferred_skillLabel)) & 
    !grepl("perform lectures", full_set$preferred_skillLabel) & 
    !grepl("circulate information", full_set$preferred_skillLabel) & 
    !grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) & 
    !grepl("deliver visual presentation of data", full_set$preferred_skillLabel) & 
    !grepl("apply frequency management", full_set$preferred_skillLabel) & 
    !grepl("ensure compliance with warranty contracts", full_set$preferred_skillLabel) & 
    !grepl("book cargo", full_set$preferred_skillLabel) & 
    !grepl("communicate in specialized nursing care", full_set$preferred_skillLabel) & 
    !grepl("communicate in healthcare", full_set$preferred_skillLabel) & 
    !grepl("communicate with beneficiaries", full_set$preferred_skillLabel) & 
    !grepl("communicate with elderly groups", full_set$preferred_skillLabel) & 
    !grepl("communicate with local residents", full_set$preferred_skillLabel) & 
    !grepl("communicate with media", full_set$preferred_skillLabel) & 
    !grepl("communicate with social service users", full_set$preferred_skillLabel) & 
    !grepl("communicate with tenants", full_set$preferred_skillLabel) & 
    !grepl("consult with business clients", full_set$preferred_skillLabel) & 
    !grepl("manage animal adoption", full_set$preferred_skillLabel) & 
    !grepl("organise entry to attractions", full_set$preferred_skillLabel) & 
    !grepl("organise group music therapy sessions", full_set$preferred_skillLabel) & 
    !grepl("perform dunning activities", full_set$preferred_skillLabel) & 
    !grepl("maintain relations with children's parents", full_set$preferred_skillLabel) & 
    !grepl("deliver social services in diverse cultural communities", full_set$preferred_skillLabel) & 
    !grepl("communicate technicalities with clients", full_set$preferred_skillLabel) & 
    !grepl("communicate clearly with passengers", full_set$preferred_skillLabel) & 
    !grepl("communicate with park visitors", full_set$preferred_skillLabel) & 
    !grepl("contact customers", full_set$preferred_skillLabel) &
    !grepl("build helping relationship with social service users", full_set$preferred_skillLabel) & 
    !grepl("develop a collaborative therapeutic relationship", full_set$preferred_skillLabel) & 
    !grepl("develop therapeutic relationships", full_set$preferred_skillLabel) & 
    !grepl("establish customer rapport", full_set$preferred_skillLabel) & 
    !grepl("establish relationship with the media", full_set$preferred_skillLabel) & 
    !grepl("improve customer interaction", full_set$preferred_skillLabel) & 
    !grepl("maintain the trust of service users", full_set$preferred_skillLabel) & 
    !grepl("manage psychotherapeutic relationships", full_set$preferred_skillLabel) & 
    !grepl("manage student relationships", full_set$preferred_skillLabel) & 
    !grepl("represent the organization", full_set$preferred_skillLabel) & 
    !grepl("engage local communities in the management of natural protected areas", full_set$preferred_skillLabel) & 
    !grepl("prospect new customers", full_set$preferred_skillLabel) & 
    !grepl("maintain relationship with customers", full_set$preferred_skillLabel) & 
    !grepl("maintain relations with local representatives", full_set$preferred_skillLabel) & 
    !grepl("represent the company", full_set$preferred_skillLabel) &
    !grepl("work with different target groups", full_set$preferred_skillLabel) & 
    !grepl("work with healthcare users under medication", full_set$preferred_skillLabel) & 
    !grepl("build rapport with people from different cultural backgrounds", full_set$preferred_skillLabel) & 
    !grepl("work in a multicultural environment in fishery", full_set$preferred_skillLabel) & 
    !grepl("establish communication with foreign cultures", full_set$preferred_skillLabel) & 
    !grepl("inform drivers of detour routes", full_set$preferred_skillLabel) & 
    !grepl("communicate verbal instructions", full_set$preferred_skillLabel) & 
    !grepl("reinforce positive behaviour", full_set$preferred_skillLabel) & 
    !grepl("give constructive feedback", full_set$preferred_skillLabel) & 
    !grepl("provide feedback on patient's communication style", full_set$preferred_skillLabel) &
    !grepl("communicate with a non-scientific audience", full_set$preferred_skillLabel) & 
    !grepl("communicate specialised veterinary information", full_set$preferred_skillLabel) & 
    !grepl("speak about your work in public", full_set$preferred_skillLabel) & 
    !grepl("apply technical communication skills", full_set$preferred_skillLabel) &
    full_set$skill_group_3!="S1.8.5"
)

# Separate tasks listed as Essential
full_set$ess_tasks_social <- full_set$tasks_social & full_set$relationType=="essential"
full_set$ess_tasks_social_outward <- full_set$tasks_social_outward & full_set$relationType=="essential"
full_set$ess_tasks_social_inward <- full_set$tasks_social_inward & full_set$relationType=="essential"
full_set$ess_tasks_technical <- full_set$tasks_technical & full_set$relationType=="essential" 
full_set$ess_tasks_artistic_creative <- full_set$tasks_artistic_creative & full_set$relationType=="essential" 
full_set$ess_tasks_analytical <- full_set$tasks_analytical & full_set$relationType=="essential" 
full_set$ess_tasks_routine <- full_set$tasks_routine & full_set$relationType=="essential" 
full_set$ess_tasks_nonroutine <- full_set$tasks_nonroutine & full_set$relationType=="essential" 
full_set$ess_tasks_manual <- full_set$tasks_manual & full_set$relationType=="essential"
full_set$ess_tasks_social_mngmt <- full_set$tasks_social_mngmt & full_set$relationType=="essential"
full_set$ess_tasks_social_care <- full_set$tasks_social_care & full_set$relationType=="essential"

# Separate tasks listed as Optional
full_set$opt_tasks_social <- full_set$tasks_social & full_set$relationType=="optional"
full_set$opt_tasks_social_outward <- full_set$tasks_social_outward & full_set$relationType=="optional"
full_set$opt_tasks_social_inward <- full_set$tasks_social_inward & full_set$relationType=="optional"
full_set$opt_tasks_analytical <- full_set$tasks_analytical & full_set$relationType=="optional" 
full_set$opt_tasks_artistic_creative <- full_set$tasks_artistic_creative & full_set$relationType=="optional" 
full_set$opt_tasks_analytical <- full_set$tasks_analytical & full_set$relationType=="optional" 
full_set$opt_tasks_routine <- full_set$tasks_routine & full_set$relationType=="optional" 
full_set$opt_tasks_nonroutine <- full_set$tasks_nonroutine & full_set$relationType=="optional" 
full_set$opt_tasks_manual <- full_set$tasks_manual & full_set$relationType=="optional"
full_set$opt_tasks_social_mngmt <- full_set$tasks_social_mngmt & full_set$relationType=="optional"
full_set$opt_tasks_social_care <- full_set$tasks_social_care & full_set$relationType=="optional"

# Calculate share of tasks that got categorised
skills <- full_set[full_set$skillType=="skill/competence",]
skills$any <- (skills$tasks_social | 
                 skills$tasks_technical | 
                 skills$tasks_analytical | 
                 skills$tasks_artistic_creative | 
                 skills$tasks_routine | 
                 skills$tasks_nonroutine | 
                 skills$tasks_manual)

all <- skills$preferred_skillLabel %>% unique() %>% length()
used <- skills$preferred_skillLabel[skills$any==TRUE] %>% unique() %>% length()
all
used
used/all

full_set[full_set==TRUE] <- 1

# Save categorised task items
write.csv(full_set, paste0(outputs, "\\esco_tasks.csv"), row.names = FALSE, na = "")
