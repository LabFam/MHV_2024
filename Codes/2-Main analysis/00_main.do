*------------------------------------------------*
*		Setting up the estimations
*-------------------------------------------------*

version 17

** Define paths
*------------------

* paths to fill
global data_euses "..."
global data_eulfs "..."
global data_pl    "..." 
global codes      "c(pwd)" 					// Change to location of 00_main 
global data_tasks "$codes/../../data" 


** Create additional folders
*------------------------------

capture mkdir "$codes/../../output"          // where results should go
capture mkdir "$codes/../../temp"            // where intermediate results should go
capture mkdir "$codes/../../data_ready"      // where intermediate data should go
capture mkdir "$codes/ado_files"

global results      "$codes/../../output"          // where results should go
global temp_folder  "$codes/../../temp"            // temporary data
global data         "$codes/../../data_ready"       // where intermediate data should go

 

** Additional packages:
*-----------------------

sysdir set PLUS "$codes/ado_files"

ssc install estout			, replace
ssc install coefplot		, replace
ssc install scheme-burd


** Running the remaining dofiles
*--------------------------


capture do 01_weights_lfs.do 

/*
 File uses EU LFS data fo recover the importance of different occupations over time. 
INPUT: this file requires EULFS and Polish LFS data, as well as the crosswalks obtainable from here: https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-isco-to-kzis/
OUTPUT: The output is weights_EUavg (also distributed with this files)
*/

capture do 02_tasks.do       

/*
 File produces a database with task content of jobs for each 3 digit ISCO 08 
	and ISCO 88 occupation.
INPUT: esco_onet_matysiaketal2024.csv and weights_EUavg.dta
OUTPUT: tasks_isco88_2018_stdlfs.dta
        tasks_isco88_2018_stdlfs.dta
*/		

capture do 03_prepare_SES.do 
/*
 File produces a database containing wages, occupations, selected characteristics
 and task content of jobs for all countries in EU-SES for the period 2002-2018. 
 
INPUT: EU Structure of Earnings Data (not distributed) 
       tasks_isco88_2018_stdlfs.dta
       tasks_isco88_2018_stdlfs.dta
	   
OUTPUT: Main database for the analysis, SES_appended	   
*/		

capture do 04_corr_ONET_ESCO.do

/*
 File compares tasks content of occupations obtained from O*NET and ESCO
 
INPUT: tasks_isco88_2018_stdlfs.dta
	   
OUTPUT:Table A2 in the paper
   
*/		


capture do 05_task_desc_by_isco2.do

/*
File describes the tasks content of occupations obtained by ISCO 08, at the 2 digit level
 
INPUT: tasks_isco08_2d.dta
	   
OUTPUT: Figure 1 in the paper
   
*/		


capture do 06_wage_regressions.do

/*
File produces the analysis of returns to task by gender, and across countries
 
INPUT: SES_appended.dta
	   
OUTPUT: Table 2, Figure 2 in the main paper, Table a3 in the Appendix, part of table a1
   
*/

capture do 07_differences_in_task.do

/*
File produces the analysis of difference in task content by gender, and across countries
 
INPUT: SES_appended.dta
	   
OUTPUT: Table 3, Figure 3 in the main paper, Table a4 in the Appendix
   
*/



capture do 08_time_changes.do

/*
File produces the analysis of difference in task content by gender, and over time
 
INPUT: SES_appended.dta
	   
OUTPUT: Figure 4 and Figure 5 in the main paper
   
*/

capture do 09_alternative_social_tasks.do

/*
File produces an alternative analysis of social tasks based on a narrower definition
of care and management
 
INPUT: SES_appended.dta
	   
OUTPUT: table a5 in the appendix
   
*/