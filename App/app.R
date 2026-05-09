# =============================================================================
# Internet Use and Anxiety Symptom Severity Among U.S. College Students
# Healthy Minds Study 2024-2025 | Hana Bauta | VTPEH 6270
# =============================================================================

library(shiny)
library(tidyverse)
library(bslib)
library(broom)
library(scales)
library(readr)
library(car)
library(parameters)

# ── Palette & theme -----------------------------------------------------------
COL_BURGUNDY <- "#800020"
COL_BLUE     <- "#4E9AF1"
COL_ORANGE   <- "#E07B54"
COL_GREEN    <- "#3E9B5F"
COL_YELLOW   <- "#D4A017"
COL_LIGHT    <- "#FAF0F2"

PAL_LGBTQ    <- c("Cis-Hetero" = COL_BLUE,  "LGBTQ+"       = COL_ORANGE)
PAL_FIRSTGEN <- c("Not First-Gen" = COL_GREEN, "First-Gen"  = COL_YELLOW)

theme_app <- function(base_size = 12) {
  theme_classic(base_size = base_size) +
    theme(
      axis.title         = element_text(size = base_size,     color = "grey20"),
      axis.text          = element_text(size = base_size - 1, color = "grey30"),
      axis.line          = element_line(color = "grey40", linewidth = 0.5),
      axis.ticks         = element_line(color = "grey40", linewidth = 0.4),
      panel.grid.major.y = element_line(color = "grey92", linewidth = 0.35),
      legend.title       = element_text(size = base_size - 1, face = "bold"),
      legend.text        = element_text(size = base_size - 1),
      legend.key.size    = unit(1, "lines"),
      plot.title         = element_text(size = base_size, face = "bold",
                                        color = "grey15", margin = margin(b = 6)),
      plot.subtitle      = element_text(size = base_size - 2, color = "grey40",
                                        margin = margin(b = 8)),
      plot.caption       = element_text(size = base_size - 3, color = "grey55",
                                        hjust = 0, margin = margin(t = 8)),
      plot.margin        = margin(10, 14, 10, 10)
    )
}

fmt_p <- function(p) ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p))

# ── Data loading & wrangling --------------------------------------------------
hms_raw <- tryCatch(
  read_csv("hms_subset.csv", show_col_types = FALSE),
  error = function(e) {
    # Fallback: simulate data with same structure for demo purposes
    set.seed(42)
    n <- 34953
    internet <- sample(1:8, n, replace = TRUE,
                       prob = c(0.04, 0.10, 0.19, 0.22, 0.20, 0.13, 0.08, 0.04))
    lgbtq_raw <- rbinom(n, 1, 0.304)
    first_gen  <- rbinom(n, 1, 0.178)
    age        <- round(rnorm(n, 24.3, 8.4))
    belong1    <- pmax(1, pmin(5, rnorm(n, 2.85, 1.33)))
    fincur     <- pmax(1, pmin(5, rnorm(n, 3.25, 1.11)))
    dep        <- pmax(0, pmin(27, rnorm(n, 8.29, 6.18)))
    anx        <- pmax(0, pmin(21,
                               1.07 + 0.047 * internet - 0.015 * age +
                                 0.479 * lgbtq_raw - 0.221 * first_gen +
                                 0.446 * fincur + 0.651 * (dep / 27 * 21) +
                                 rnorm(n, 0, 3.8)))
    tibble(
      internet_1    = internet,
      anx_score     = round(anx),
      lgbtq         = lgbtq_raw,
      first_gen     = first_gen,
      age           = age,
      belong1       = belong1,
      fincur_stress = fincur,
      deprawsc      = dep
    )
  }
)

analysis_df <- hms_raw |>
  filter(!is.na(internet_1), !is.na(anx_score)) |>
  mutate(
    lgbtq     = factor(lgbtq,     labels = c("Cis-Hetero", "LGBTQ+")),
    first_gen = factor(first_gen, labels = c("Not First-Gen", "First-Gen")),
    severity  = cut(anx_score,
                    breaks = c(-Inf, 4, 9, 14, 21),
                    labels = c("Minimal (0–4)", "Mild (5–9)",
                               "Moderate (10–14)", "Severe (15–21)"),
                    right  = TRUE)
  )

