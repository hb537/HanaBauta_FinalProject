# ============================================================
# Tech Engagement & Mental Health — Shiny App (Enhanced)
# Author: Hana Bauta
# Dual-Dataset Analysis: mWEL (Educators) & HMS (College Students)
# ============================================================
library(shiny)
library(tidyverse)
library(ggplot2)
library(here)

# ============================================================
# CUSTOM CSS STYLING FOR PORTFOLIO
# ============================================================
portfolio_css <- tags$head(
  tags$style(HTML("
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
      color: #2c3e50;
      line-height: 1.6;
    }
    /* ===== NAVBAR ===== */
    .navbar-inverse {
      background: linear-gradient(to right, #f8f9fa, #e8ecf1);
      border: none;
      box-shadow: 0 2px 12px rgba(0,0,0,0.1);
      min-height: 70px;
      padding: 15px 0;
      border-bottom: 3px solid #00b6ff;
    }
    .navbar-brand {
      font-size: 20px !important;
      font-weight: 700;
      color: #1a1a2e !important;
      letter-spacing: 0.5px;
      margin-left: 30px;
    }
    .navbar-inverse .navbar-nav > li > a {
      color: #2c3e50 !important;
      font-weight: 600;
      font-size: 14px;
      padding: 10px 20px !important;
      transition: all 0.3s ease;
    }
    .navbar-inverse .navbar-nav > li > a:hover {
      color: #00b6ff !important;
      background: rgba(0,182,255,0.08);
      border-radius: 4px;
    }
    .navbar-inverse .navbar-nav > li.active > a {
      color: #00b6ff !important;
      background: rgba(0,182,255,0.12);
      border-bottom: 3px solid #00b6ff;
      border-radius: 4px 4px 0 0;
      font-weight: 700;
    }
    .container-fluid { background: transparent; }
    .well {
      background: #ffffff;
      border: none;
      border-radius: 8px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      padding: 30px;
      margin-bottom: 20px;
    }
    .sidebar-panel {
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      padding: 25px;
      margin-bottom: 20px;
    }
    .sidebar-label {
      font-weight: 600;
      color: #1a1a2e;
      margin-bottom: 12px;
      font-size: 14px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    h1, h2, h3, h4, h5, h6 {
      color: #1a1a2e;
      font-weight: 700;
      margin-bottom: 15px;
    }
    h2 {
      font-size: 26px;
      padding-bottom: 12px;
      border-bottom: 3px solid #00b6ff;
      display: inline-block;
      margin-bottom: 25px;
    }
    h3 {
      font-size: 20px;
      color: #16213e;
      margin-top: 25px;
    }
    h4 { font-size: 16px; color: #2c3e50; font-weight: 600; }
    p { color: #34495e; margin-bottom: 12px; font-size: 15px; }
    ul, ol { margin-left: 20px; margin-bottom: 15px; }
    li { margin-bottom: 8px; color: #34495e; }
    .form-group { margin-bottom: 20px; }
    .form-control {
      border: 2px solid #e8eef5;
      border-radius: 6px;
      padding: 10px 14px;
      font-size: 14px;
      transition: all 0.3s ease;
      background-color: #ffffff;
    }
    .form-control:focus {
      border-color: #00b6ff;
      box-shadow: 0 0 0 4px rgba(0,182,255,0.1);
      background-color: #ffffff;
    }
    label { color: #2c3e50; font-weight: 600; font-size: 14px; margin-bottom: 8px; }
    .irs { margin: 15px 0; }
    .irs-slider { background: linear-gradient(to right, #00b6ff, #0099ff); box-shadow: 0 2px 8px rgba(0,182,255,0.3); }
    .irs-from, .irs-to, .irs-single { background: #00b6ff; border-radius: 4px; padding: 3px 8px; font-weight: 600; font-size: 12px; }
    .checkbox label { font-weight: 500; color: #2c3e50; margin-top: 10px; padding-left: 30px; }
    input[type='checkbox'] { width: 18px; height: 18px; cursor: pointer; accent-color: #00b6ff; }
    input[type='radio'] { accent-color: #00b6ff; }
    .shiny-plot-output {
      background: #ffffff;
      border-radius: 8px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      padding: 20px;
      margin-bottom: 25px;
    }
    table.table {
      background: #ffffff;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      margin-top: 20px;
    }
    table.table thead {
      background: linear-gradient(to right, #1a1a2e, #16213e);
      border: none;
    }
    table.table thead th {
      color: #ffffff;
      font-weight: 700;
      padding: 15px 12px;
      border: none;
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    table.table tbody td {
      padding: 12px;
      border-bottom: 1px solid #ecf0f5;
      color: #34495e;
    }
    table.table tbody tr:hover { background: #f8fafc; }
    table.table tbody tr:last-child td { border-bottom: none; }
    .shiny-text-output {
      background: #f8fafc;
      border-left: 4px solid #00b6ff;
      padding: 20px;
      border-radius: 6px;
      font-family: 'Courier New', monospace;
      font-size: 13px;
      color: #2c3e50;
      line-height: 1.6;
      margin-top: 20px;
    }
    .info-card {
      background: linear-gradient(135deg, #f5f7fa 0%, #e9ecef 100%);
      border-left: 4px solid #00b6ff;
      padding: 20px;
      border-radius: 6px;
      margin: 20px 0;
    }
    .info-card h4 { margin-top: 0; color: #16213e; }
    .highlight-box {
      background: linear-gradient(135deg, #00b6ff, #0099ff);
      color: #ffffff;
      padding: 20px;
      border-radius: 8px;
      margin: 20px 0;
      box-shadow: 0 4px 15px rgba(0,182,255,0.2);
    }
    .highlight-box h4 { color: #ffffff; margin-top: 0; }
    .highlight-box p { color: rgba(255,255,255,0.95); margin-bottom: 0; }
    .dataset-badge {
      display: inline-block;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      margin: 5px;
    }
    .badge-mwel {
      background: #e8f4f8;
      color: #0066cc;
      border: 1px solid #0066cc;
    }
    .badge-hms {
      background: #f0e8f8;
      color: #6600cc;
      border: 1px solid #6600cc;
    }
    @media (max-width: 768px) {
      .navbar-brand { font-size: 16px; margin-left: 15px; }
      .well, .sidebar-panel { padding: 20px; }
      h2 { font-size: 22px; }
      h3 { font-size: 18px; }
      .shiny-plot-output { padding: 10px; }
    }
    .row { margin-bottom: 20px; }
    .col-sm-3, .col-sm-9 { padding: 10px; }
  "))
)

# ============================================================
# PUBLICATION-STYLE GGPLOT2 THEME
# ============================================================
theme_portfolio <- function() {
  theme_minimal(base_size = 12, base_family = "sans") +
    theme(
      plot.title = element_text(face = "bold", size = 14, color = "#1a1a2e", margin = margin(b = 8)),
      plot.subtitle = element_text(size = 11, color = "#7f8c8d", margin = margin(b = 12)),
      axis.title = element_text(face = "bold", size = 11, color = "#2c3e50"),
      axis.text = element_text(size = 10, color = "#34495e"),
      panel.grid.major = element_line(color = "#ecf0f5", size = 0.3),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "#ffffff", color = NA),
      plot.background = element_rect(fill = "#ffffff", color = NA),
      legend.position = "none",
      plot.margin = margin(12, 12, 12, 12)
    )
}

# ============================================================
# COLOR PALETTES
# ============================================================
palette_age <- c("<25" = "#0099ff", "25–34" = "#00d4ff", "35–44" = "#ffa500", "45–54" = "#ff6b6b", "55+" = "#9b59b6")
palette_tertile <- c("1" = "#aed6f1", "2" = "#3498db", "3" = "#1a5490")
palette_usage <- c("None" = "#aed6f1", "<1hr" = "#5dade2", "1–2hr" = "#3498db", "2–3hr" = "#2980b9",
                   "3–4hr" = "#1a5490", "4–6hr" = "#0d3b66", "6–9hr" = "#ff6b6b", "10+hr" = "#c0392b")

# ============================================================
# DATA LOADING
# ============================================================
mwel_data <- read_csv(here("data", "raw", "mWEL_Data.csv"))
hms_data  <- read_csv(here("data", "processed", "hms_processed_subset.csv"))

# ============================================================
# DATA PREPARATION - mWEL (EDUCATORS)
# ============================================================
mwel_analysis <- mwel_data %>%
  mutate(
    tech_score = rowMeans(select(., tech_1:tech_7), na.rm = TRUE),
    age_numeric = as.numeric(age),
    age_group = cut(age_numeric, breaks = c(-Inf, 24, 34, 44, 54, Inf),
                    labels = c("<25", "25–34", "35–44", "45–54", "55+"))
  ) %>%
  filter(!is.na(tech_score), !is.na(GAD7_Sum1)) %>%
  mutate(dataset = "Educators (mWEL)")

# ============================================================
# DATA PREPARATION - HMS (COLLEGE STUDENTS)
# ============================================================
hms_analysis <- hms_data %>%
  filter(!is.na(internet_1), !is.na(anx_score)) %>%
  mutate(
    usage_category = factor(internet_1,
                            levels = 1:8,
                            labels = c("None", "<1hr", "1–2hr", "2–3hr", "3–4hr", "4–6hr", "6–9hr", "10+hr")),
    dataset = "College Students (HMS)"
  )

# ============================================================
# UI
# ============================================================
ui <- navbarPage(
  title = "Tech Engagement & Mental Health",
  portfolio_css,

  # ==========================
  # OVERVIEW TAB
  # ==========================
  tabPanel("Overview",
    fluidPage(
      div(style = "max-width: 1000px; margin: 30px auto; padding: 0 20px;",

        h2("Research Overview"),

        p(
          strong("Dual-Study Analysis: "),
          "This dashboard synthesizes findings from two distinct populations studying the relationship between ",
          "technology engagement and mental health outcomes."
        ),

        div(class = "info-card",
          h4("Study 1: mWEL (Educators in Uganda)"),
          p("Low-resource setting exploring technology as a professional resource for teachers and parents."),
          span(class = "dataset-badge badge-mwel", "mWEL Dataset"),
          tags$ul(
            tags$li("Sample: Educators and parents in Uganda"),
            tags$li("Tech Measure: Composite score (tech_1–tech_7)"),
            tags$li("Outcome: GAD-7 anxiety severity"),
            tags$li("Context: Technology may buffer anxiety through streamlined communication")
          )
        ),

        div(class = "info-card",
          h4("Study 2: HMS (College Students in USA)"),
          p("National US survey examining daily internet/social media use and anxiety among adolescents/young adults."),
          span(class = "dataset-badge badge-hms", "HMS Dataset"),
          tags$ul(
            tags$li("Sample: U.S. college and university students (N = 34,953 analyzed)"),
            tags$li("Tech Measure: Daily internet/social media use (1-8 ordinal scale)"),
            tags$li("Outcome: GAD-7 anxiety severity (0–21)"),
            tags$li("Context: Excessive tech use may exacerbate anxiety through FOMO and social comparison")
          )
        ),

        h3("Research Questions"),
        tags$ul(
          tags$li("How does technology engagement relate to anxiety severity in two distinct populations?"),
          tags$li("Are patterns similar or different between educators (professional use) and students (personal use)?"),
          tags$li("What mechanisms might explain tech-anxiety relationships in each context?")
        ),

        hr(),

        p(style = "font-size: 12px; color: #7f8c8d;",
          strong("Analysis Date: "), format(Sys.Date(), "%B %d, %Y"), " | ",
          strong("Contact: "), "bauta.hana@gmail.com"
        )
      )
    )
  ),

  # ==========================
  # mWEL EDUCATORS TAB
  # ==========================
  tabPanel("Educators (mWEL)",
    sidebarLayout(
      sidebarPanel(width = 3,
        div(class = "sidebar-panel",
          p(class = "sidebar-label", "Filter by Age Group"),
          selectInput("age_filter", label = NULL,
                     choices = c("All", levels(mwel_analysis$age_group)))
        )
      ),

      mainPanel(width = 9,
        div(style = "padding: 20px;",
          h2("Technology Engagement by Age (Educators)"),

          plotOutput("boxplot_mwel", height = 420),
          br(),

          h3("Summary Statistics"),
          tableOutput("summary_mwel"),

          br(),

          h3("Tech vs Anxiety Association"),
          plotOutput("scatter_mwel", height = 400),

          br(),

          h3("Statistical Results"),
          verbatimTextOutput("correlation_mwel"),

          p(style = "font-size: 12px; color: #7f8c8d; margin-top: 15px;",
            "Pearson correlation measures linear association; p-value indicates statistical significance (α = 0.05)."
          )
        )
      )
    )
  ),

  # ==========================
  # HMS COLLEGE STUDENTS TAB
  # ==========================
  tabPanel("Students (HMS)",
    sidebarLayout(
      sidebarPanel(width = 3,
        div(class = "sidebar-panel",
          p(class = "sidebar-label", "Display Options"),
          checkboxInput("show_lm_hms", "Show Regression Line", TRUE),
          hr(),
          p(style = "font-size: 12px; color: #7f8c8d;",
            "Based on Healthy Minds Study 2024-25 (N = 34,953 with complete data)"
          )
        )
      ),

      mainPanel(width = 9,
        div(style = "padding: 20px;",
          h2("Internet/Social Media Use & Anxiety (College Students)"),

          p("Violin plots show the full distribution of anxiety scores at each usage level. ",
            "Wider sections indicate more students with that anxiety level; boxplots show median and quartiles."),

          plotOutput("usage_anxiety_hms", height = 450),
          br(),

          h3("Daily Usage Categories"),
          p("Summary statistics of GAD-7 anxiety scores stratified by daily internet/social media use categories."),
          tableOutput("usage_stats_hms"),

          br(),

          h3("Regression Analysis"),
          p("Linear regression with internet_1 (1-8 ordinal scale) as continuous predictor. ",
            "Tests whether daily usage level significantly predicts anxiety severity."),

          br(),

          plotOutput("regression_plot_hms", height = 420),

          br(),

          verbatimTextOutput("regression_hms"),

          p(style = "font-size: 12px; color: #7f8c8d; margin-top: 15px;",
            strong("Note: "), "This matches the analysis from Checkpoint 6 (VTPEH 6270). ",
            "The ordinal usage scale (1-8) is treated as continuous in the regression model."
          )
        )
      )
    )
  ),

  # ==========================
  # COMPARATIVE ANALYSIS TAB
  # ==========================
  tabPanel("Comparison",
    fluidPage(
      div(style = "max-width: 1000px; margin: 30px auto; padding: 0 20px;",

        h2("Cross-Population Comparison"),

        div(class = "info-card",
          h4("Key Comparison Points"),
          tags$ul(
            tags$li(
              strong("Context: "),
              "mWEL focuses on professional tech use (communication, work tools) while HMS examines leisure/social tech"
            ),
            tags$li(
              strong("Populations: "),
              "Educators in resource-limited settings (Uganda) vs. college students in high-income setting (USA)"
            ),
            tags$li(
              strong("Mechanisms: "),
              "Tech may buffer stress for educators through work support, but exacerbate for students through social comparison"
            ),
            tags$li(
              strong("Methodological: "),
              "Different measurement scales; mWEL uses composite score while HMS uses ordinal daily usage scale"
            )
          )
        ),

        h3("Expected Findings"),
        tags$ul(
          tags$li("mWEL: Weak or null association (tech as coping resource)"),
          tags$li("HMS: Positive association (higher use → higher anxiety)")
        ),

        h3("Implications"),
        p("The differential patterns across populations highlight that the tech-mental health relationship is not universal ",
          "but rather context- and purpose-dependent. Understanding these nuances is critical for designing interventions."),

        div(class = "highlight-box",
          h4("Next Steps"),
          p("Future analyses should examine: mediators (FOMO, social comparison), moderators (institutional support, choice), ",
            "and temporal dynamics (longitudinal follow-up) to elucidate mechanisms and inform prevention efforts.")
        )
      )
    )
  ),

  # ==========================
  # SIMULATION TAB
  # ==========================
  tabPanel("Power Analysis",
    sidebarLayout(
      sidebarPanel(width = 3,
        div(class = "sidebar-panel",
          p(class = "sidebar-label", "Simulation Parameters"),

          sliderInput("effect", "Effect Size (slope)", min = -2, max = 0, value = -0.7, step = 0.1),
          sliderInput("sample", "Sample Size", min = 50, max = 500, value = 150, step = 10),
          sliderInput("noise", "Noise (SD)", min = 1, max = 10, value = 4, step = 0.5)
        )
      ),

      mainPanel(width = 9,
        div(style = "padding: 20px;",
          h2("Statistical Power Analysis"),

          p("Explore how effect size, sample size, and measurement error affect statistical power ",
            "to detect relationships between technology use and anxiety."),

          plotOutput("sim_plot", height = 420),
          br(),

          div(class = "highlight-box",
            h4("Power Result"),
            textOutput("power_text")
          ),

          p(style = "font-size: 12px; color: #7f8c8d; margin-top: 15px;",
            "Simulated data generated from normal distributions with user-specified parameters. ",
            "P-value < 0.05 indicates statistical significance."
          )
        )
      )
    )
  )
)

# ============================================================
# SERVER
# ============================================================
server <- function(input, output) {

  # ------ mWEL FILTERED DATA ------
  mwel_filtered <- reactive({
    if (input$age_filter == "All") {
      mwel_analysis
    } else {
      mwel_analysis %>% filter(age_group == input$age_filter)
    }
  })

  # ====== mWEL PLOTS ======

  output$boxplot_mwel <- renderPlot({
    ggplot(mwel_filtered(),
           aes(x = fct_relevel(age_group, "<25", "25–34", "35–44", "45–54", "55+"),
               y = tech_score, fill = age_group)) +
      geom_boxplot(alpha = 0.85, outlier.alpha = 0.4) +
      geom_jitter(width = 0.15, alpha = 0.2, size = 1.5) +
      scale_fill_manual(values = palette_age) +
      labs(title = "Technology Engagement by Age Group (mWEL Educators)",
           x = "Age Group", y = "Tech Engagement Score") +
      theme_portfolio()
  })

  output$summary_mwel <- renderTable({
    mwel_filtered() %>%
      group_by(age_group) %>%
      summarise(n = n(),
                Mean = round(mean(tech_score, na.rm = TRUE), 2),
                SD = round(sd(tech_score, na.rm = TRUE), 2),
                Median = round(median(tech_score, na.rm = TRUE), 2),
                .groups = "drop") %>%
      rename("Age Group" = age_group, "N" = n)
  }, striped = TRUE, hover = TRUE)

  output$scatter_mwel <- renderPlot({
    ggplot(mwel_filtered(), aes(x = tech_score, y = GAD7_Sum1)) +
      geom_point(alpha = 0.5, size = 2.5, color = "#34495e") +
      geom_smooth(method = "lm", color = "#00b6ff", fill = "#aed6f1", se = TRUE, size = 1.1) +
      labs(title = "Tech Engagement vs Anxiety (mWEL Educators)",
           x = "Tech Engagement Score", y = "GAD-7 Anxiety Score") +
      theme_portfolio()
  })

  output$correlation_mwel <- renderPrint({
    result <- cor.test(mwel_filtered()$tech_score, mwel_filtered()$GAD7_Sum1)
    cat("PEARSON CORRELATION TEST (mWEL Educators)\n")
    cat("=========================================\n\n")
    cat("Sample Size (n):", nrow(mwel_filtered()), "\n")
    cat("Correlation Coefficient (r):", round(result$estimate, 3), "\n")
    cat("95% CI: [", round(result$conf.int[1], 3), ", ", round(result$conf.int[2], 3), "]\n")
    cat("T-statistic:", round(result$statistic, 3), "\n")
    cat("P-value:", format.pval(result$p.value, digits = 3), "\n\n")
    cat("Interpretation:", ifelse(result$p.value < 0.05, "Significant", "Not significant"),
        "at α = 0.05\n")
  })

  # ====== HMS PLOTS ======

  output$usage_anxiety_hms <- renderPlot({
    ggplot(hms_analysis, aes(x = fct_reorder(usage_category, internet_1),
                             y = anx_score, fill = usage_category)) +
      geom_violin(alpha = 0.7, color = NA) +
      geom_boxplot(width = 0.2, alpha = 0.9, color = "#1a1a2e", outlier.alpha = 0.3) +
      scale_fill_manual(values = palette_usage) +
      labs(title = "Daily Internet/Social Media Use vs Anxiety (HMS College Students)",
           subtitle = "Violin plot with boxplot overlay showing distribution shape and central tendency",
           x = "Daily Usage Category",
           y = "GAD-7 Anxiety Score (0–21)") +
      theme_portfolio() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  output$usage_stats_hms <- renderTable({
    hms_analysis %>%
      group_by(usage_category) %>%
      summarise(n = n(),
                Mean_GAD7 = round(mean(anx_score, na.rm = TRUE), 2),
                SD = round(sd(anx_score, na.rm = TRUE), 2),
                Median = round(median(anx_score, na.rm = TRUE), 1),
                .groups = "drop") %>%
      rename("Daily Usage Category" = usage_category, "N" = n)
  }, striped = TRUE, hover = TRUE)

  # ====== HMS REGRESSION PLOT ======

  output$regression_plot_hms <- renderPlot({
    ggplot(hms_analysis, aes(x = internet_1, y = anx_score)) +
      geom_jitter(alpha = 0.2, size = 1.5, width = 0.15, color = "#34495e") +
      geom_smooth(method = "lm", color = "#00b6ff", fill = "#aed6f1", se = TRUE, size = 1.1) +
      labs(
        title = "Regression: Daily Internet Use Predicting Anxiety",
        subtitle = "Linear regression with 95% confidence interval",
        x = "Daily Internet/Social Media Use Level (1=None, 8=10+ hours)",
        y = "GAD-7 Anxiety Score (0–21)"
      ) +
      theme_portfolio()
  })

  output$regression_hms <- renderPrint({
    model <- lm(anx_score ~ internet_1, data = hms_analysis)
    coef_table <- summary(model)$coefficients
    r2 <- summary(model)$r.squared
    n <- nrow(hms_analysis)

    cat("LINEAR REGRESSION: Daily Internet Use Predicting Anxiety\n")
    cat("===========================================================\n\n")
    cat("Sample Size (N):", n, "\n")
    cat("R-squared:", round(r2, 4),
        "(", round(r2*100, 2), "% of variance explained)\n\n")

    cat("COEFFICIENTS:\n")
    cat("─────────────────────────────────────────────────────────\n")
    print(coef_table, digits = 4)

    cat("\n\nINTERPRETATION:\n")
    cat("─────────────────────────────────────────────────────────\n")
    coef_internet <- coef_table[2, 1]
    pval <- coef_table[2, 4]
    cat("• For each unit increase in daily internet use (1→8 scale),\n")
    cat("  anxiety increases by", round(coef_internet, 3), "points on the GAD-7\n")
    cat("• This effect is", ifelse(pval < 0.05, "STATISTICALLY SIGNIFICANT", "NOT significant"),
        "(p =", round(pval, 4), ")\n")

    if (coef_internet > 0) {
      cat("• Direction: POSITIVE association (more use → higher anxiety)\n")
    } else {
      cat("• Direction: NEGATIVE association (more use → lower anxiety)\n")
    }

    if (r2 < 0.01) {
      cat("• Effect size: SMALL (explains <1% of variance)\n")
    } else if (r2 < 0.04) {
      cat("• Effect size: SMALL TO MODERATE\n")
    } else {
      cat("• Effect size: MODERATE TO LARGE\n")
    }
  })

  # ====== SIMULATION ======

  sim_data <- reactive({
    n <- input$sample
    b1 <- input$effect
    sigma <- input$noise

    tibble(
      tech = rnorm(n, mean = 3.5, sd = 1),
      anxiety = 10 + b1 * tech + rnorm(n, 0, sigma)
    )
  })

  output$sim_plot <- renderPlot({
    ggplot(sim_data(), aes(x = tech, y = anxiety)) +
      geom_point(alpha = 0.5, size = 2, color = "#34495e") +
      geom_smooth(method = "lm", color = "#00b6ff", fill = "#aed6f1", se = TRUE, size = 1.1) +
      labs(title = "Simulated Data: Power Demonstration",
           x = "Technology Engagement",
           y = "Anxiety Score") +
      theme_portfolio()
  })

  output$power_text <- renderText({
    model <- lm(anxiety ~ tech, data = sim_data())
    pval <- summary(model)$coefficients[2, 4]
    coef <- summary(model)$coefficients[2, 1]
    r2 <- summary(model)$r.squared

    paste0(
      "Regression Coefficient: ", round(coef, 3), " | ",
      "P-value: ", round(pval, 4), " | ",
      "R²: ", round(r2, 3), " | ",
      "Significant: ", ifelse(pval < 0.05, "✓ YES", "✗ NO")
    )
  })
}

# ============================================================
# RUN APP
# ============================================================
shinyApp(ui = ui, server = server)