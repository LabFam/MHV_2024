---
title: "Structural Labour Market Change and Gender Inequality in Earnings"
subtitle: "Reproduction codes"
author: "Matysiak, A., Hardy, W., van der Velde, L."
date: today
format:
  html:
    embed-resources: true
keep-md: true
title-block-banner: true
---



## Contents

This repository contains the codes and otputs necessary to reproduce the article *"Structural Labour Market Change and Gender Inequality in Earnings"* by  Matysiak et al. (2024). When using these resources, please provide a citation for:

<to be included when the paper goes online>

## Repository

The files stored in the repository are split into the following directories:

### > Codes

The **code** directory includes:

1. Task indices construction

This folder includes R codes used for the categorisation of the ESCO database items into task categories as defined in the Matysiak et al. (2024) paper. The outputs of these files can be used for standardisation and analyses with different data sources on workers.

The results of these codes (i.e. a dataset containing categorised tasks) can be found on Zenodo: 10.5281/zenodo.11092167.

2. Main analysis

This folder includes Stata codes used for all the results in the Matysiak et al. (2024) paper. The first steps include the matching and standardisation of the task indices, with further code files providing calculations, figures, tables and robustness checks - as presented in the Matysiak et al. (2024) paper.

The ado_files directory provides relevant versions of the used Stata packages.

### > Data

The **data** folder includes key intermediate data outputs of the paper, e.g. the task categorisation in *esco_onet_matysiaketal2024.csv* as well as the final standardised task content measures in *tasks_isco08_2018_stdlfs* files. These files can be reproduced using the included codes, but as not data is easily obtainable, provide a shortcut for collecting the task measures.

This directory also includes necessary crosswalks and supplementary data inputs (all described in the relevant do-files.)

### > Output

The **output** directory includes all figures and tables as presented in the Matysiak et al. (2024) paper. These files can be also generated by the included codes.

## Data sources

The codes used in this repository rely on several data sources. The R codes in the first folder make use of the [O*NET database](https://www.onetcenter.org/database.html) in it's 25.0 version (other versions could be likely used with additional crosswalks and checking), as well as the [ESCO database](https://esco.ec.europa.eu/en/use-esco/download) files in their 1.0.8 version. Finally, the codes use a crosswalk between occupation classifications, included in the first folder along with the codes.

The codes in the main analysis folder use the *EU Structure of Earnings Survey (EU SES)* data and the *EU Labour Force Survey (EU LFS)* data. These data need to be applied for and are not included in this package.

## Article abstract

*Research from the US argues that women will benefit from a structural labour market change as the importance of social tasks increases and that of manual tasks declines. This article contributes to this discussion in three ways: (a) by extending the standard framework of task content of occupations in order to account for the gender perspective; (b) by developing measures of occupational task content tailored to the European context; and (c) by testing this argument in 13 European countries. Data are analysed from the European Skills, Competences, Qualifications and Occupations Database and the European Structure of Earnings Survey. The analysis demonstrates that relative to men the structural labour market change improves the earnings potential of women working in low- and middle-skilled occupations but not those in high-skilled occupations. Women are overrepresented in low paid social tasks (e.g. care) and are paid less for analytical tasks than men.*

## Environment

The R codes in this repository rely on the `Groundhog` package to load the necessary versions of used packages. They were last run with R version 4.3.2.

The Stata codes have been last run using Stata 17, and the codes folders include ado-files in relevant versions. 

## Authors

For questions please contact [Prof. Anna Matysiak](amatysiak@wne.uw.edu.pl), [Wojciech Hardy](wojciechhardy@uw.edu.pl) or [Lucas van der Velde](lvandervelde@grape.org.pl)
