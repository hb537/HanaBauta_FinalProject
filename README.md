# VTPEH6270: Final Project
## Daily Internet Use and Mental Health Among U.S. College Students
---

## Description

This project investigates whether higher daily internet and social media use is associated with greater anxiety symptom severity among U.S. college students, and whether this association persists after accounting for demographic, socioeconomic, and psychosocial factors including loneliness, financial stress, and sense of belonging.

The analysis utilizes the **Healthy Minds Study (HMS) 2024–2025** dataset — a nationally representative, open-source survey of mental health and technology use among students at U.S. colleges and universities (N = 84,735 total; N = 34,953 analyzed).

---

## Author

**Hana Bauta** — MPH Candidate, Cornell University  
Contact: [hb537@cornell.edu](mailto:hb537@cornell.edu)

**Affiliation & Collaboration**
- Cornell University: Master of Public Health Program (MPH)
- NYU Grossman School of Medicine: Department of Population Health (Dr. Keng-Yen Huang) (Hyungrok Do, PhD)

---

## Research Questions

1. Is higher daily internet and social media use associated with greater GAD-7 anxiety severity among U.S. college students?
2. Does this association persist after controlling for age, gender, LGBTQ+ identity, first-generation student status, financial stress, sense of belonging, and loneliness?
3. Does the tech-anxiety association differ by LGBTQ+ identity or first-generation student status?

---

## Data Source

**Healthy Minds Study (HMS) 2024–2025**
- A national, open-source, web-based survey focused on mental health, help-seeking behaviors, and technology use among adolescent and young adult students across U.S. colleges and universities
- Participants recruited via stratified random sampling of enrolled students at each participating institution
- Full dataset: 84,735 observations, 1,608 variables
- Primary analysis sample: 34,953 students with complete data on the exposure and primary outcome
- Access: [healthymindsnetwork.org](https://healthymindsnetwork.org)

---

## Project Structure

```
VTPEH6270-FinalProject/
│
├── data/
│   ├── raw/                          # Original HMS dataset (not included; see access instructions above)
│   └── hms_subset.csv                # Processed analysis subset
│
├── scripts/
│   └── hms_subset_final.R            # Subsetting script: full HMS → analysis subset
│
├── outputs/
│   ├── figures/                      # Visualizations generated from the analysis
│   └── reports/
│       ├── final_report.Rmd          # Final report R Markdown source
│       └── final_report.pdf          # Compiled PDF output
│
├── app/
│   └── app.R                         # Shiny app source code
│
└── references.bib                    # BibTeX references
```

---

## Methods

- **Statistical Analysis:** Linear regression models in R to examine associations between daily internet use and anxiety (GAD-7), depression (PHQ-9), and psychological flourishing (Diener Scale)
- **Covariates:** Age, gender identity, LGBTQ+ identity, first-generation student status, financial stress, sense of belonging, and loneliness (UCLA 3-item scale)
- **Moderation Analysis:** Interaction terms tested to assess whether the tech-anxiety association differs by LGBTQ+ identity and first-generation status
- **Assumption Checks:** Residuals vs. fitted and Q-Q plots; Shapiro-Wilk not used (N > 5,000)

---

## How to Reproduce

**Required R packages:**
```r
install.packages(c("tidyverse", "knitr", "kableExtra",
                   "ggpubr", "broom", "scales", "shiny"))
```

**Recreate the data subset** (requires full HMS CSV):
```r
source("scripts/hms_subset_final.R")
# Update the file path inside the script to your local HMS CSV
```

**Knit the final report:**
```r
rmarkdown::render("outputs/reports/final_report.Rmd")
```

**Run the Shiny app locally:**
```r
shiny::runApp("app/app.R")
```

---

## Shiny App

**[https://hbauta.shinyapps.io/application/](https://hbauta.shinyapps.io/application/)**

The app includes interactive tabs for exploring the HMS data, regression outputs, group-level distributions, and a statistical power simulation.

---

## Data Privacy & Ethics

The HMS dataset is publicly available and contains no personally identifiable information. All data are used strictly for academic purposes in accordance with the Healthy Minds Network's data use policies.

---

## AI Disclosure

Claude (Anthropic) and Gemini were used to assist with code development, data subsetting, RMarkdown structuring, and debugging throughout this project. All academic interpretations and conclusions are the work of the author.
