# Data simulation for sampler comparison study
# AJ Brown
# 28 Feb 24

# load libraries
library(ggplot2)

simulate_data <- function(real_data_path, export_csv = FALSE, csv_path = "./1_data/simulated_data.csv") {
  # Load real data characteristics or define them directly if not using an external CSV
  if(file.exists(real_data_path)) {
    real.df <- read.csv(real_data_path)
  } else {
    stop("The specified file for real data does not exist.")
  }
  real.df <- real.df[real.df$event.type != 'Inflow',]
  real.df <- real.df[!real.df$event.count %in% c('Storm 1', 'Storm 2'),]
  
  # Key columns and summaries
  method.name <- unique(real.df$method.name)
  treatment <- unique(real.df$treatment)
  analyte_abbr <- unique(real.df$analyte_abbr)
  block <- as.factor(unique(real.df$block))
  event.count <- unique(real.df$event.count)
  
  # Create all combinations
  all_combinations <- expand.grid(event.count=event.count, analyte_abbr=analyte_abbr, 
                                  treatment=treatment, block=block, method.name=method.name)
  
  # Define offsets
  method_offsets <- list("Grab Sample" = 1, "Hourly Grab" = 1.1, "ISCO" = 0.9, "Low-Cost Sampler" = 0.85)
  treatment_offsets <- list("CT" = 1.2, "MT" = 1, "ST" = 0.8)
  event_offsets <- list("Irrigation 1" = 1.2, "Irrigation 2" = 1, "Irrigation 3" = 1, 
                        "Irrigation 4" = 0.9, "Irrigation 5" = 0.8)
  block_offsets <- list("1" = 1, "2" = 0.9)
  
  # Define adjust_mean function
  adjust_mean <- function(base_mean, method, treatment, event, blk) {
    adjusted_mean <- base_mean +
      (method_offsets[[as.character(method)]] - 1) * base_mean +
      (treatment_offsets[[as.character(treatment)]] - 1) * base_mean +
      (event_offsets[[as.character(event)]] - 1) * base_mean +
      (block_offsets[[as.character(blk)]] - 1) * base_mean
    return(adjusted_mean)
  }
  
  # Initialize an empty data frame for results
  results_df <- data.frame()
  
  # Simulate data
  for (i in 1:nrow(all_combinations)) {
    row <- all_combinations[i, ]
    analyte <- row$analyte_abbr
    base_means <- c(NO3 = 8, NO2 = 0.1, TKN = 5, pH = 7, TP = 0.8, OP = 0.3, EC = 0.15, TSS = 1000, TDS = 500)
    base_sd <- c(NO3 = 1, NO2 = 0.01, TKN = 1, pH = 0.1, TP = 0.1, OP = 0.05, EC = 0.01, TSS = 200, TDS = 50)
    
    adjusted_mean <- adjust_mean(base_means[analyte], row$method.name, row$treatment, row$event.count, row$block)
    original_result <- rnorm(1, mean = adjusted_mean, sd = base_sd[analyte])
    duplicate_result <- rnorm(1, mean = adjusted_mean, sd = base_sd[analyte])
    
    results_df <- rbind(results_df, cbind(row, result=original_result, duplicate=FALSE))
    results_df <- rbind(results_df, cbind(row, result=duplicate_result, duplicate=TRUE))
  }
  
  # Optionally export to CSV
  if (export_csv) {
    write.csv(results_df, file = csv_path, row.names = FALSE)
  }
  
  return(results_df)
}

# Example usage:
#simulated_data <- simulate_data(export_csv = TRUE, csv_path = "./1_data/simulated_data.csv")

# plot average of each analyte_abbr by method.name as bar graph
plot_results_by_method_and_analyte <- function(df, title = "Data") {
  # Ensure method.name and analyte_abbr are factors for proper plotting
  df$method.name <- as.factor(df$method.name)
  df$analyte_abbr <- as.factor(df$analyte_abbr)
  
  # Calculate mean and standard deviation for each method and analyte
  mean_df <- aggregate(result ~ method.name + analyte_abbr, data=df, FUN=mean)
  sd_df <- aggregate(result ~ method.name + analyte_abbr, data=df, FUN=sd, na.rm = TRUE)
  
  # Merge mean and standard deviation dataframes
  plot_df <- merge(mean_df, sd_df, by=c('method.name', 'analyte_abbr'))
  names(plot_df)[3:4] <- c("mean", "sd")
  
  # Create the plot
  p <- ggplot(plot_df, aes(x=method.name, y=mean, fill=analyte_abbr)) +
    geom_bar(stat="identity", position=position_dodge()) +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.2,
                  position=position_dodge(.9)) +
    labs(title=title, x="Method", y="Mean Result") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    facet_wrap(~analyte_abbr, scales="free_y") +
    theme(legend.position="none")
  
  return(p)
}

# Usage with simulated data
# p_simulated <- plot_results_by_method_and_analyte(
#   simulate_data("./1_data/real_data.csv",
#                 export_csv = TRUE,
#                 csv_path = "./1_data/simulated_data.csv"),
#   title = "Simulated Data")
# print(p_simulated)

# To use with real data, just pass your real data frame to the function
# Ensure your real data frame has the same structure, particularly the columns: method.name, analyte_abbr, and result
# p_real <- plot_results_by_method_and_analyte(real.df, title = "Real Data")
# print(p_real)

# plot average of each analyte_abbr by treatment as bar graph
plot_results_by_treatment_and_analyte <- function(df, title = "Data") {
  # Ensure treatment and analyte_abbr are factors for proper plotting
  df$treatment <- as.factor(df$treatment)
  df$analyte_abbr <- as.factor(df$analyte_abbr)
  
  # Calculate mean and standard deviation for each treatment and analyte
  mean_df <- aggregate(result ~ treatment + analyte_abbr, data=df, FUN=mean)
  sd_df <- aggregate(result ~ treatment + analyte_abbr, data=df, FUN=sd, na.rm = TRUE)
  
  # Merge mean and standard deviation dataframes
  plot_df <- merge(mean_df, sd_df, by=c('treatment', 'analyte_abbr'))
  names(plot_df)[3:4] <- c("mean", "sd")
  
  # Create the plot
  p <- ggplot(plot_df, aes(x=treatment, y=mean, fill=analyte_abbr)) +
    geom_bar(stat="identity", position=position_dodge()) +
    geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.2,
                  position=position_dodge(.9)) +
    labs(title=title, x="Treatment", y="Mean Result") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    facet_wrap(~analyte_abbr, scales="free_y") +
    theme(legend.position="none")
  
  return(p)
}


