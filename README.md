# Internet Use and Anxiety Symptom Severity Among U.S. College Students

**VTPEH 6270 Final Project** | Cornell University | Spring 2026

[![Shiny App](https://img.shields.io/badge/Shiny-Live%20App-blue?logo=r)](https://hbauta.shinyapps.io/application/)
[![Report](https://img.shields.io/badge/Report-PDF-red?logo=adobeacrobatreader)](Report/Final_Report_.pdf)
[![Data](https://img.shields.io/badge/Data-Healthy%20Minds%20Study-green)](https://healthymindsnetwork.org/)

---

## Overview

This repository contains all code and materials to fully reproduce the final report and interactive Shiny app for my VTPEH 6270 project. The study examines whether daily internet and social media use is associated with greater anxiety symptom severity (GAD-7) among U.S. college students, and whether this association varies by LGBTQ+ identity or first-generation student status.

**Data source:** [Healthy Minds Study (HMS) 2024–2025 Academic Year](https://healthymindsnetwork.org/), a nationally representative web-based survey of students at U.S. colleges and universities (full dataset: N = 84,735; analytic sample: N = 34,953).

---

## Research Questions

1. **Primary:** Is higher daily internet and social media use associated with greater anxiety symptom severity (GAD-7) among U.S. college students?
2. **Secondary:** Does this association persist after accounting for depression severity, financial stress, sense of belonging, and demographics?
3. **Subgroup:** Does the association differ by LGBTQ+ identity or first-generation student status?

---

## Key Findings

- Each additional hour of internet use per day was associated with a **0.047-point increase in GAD-7 score** (95% CI: [0.022, 0.072]) after full covariate adjustment.
- **Depression severity** (PHQ-9) was the strongest independent predictor of anxiety (Std. β = 0.703).
- **LGBTQ+ students** reported substantially higher anxiety than cisgender-heterosexual peers (mean difference = 2.65 points, p < 0.001).
- **First-generation students** showed a significantly steeper internet–anxiety gradient than non-first-gen peers (interaction β = 0.060, p = 0.041).

---

## Repository Structure

```
HanaBauta_FinalProject/
│
├── README.md
│
├── App/
│   ├── app.R                                   # Shiny app (ui + server)
│   ├── hms_subset.csv                          # Data copy for app deployment
│   └── rsconnect/shinyapps.io/hbauta/          # shinyapps.io deployment config
│
├── Bibliography/
│   └── bib_final.bib                           # BibTeX reference file
│
├── Data/
│   ├── HMS Data/
│   │   └── hms_subset.csv                      # Analytic subset used in report
│   └── Codebook/
│       └── HMS_24-25_Codebook.pdf              # Official HMS variable codebook
│
├── Figures/
│   ├── assumption-plots-1.pdf                  # Q-Q and residuals-vs-fitted plots
│   ├── coef-plot-1.pdf                         # Standardised coefficient forest plot
│   ├── dist-plots-1.pdf                        # GAD-7 and internet use distributions
│   ├── group-diff-plots-1.pdf                  # Boxplots by LGBTQ+ and first-gen
│   ├── moderation-plots-1.pdf                  # Marginal predicted scores by subgroup
│   └── scatter-1.pdf                           # Internet use vs. anxiety scatterplot
│
├── Report/
│   └── Final_Report_.pdf                       # Compiled final report (PDF)
│
└── Scripts/
    └── _Final_Report_.Rmd                      # RMarkdown source (report + analysis)
```

---

## Outputs

| Output | Link |
|--------|------|
| 📄 Final Report (PDF) | [`Report/Final_Report_.pdf`](Report/Final_Report_.pdf) |
| 🌐 Interactive Shiny App | [https://hbauta.shinyapps.io/application/](https://hbauta.shinyapps.io/application/) |

---

## Data Access

The data used in this project come from the **Healthy Minds Study (HMS) 2024–2025**. The HMS is a restricted-access dataset available to researchers at participating institutions.

- To request access: [https://healthymindsnetwork.org/research/data-for-researchers/](https://healthymindsnetwork.org/research/data-for-researchers/)
- The analytic subset (`hms_subset.csv`) is included for reproducibility within this course context.
- The official variable codebook is at `Data/Codebook/HMS_24-25_Codebook.pdf`.

**Key variables used:**

| Variable | Description |
|----------|-------------|
| `anx_score` | GAD-7 sum score (0–21); primary outcome |
| `internet_1` | Self-reported daily internet/social media hours (1–8); primary exposure |
| `lgbtq` | LGBTQ+ identity (0 = Cis-Hetero, 1 = LGBTQ+) |
| `first_gen` | First-generation student status (0 = No, 1 = Yes) |
| `age` | Age in years |
| `belong1` | Sense of belonging (continuous) |
| `fincur_stress` | Current financial stress (continuous) |
| `deprawsc` | PHQ-9 depression score (0–27) |

---

## Reproducing the Report

### Requirements

R (≥ 4.1) and the following packages:

```r
install.packages(c(
  "tidyverse", "ggpubr", "knitr", "rmarkdown",
  "broom", "kableExtra", "car", "parameters",
  "modelsummary", "shiny", "bslib", "scales", "readr"
))
```

> **Note:** The report uses `xelatex` as the LaTeX engine. Install TinyTeX if needed:
> ```r
> install.packages("tinytex")
> tinytex::install_tinytex()
> ```

### Steps

1. Clone the repository
2. Compile the report
3. Run the Shiny app locally
Or open App/app.R in RStudio and click Run App.
---

## Statistical Methods Summary

- **Descriptive statistics:** Means, SDs, and proportions for all study variables.
- **Group comparisons:** Independent-samples t-tests (Welch's correction) for LGBTQ+ and first-generation subgroups.
- **Regression:** Two linear models predicting GAD-7 score:
  - *Model 1:* Unadjusted (internet use only)
  - *Model 2:* Adjusted for age, LGBTQ+ identity, first-gen status, belonging, financial stress, PHQ-9
- **Moderation:** Interaction terms added separately for LGBTQ+ identity (Model 3a) and first-generation status (Model 3b); marginal predicted scores plotted with 95% CIs.
- **Assumption checks:** Q-Q plots, residuals-vs.-fitted plots, and variance inflation factors (VIFs).

All analyses conducted in **R (version 4.x)**.

---

## Shiny App

The interactive app allows users to explore all major analyses from the report:

- **About** — Study context, research questions, and key statistics
- **Descriptives** — Distributions of GAD-7, internet use, and PHQ-9, coloured by subgroup
- **Group Comparisons** — Box/violin plots and Welch t-test results by LGBTQ+ or first-gen status
- **Regression Models** — Regression lines and standardised coefficient forest plot
- **Moderation Analysis** — Marginal predicted GAD-7 by internet use for each subgroup with 95% CI bands

🔗 **[https://hbauta.shinyapps.io/application/](https://hbauta.shinyapps.io/application/)**

---

## Author

**Hana Bauta**  
Graduate Student, VTPEH 6270  
Cornell University, Spring 2026  
GitHub: [@hb537](https://github.com/hb537)

---

## References

- Karim, F., et al. (2020). Social media use and its connection to mental health: A systematic review. *Cureus, 12*(6), e8627.
- Moagi, M. M., et al. (2021). Mental health challenges of LGBTQ people: An integrated literature review. *Health SA, 26*, 1487.
- Tafesse, W., et al. (2024). Digital overload, coping mechanisms, and student engagement. *SAGE Open, 14*(1).
- Twenge, J. M., et al. (2018). Increases in depressive symptoms and suicide rates among U.S. adolescents. *Clinical Psychological Science, 6*(1), 3–17.
- Vannucci, A., et al. (2017). Social media use and anxiety in emerging adults. *Journal of Affective Disorders, 207*, 163–166.
- Horne, C., & Chukwuere, P. C. (2025). Mental health challenges at the intersection of first-year, first-generation college students. *Healthcare (Basel), 14*(1), 21.

---

## AI Use Disclosure

This project was completed with assistance from **Claude (Anthropic)** AI to support code development, figure formatting, and documentation. All code was reviewed and verified by the author prior to submission. All analytical and interpretive decisions reflect the author's independent judgment.

---