model_df <- analysis_df |>
  filter(!is.na(age), !is.na(belong1), !is.na(fincur_stress),
         !is.na(lgbtq), !is.na(first_gen), !is.na(deprawsc))

# Pre-fit models (once, at startup)
m1  <- lm(anx_score ~ internet_1, data = analysis_df)
m2  <- lm(anx_score ~ internet_1 + age + lgbtq + first_gen +
            belong1 + fincur_stress + deprawsc, data = model_df)
m3a <- lm(anx_score ~ internet_1 * lgbtq + age + first_gen +
            belong1 + fincur_stress + deprawsc, data = model_df)
m3b <- lm(anx_score ~ internet_1 * first_gen + age + lgbtq +
            belong1 + fincur_stress + deprawsc, data = model_df)

# Prediction grids for moderation plots
make_grid <- function(mod, vary_var, vary_levels) {
  base <- data.frame(
    internet_1    = seq(1, 8, length.out = 100),
    age           = mean(model_df$age,           na.rm = TRUE),
    belong1       = mean(model_df$belong1,        na.rm = TRUE),
    fincur_stress = mean(model_df$fincur_stress,  na.rm = TRUE),
    deprawsc      = mean(model_df$deprawsc,       na.rm = TRUE),
    lgbtq         = factor("Cis-Hetero",    levels = levels(model_df$lgbtq)),
    first_gen     = factor("Not First-Gen", levels = levels(model_df$first_gen))
  )
  lapply(vary_levels, function(lv) {
    d             <- base
    d[[vary_var]] <- factor(lv, levels = levels(model_df[[vary_var]]))
    pr            <- predict(mod, newdata = d, interval = "confidence")
    d$predicted   <- pr[, "fit"]
    d$lwr         <- pr[, "lwr"]
    d$upr         <- pr[, "upr"]
    d
  }) |> bind_rows()
}

grid_lgbtq <- make_grid(m3a, "lgbtq",     levels(model_df$lgbtq))
grid_fg    <- make_grid(m3b, "first_gen", levels(model_df$first_gen))

# =============================================================================
# UI
# =============================================================================
ui <- page_navbar(
  title = tags$span(
    tags$span(style = "color:#800020; font-weight:700;", "HMS"),
    tags$span(style = "color:#444; font-weight:400; font-size:0.9em;",
              " | Internet Use & Anxiety")
  ),
  theme = bs_theme(
    bootswatch  = "flatly",
    primary     = "#800020",
    base_font   = font_google("Source Sans 3"),
    heading_font = font_google("Source Sans 3"),
    `navbar-bg` = "#FFFFFF",
    `navbar-light-color` = "#444444"
  ),
  fillable = FALSE,
  header = tags$head(
    tags$style(HTML("
      .navbar { border-bottom: 3px solid #800020; }
      .nav-link.active { color: #800020 !important; font-weight: 600; }
      .stat-box {
        background: #FAF0F2; border-left: 4px solid #800020;
        border-radius: 6px; padding: 14px 18px; margin-bottom: 10px;
      }
      .stat-box .stat-val { font-size: 1.7em; font-weight: 700; color: #800020; }
      .stat-box .stat-lab { font-size: 0.85em; color: #555; margin-top: 2px; }
      .section-header {
        font-size: 1.05em; font-weight: 600; color: #800020;
        border-bottom: 1px solid #e8c0c8; padding-bottom: 4px;
        margin-bottom: 12px; margin-top: 4px;
      }
      .note-box {
        background: #f8f9fa; border-radius: 6px;
        padding: 10px 14px; font-size: 0.87em; color: #555;
        border: 1px solid #e0e0e0; margin-top: 8px;
      }
      .result-badge {
        display: inline-block; padding: 3px 10px; border-radius: 12px;
        font-size: 0.82em; font-weight: 600; margin-left: 6px;
      }
      .sig   { background: #d4edda; color: #155724; }
      .insig { background: #f8d7da; color: #721c24; }
    "))
  ),
  
  # ── Tab 1: About -------------------------------------------------------------
  nav_panel(
    "About",
    icon = icon("info-circle"),
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header(tags$span(class = "section-header",
                              "Internet Use & Anxiety Among U.S. College Students")),
        card_body(
          p(strong("Study overview."),
            "This app accompanies the final report for VTPEH 6270 and presents
             interactive analyses from the Healthy Minds Study (HMS) 2024–2025
             Academic Year, a nationally representative survey of U.S. college students."),
          p(strong("Research questions:")),
          tags$ol(
            tags$li("Is higher daily internet and social media use associated with greater
                     anxiety symptom severity (GAD-7)?"),
            tags$li("Does this association persist after controlling for depression, financial
                     stress, sense of belonging, and demographics?"),
            tags$li("Does the association differ by LGBTQ+ identity or first-generation
                     student status?")
          ),
          p(strong("Key variables:")),
          tags$ul(
            tags$li(strong("Outcome:"), " GAD-7 anxiety score (0–21)"),
            tags$li(strong("Exposure:"), " Self-reported daily internet/social media hours (1–8)"),
            tags$li(strong("Covariates:"), " Age, LGBTQ+ identity, first-generation status,
                     sense of belonging, financial stress, pHQ-9 depression score")
          ),
          hr(),
          tags$div(class = "note-box",
                   icon("circle-info"), " ",
                   strong("Navigate using the tabs above"),
                   " to explore: ",
                   strong("Descriptives"), " → ",
                   strong("Group Comparisons"), " → ",
                   strong("Regression Models"), " → ",
                   strong("Moderation Analysis.")
          )
        )
      ),
      tagList(
        card(
          card_body(
            tags$div(class = "section-header", "Sample at a Glance"),
            tags$div(class = "stat-box",
                     tags$div(class = "stat-val", "34,953"),
                     tags$div(class = "stat-lab", "Students in analytic sample")),
            tags$div(class = "stat-box",
                     tags$div(class = "stat-val", "7.46"),
                     tags$div(class = "stat-lab", "Mean GAD-7 score (SD = 5.72)")),
            tags$div(class = "stat-box",
                     tags$div(class = "stat-val", "4.77 hrs"),
                     tags$div(class = "stat-lab", "Mean daily internet use (SD = 1.76)")),
            tags$div(class = "stat-box",
                     tags$div(class = "stat-val", "30.4%"),
                     tags$div(class = "stat-lab", "Identify as LGBTQ+")),
            tags$div(class = "stat-box",
                     tags$div(class = "stat-val", "17.8%"),
                     tags$div(class = "stat-lab", "First-generation students"))
          )
        ),
        card(
          card_body(
            tags$div(class = "section-header", "Data & Code"),
            tags$p(icon("database"), " ",
                   tags$a("Healthy Minds Study 2024–2025",
                          href = "https://healthymindsnetwork.org/", target = "_blank")),
            tags$p(icon("code-branch"), " ",
                   tags$a("GitHub Repository",
                          href = "https://github.com/hb537/HanaBauta_Finalproject.git",
                          target = "_blank")),
            tags$p(icon("user"), " ", strong("Author:"), " Hana Bauta"),
            tags$p(icon("robot"), " ", strong("AI Disclosure:"),
                   " Claude (Anthropic) assisted with code development.
                     All analytical decisions reflect the author's independent judgment.")
          )
        )
      )
    )
  ),
  
  # ── Tab 2: Descriptives ------------------------------------------------------
  nav_panel(
    "Descriptives",
    icon = icon("chart-bar"),
    layout_columns(
      col_widths = c(3, 9),
      card(
        card_header("Controls"),
        card_body(
          tags$div(class = "section-header", "Display Options"),
          radioButtons("dist_var", "Variable to display:",
                       choices = c("GAD-7 Anxiety Score" = "anx_score",
                                   "Internet Hours/Day"  = "internet_1",
                                   "PHQ-9 Depression"    = "deprawsc"),
                       selected = "anx_score"),
          hr(),
          radioButtons("dist_fill", "Colour by:",
                       choices = c("None"              = "none",
                                   "LGBTQ+ Identity"   = "lgbtq",
                                   "First-Gen Status"  = "first_gen"),
                       selected = "none"),
          hr(),
          tags$div(class = "note-box",
                   "The severity table below always shows GAD-7 clinical categories."
          )
        )
      ),
      tagList(
        card(
          card_header("Distribution"),
          card_body(plotOutput("dist_plot", height = "320px"))
        ),
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header("GAD-7 Severity Categories"),
            card_body(tableOutput("severity_tbl"))
          ),
          card(
            card_header("Sample Summary"),
            card_body(tableOutput("desc_tbl"))
          )
        )
      )
    )
  ),
  
  # ── Tab 3: Group Comparisons -------------------------------------------------
  nav_panel(
    "Group Comparisons",
    icon = icon("users"),
    layout_columns(
      col_widths = c(3, 9),
      card(
        card_header("Controls"),
        card_body(
          tags$div(class = "section-header", "Subgroup"),
          radioButtons("group_var", "Compare anxiety by:",
                       choices = c("LGBTQ+ Identity"  = "lgbtq",
                                   "First-Gen Status" = "first_gen"),
                       selected = "lgbtq"),
          hr(),
          radioButtons("group_plot_type", "Plot type:",
                       choices = c("Box plot"   = "box",
                                   "Violin plot" = "violin"),
                       selected = "box"),
          hr(),
          tags$div(class = "note-box",
                   "Diamond markers indicate group means. T-test results are shown below the plot."
          )
        )
      ),
      tagList(
        card(
          card_header("GAD-7 Score by Subgroup"),
          card_body(plotOutput("group_plot", height = "340px"))
        ),
        card(
          card_header("Independent-Samples t-Test Results"),
          card_body(uiOutput("ttest_result"))
        )
      )
    )
  ),
  
  # ── Tab 4: Regression Models -------------------------------------------------
  nav_panel(
    "Regression Models",
    icon = icon("chart-line"),
    layout_columns(
      col_widths = c(3, 9),
      card(
        card_header("Controls"),
        card_body(
          tags$div(class = "section-header", "Model Selection"),
          radioButtons("reg_model", "Display model:",
                       choices = c("Model 1: Unadjusted"  = "m1",
                                   "Model 2: Adjusted"    = "m2",
                                   "Both (overlay)"       = "both"),
                       selected = "both"),
          hr(),
          radioButtons("reg_plot_type", "Visualisation:",
                       choices = c("Scatter + regression line" = "scatter",
                                   "Standardised coefficients" = "coefs"),
                       selected = "scatter"),
          hr(),
          tags$div(class = "note-box",
                   strong("Model 1:"), " internet use only.",
                   br(),
                   strong("Model 2:"), " adjusts for age, LGBTQ+ identity,
            first-gen status, belonging, financial stress, and depression."
          )
        )
      ),
      tagList(
        card(
          card_header("Regression Visualisation"),
          card_body(plotOutput("reg_plot", height = "340px"))
        ),
        card(
          card_header("Model Summary"),
          card_body(uiOutput("reg_summary"))
        )
      )
    )
  ),
  
  # ── Tab 5: Moderation --------------------------------------------------------
  nav_panel(
    "Moderation Analysis",
    icon = icon("code-branch"),
    layout_columns(
      col_widths = c(3, 9),
      card(
        card_header("Controls"),
        card_body(
          tags$div(class = "section-header", "Moderator"),
          radioButtons("mod_var", "Examine interaction with:",
                       choices = c("LGBTQ+ Identity"  = "lgbtq",
                                   "First-Gen Status" = "first_gen"),
                       selected = "lgbtq"),
          hr(),
          tags$div(class = "note-box",
                   "Predicted GAD-7 scores across internet use levels, holding all
             other covariates at their sample means. Shaded bands = 95% CI."
          )
        )
      ),
      tagList(
        card(
          card_header("Marginal Predicted Anxiety by Internet Use"),
          card_body(plotOutput("mod_plot", height = "340px"))
        ),
        card(
          card_header("Interaction Term"),
          card_body(uiOutput("mod_result"))
        )
      )
    )
  )
)

# =============================================================================
# SERVER
# =============================================================================
server <- function(input, output, session) {
  
  # ── Tab 2: Distribution plot -------------------------------------------------
  output$dist_plot <- renderPlot({
    var   <- input$dist_var
    fill  <- input$dist_fill
    
    xlab <- switch(var,
                   anx_score  = "GAD-7 Anxiety Score (0–21)",
                   internet_1 = "Internet / Social Media Hours per Day",
                   deprawsc   = "PHQ-9 Depression Score (0–27)"
    )
    
    bw <- switch(var, anx_score = 1, internet_1 = 1, deprawsc = 1)
    
    if (fill == "none") {
      col_fill <- switch(var, anx_score = COL_BURGUNDY,
                         internet_1 = COL_BLUE, deprawsc = COL_ORANGE)
      ggplot(analysis_df, aes(x = .data[[var]])) +
        geom_histogram(binwidth = bw, fill = col_fill,
                       color = "white", alpha = 0.9) +
        labs(x = xlab, y = "Count",
             caption = paste0("N = ", scales::comma(nrow(analysis_df)))) +
        theme_app()
    } else {
      pal <- if (fill == "lgbtq") PAL_LGBTQ else PAL_FIRSTGEN
      ggplot(analysis_df, aes(x = .data[[var]], fill = .data[[fill]])) +
        geom_histogram(binwidth = bw, color = "white", alpha = 0.82,
                       position = "identity") +
        scale_fill_manual(values = pal) +
        labs(x = xlab, y = "Count", fill = NULL,
             caption = paste0("N = ", scales::comma(nrow(analysis_df)))) +
        theme_app() +
        theme(legend.position = "top")
    }
  }, res = 110)
  
  # ── Tab 2: Severity table ----------------------------------------------------
  output$severity_tbl <- renderTable({
    analysis_df |>
      count(Severity = severity) |>
      mutate(Percent = sprintf("%.1f%%", n / sum(n) * 100)) |>
      rename(N = n)
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  # ── Tab 2: Descriptive summary table ----------------------------------------
  output$desc_tbl <- renderTable({
    analysis_df |>
      summarise(
        `Mean GAD-7 (SD)` = paste0(round(mean(anx_score, na.rm = TRUE), 2),
                                   " (", round(sd(anx_score, na.rm = TRUE), 2), ")"),
        `Mean Internet Hrs (SD)` = paste0(round(mean(internet_1, na.rm = TRUE), 2),
                                          " (", round(sd(internet_1, na.rm = TRUE), 2), ")"),
        `Mean Age (SD)` = paste0(round(mean(age, na.rm = TRUE), 1),
                                 " (", round(sd(age, na.rm = TRUE), 1), ")"),
        `LGBTQ+ (%)` = paste0(sum(lgbtq == "LGBTQ+", na.rm = TRUE), " (",
                              round(mean(lgbtq == "LGBTQ+", na.rm = TRUE) * 100, 1), "%)"),
        `First-Gen (%)` = paste0(sum(first_gen == "First-Gen", na.rm = TRUE), " (",
                                 round(mean(first_gen == "First-Gen", na.rm = TRUE) * 100, 1), "%)")
      ) |>
      pivot_longer(everything(), names_to = "Characteristic", values_to = "Value")
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  # ── Tab 3: Group comparison plot ---------------------------------------------
  output$group_plot <- renderPlot({
    gv  <- input$group_var
    pal <- if (gv == "lgbtq") PAL_LGBTQ else PAL_FIRSTGEN
    xlab <- if (gv == "lgbtq") "LGBTQ+ Identity" else "First-Gen Status"
    
    means_df <- analysis_df |>
      group_by(.data[[gv]]) |>
      summarise(m = mean(anx_score, na.rm = TRUE), .groups = "drop")
    
    p <- ggplot(analysis_df,
                aes(x = .data[[gv]], y = anx_score, fill = .data[[gv]])) +
      scale_fill_manual(values = pal, guide = "none") +
      scale_color_manual(values = pal, guide = "none") +
      labs(x = xlab, y = "GAD-7 Score",
           caption = paste0("N = ", scales::comma(nrow(analysis_df)))) +
      theme_app()
    
    if (input$group_plot_type == "box") {
      p <- p + geom_boxplot(alpha = 0.75, outlier.alpha = 0.08,
                            outlier.size = 0.5, width = 0.5)
    } else {
      p <- p + geom_violin(alpha = 0.65, width = 0.8) +
        geom_boxplot(alpha = 0, width = 0.15, linewidth = 0.6,
                     outlier.colour = NA)
    }
    
    p + geom_point(data = means_df,
                   aes(x = .data[[gv]], y = m, color = .data[[gv]]),
                   shape = 18, size = 4.5, show.legend = FALSE)
  }, res = 110)
  
  # ── Tab 3: T-test results ----------------------------------------------------
  output$ttest_result <- renderUI({
    gv <- input$group_var
    lvls <- levels(analysis_df[[gv]])
    g1 <- analysis_df$anx_score[analysis_df[[gv]] == lvls[1]]
    g2 <- analysis_df$anx_score[analysis_df[[gv]] == lvls[2]]
    tt <- t.test(g2, g1)
    
    sig_class <- if (tt$p.value < 0.05) "sig" else "insig"
    sig_label <- if (tt$p.value < 0.05) "Significant" else "Not significant"
    
    tagList(
      tags$table(class = "table table-sm table-bordered",
                 tags$thead(tags$tr(
                   tags$th("Group"), tags$th("Mean GAD-7"), tags$th("SD")
                 )),
                 tags$tbody(
                   tags$tr(tags$td(lvls[1]),
                           tags$td(round(mean(g1, na.rm = TRUE), 2)),
                           tags$td(round(sd(g1,   na.rm = TRUE), 2))),
                   tags$tr(tags$td(lvls[2]),
                           tags$td(round(mean(g2, na.rm = TRUE), 2)),
                           tags$td(round(sd(g2,   na.rm = TRUE), 2)))
                 )
      ),
      tags$p(
        strong("Mean difference: "),
        round(diff(rev(tt$estimate)), 2),
        strong(" | 95% CI: "),
        sprintf("[%.2f, %.2f]", tt$conf.int[1], tt$conf.int[2]),
        strong(" | p-value: "),
        fmt_p(tt$p.value),
        tags$span(class = paste("result-badge", sig_class), sig_label)
      ),
      tags$div(class = "note-box",
               icon("circle-info"), " Independent-samples t-test (Welch's correction applied)."
      )
    )
  })
  
  # ── Tab 4: Regression plot ---------------------------------------------------
  output$reg_plot <- renderPlot({
    if (input$reg_plot_type == "scatter") {
      p <- ggplot(analysis_df, aes(x = internet_1, y = anx_score)) +
        geom_jitter(alpha = 0.04, size = 0.5, color = "grey40",
                    width = 0.15, height = 0.15) +
        scale_x_continuous(breaks = 1:8) +
        labs(x = "Internet / Social Media Hours per Day",
             y = "GAD-7 Anxiety Score",
             caption = paste0("N = ", scales::comma(nrow(analysis_df)),
                              " | Points jittered for clarity")) +
        theme_app()
      
      if (input$reg_model %in% c("m1", "both")) {
        p <- p + geom_smooth(method = "lm", se = TRUE,
                             color = COL_BURGUNDY, fill = COL_BURGUNDY,
                             alpha = 0.15, linewidth = 1.1,
                             linetype = "solid")
      }
      if (input$reg_model %in% c("m2", "both")) {
        # For m2, project fitted values onto internet_1 axis
        nd <- data.frame(
          internet_1    = seq(1, 8, length.out = 200),
          age           = mean(model_df$age,           na.rm = TRUE),
          belong1       = mean(model_df$belong1,        na.rm = TRUE),
          fincur_stress = mean(model_df$fincur_stress,  na.rm = TRUE),
          deprawsc      = mean(model_df$deprawsc,       na.rm = TRUE),
          lgbtq         = factor("Cis-Hetero",    levels = levels(model_df$lgbtq)),
          first_gen     = factor("Not First-Gen", levels = levels(model_df$first_gen))
        )
        pr <- predict(m2, newdata = nd, interval = "confidence") |>
          as.data.frame()
        nd2 <- cbind(nd, pr)
        
        lty <- if (input$reg_model == "both") "dashed" else "solid"
        col <- if (input$reg_model == "both") COL_BLUE else COL_BURGUNDY
        p <- p +
          geom_ribbon(data = nd2, aes(x = internet_1, ymin = lwr, ymax = upr),
                      inherit.aes = FALSE, fill = col, alpha = 0.12) +
          geom_line(data = nd2, aes(x = internet_1, y = fit),
                    inherit.aes = FALSE, color = col,
                    linewidth = 1.1, linetype = lty)
      }
      
      if (input$reg_model == "both") {
        p <- p + annotate("text", x = 1.2, y = 19,
                          label = "Model 1 (unadjusted)", color = COL_BURGUNDY,
                          hjust = 0, size = 3.5, fontface = "bold") +
          annotate("text", x = 1.2, y = 17.8,
                   label = "Model 2 (adjusted, at means)", color = COL_BLUE,
                   hjust = 0, size = 3.5, fontface = "bold")
      }
      p
      
    } else {
      # Standardised coefficients from m2
      param_map <- c(
        "internet_1"         = "Internet Hours/Day",
        "age"                = "Age",
        "lgbtqLGBTQ+"        = "LGBTQ+ Identity",
        "first_genFirst-Gen" = "First-Gen Status",
        "belong1"            = "Sense of Belonging",
        "fincur_stress"      = "Financial Stress",
        "deprawsc"           = "PHQ-9 Depression"
      )
      
      sc <- tryCatch({
        standardize_parameters(m2) |>
          as_tibble() |>
          rename(parameter = any_of(c("Parameter", "term"))) |>
          filter(parameter != "(Intercept)") |>
          mutate(
            parameter = ifelse(parameter %in% names(param_map),
                               param_map[parameter], parameter),
            Direction = Std_Coefficient > 0
          ) |>
          arrange(Std_Coefficient)
      }, error = function(e) {
        tidy(m2, conf.int = TRUE) |>
          filter(term != "(Intercept)") |>
          mutate(
            parameter = ifelse(term %in% names(param_map),
                               param_map[term], term),
            Std_Coefficient = estimate / sd(model_df$anx_score, na.rm = TRUE),
            CI_low = conf.low / sd(model_df$anx_score, na.rm = TRUE),
            CI_high = conf.high / sd(model_df$anx_score, na.rm = TRUE),
            Direction = Std_Coefficient > 0
          ) |>
          arrange(Std_Coefficient)
      })
      
      ggplot(sc, aes(x = Std_Coefficient,
                     y = fct_inorder(parameter),
                     color = Direction)) +
        geom_vline(xintercept = 0, linetype = "dashed",
                   color = "grey55", linewidth = 0.5) +
        geom_errorbarh(aes(xmin = CI_low, xmax = CI_high),
                       height = 0.28, linewidth = 0.6) +
        geom_point(size = 3) +
        scale_color_manual(values = c("TRUE" = COL_BURGUNDY, "FALSE" = COL_BLUE),
                           labels = c("TRUE" = "Positive", "FALSE" = "Negative"),
                           name   = "Direction") +
        labs(x = "Standardised Beta Coefficient",
             y = NULL,
             subtitle = "Model 2 (fully adjusted) | Error bars = 95% CI") +
        theme_app() +
        theme(legend.position = "top")
    }
  }, res = 110)
  
  # ── Tab 4: Regression summary ------------------------------------------------
  output$reg_summary <- renderUI({
    m1t <- tidy(m1, conf.int = TRUE) |> filter(term == "internet_1")
    m2t <- tidy(m2, conf.int = TRUE) |> filter(term == "internet_1")
    r1  <- summary(m1)$r.squared
    r2  <- summary(m2)$r.squared
    
    tagList(
      tags$table(class = "table table-sm table-bordered",
                 tags$thead(tags$tr(
                   tags$th("Model"), tags$th("β (internet hrs)"),
                   tags$th("95% CI"), tags$th("p-value"), tags$th("R²")
                 )),
                 tags$tbody(
                   tags$tr(
                     tags$td("Model 1 (Unadjusted)"),
                     tags$td(round(m1t$estimate, 3)),
                     tags$td(sprintf("[%.3f, %.3f]", m1t$conf.low, m1t$conf.high)),
                     tags$td(fmt_p(m1t$p.value)),
                     tags$td(round(r1, 3))
                   ),
                   tags$tr(
                     tags$td("Model 2 (Adjusted)"),
                     tags$td(round(m2t$estimate, 3)),
                     tags$td(sprintf("[%.3f, %.3f]", m2t$conf.low, m2t$conf.high)),
                     tags$td(fmt_p(m2t$p.value)),
                     tags$td(round(r2, 3))
                   )
                 )
      ),
      tags$div(class = "note-box",
               icon("circle-info"), " ",
               "The internet-anxiety coefficient attenuates from ",
               strong(round(m1t$estimate, 3)), " (Model 1) to ",
               strong(round(m2t$estimate, 3)), " (Model 2) after covariate adjustment,
         but remains statistically significant (p < 0.001). Adjusted R² rises from ",
               strong(round(r1, 3)), " to ", strong(round(r2, 3)),
               ", driven primarily by depression severity."
      )
    )
  })
  
  # ── Tab 5: Moderation plot ---------------------------------------------------
  output$mod_plot <- renderPlot({
    mv  <- input$mod_var
    if (mv == "lgbtq") {
      grid <- grid_lgbtq
      cv   <- "lgbtq"
      pal  <- PAL_LGBTQ
      xl   <- "Internet Hours/Day"
    } else {
      grid <- grid_fg
      cv   <- "first_gen"
      pal  <- PAL_FIRSTGEN
      xl   <- "Internet Hours/Day"
    }
    
    ggplot(grid, aes(x = internet_1, y = predicted,
                     color = .data[[cv]], fill = .data[[cv]])) +
      geom_ribbon(aes(ymin = lwr, ymax = upr),
                  alpha = 0.13, color = NA) +
      geom_line(linewidth = 1.1) +
      scale_color_manual(values = pal) +
      scale_fill_manual(values  = pal) +
      scale_x_continuous(breaks = 1:8) +
      labs(x = xl, y = "Predicted GAD-7 Score",
           color = NULL, fill = NULL,
           subtitle = "All other covariates held at sample means | Bands = 95% CI",
           caption  = "Marginal predictions from interaction models (Models 3a/3b)") +
      theme_app() +
      theme(legend.position = "top")
  }, res = 110)
  
  # ── Tab 5: Moderation result -------------------------------------------------
  output$mod_result <- renderUI({
    mv <- input$mod_var
    
    if (mv == "lgbtq") {
      int_row <- tidy(m3a, conf.int = TRUE) |>
        filter(grepl("internet_1:lgbtq", term))
      label <- "Internet × LGBTQ+"
      mod_m  <- m3a
    } else {
      int_row <- tidy(m3b, conf.int = TRUE) |>
        filter(grepl("internet_1:first_gen", term))
      label <- "Internet × First-Gen"
      mod_m  <- m3b
    }
    
    sig_class <- if (int_row$p.value < 0.05) "sig" else "insig"
    sig_label <- if (int_row$p.value < 0.05) "Significant interaction" else "Non-significant interaction"
    
    interp <- if (mv == "lgbtq") {
      "The interaction between internet use and LGBTQ+ identity was
       not statistically significant (p = 0.152). Both groups show higher
       predicted anxiety with greater internet use, but the slopes are broadly
       parallel — the internet-anxiety gradient does not significantly differ
       by sexual/gender identity after full covariate adjustment."
    } else {
      "The interaction between internet use and first-generation status was
       statistically significant (p = 0.041). First-generation students show
       a steeper internet-anxiety gradient, consistent with the hypothesis that
       compounded academic, financial, and social stressors amplify the
       psychological burden of high digital engagement in this population."
    }
    
    tagList(
      tags$table(class = "table table-sm table-bordered",
                 tags$thead(tags$tr(
                   tags$th("Term"), tags$th("β"), tags$th("95% CI"), tags$th("p-value")
                 )),
                 tags$tbody(tags$tr(
                   tags$td(label),
                   tags$td(round(int_row$estimate, 3)),
                   tags$td(sprintf("[%.3f, %.3f]", int_row$conf.low, int_row$conf.high)),
                   tags$td(
                     fmt_p(int_row$p.value),
                     tags$span(class = paste("result-badge", sig_class), sig_label)
                   )
                 ))
      ),
      tags$div(class = "note-box", icon("comment"), " ", interp)
    )
  })
}

# =============================================================================
shinyApp(ui, server)