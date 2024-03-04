# Data simulation for sampler comparison study
# AJ Brown
# 28 Feb 24

# load real data to get characteristics
real.df <- read.csv('./1_data/real_data.csv')

# clean the data prior to simulation for easy replication
# note that removing these values does no harm for final analysis
# drop inflow rows in event.type column
real.df <- real.df[real.df$event.type != 'Inflow',]
# drop Storm 1 and Storm 2 levels from event.count
real.df <- real.df[real.df$event.count != 'Storm 1',]
real.df <- real.df[real.df$event.count != 'Storm 2',]


# key columns and summaries
method.name <- unique(real.df$method.name)
treatment <- unique(real.df$treatment)
analyte_abbr <- unique(real.df$analyte_abbr)
block <- as.factor(unique(real.df$block))
event.count <- unique(real.df$event.count)

# Create all combinations
all_combinations <- expand.grid(event.count=event.count, 
                                analyte_abbr=analyte_abbr, 
                                treatment=treatment, 
                                block=block, 
                                method.name=method.name)

# Assuming we define some multiplicative offsets for demonstration
method_offsets <- list("Grab Sample" = 1, "Hourly Grab" = 1.1, "ISCO" = 0.9, 
                       "Low-Cost Sampler" = 0.85)
treatment_offsets <- list("CT" = 1.1, "MT" = 1, "ST" = 0.9)
event_offsets <- list("Irrigation 1" = 1.1, "Irrigation 2" = 1, 
                      "Irrigation 3" = 0.97, "Irrigation 4" = 0.95, 
                      "Irrigation 5" = 0.9)
block_offsets <- list("1" = 1, "2" = 0.9)

# Function to adjust mean based on method and treatment
adjust_mean <- function(base_mean, method, treatment, event, blk) {
  # Adjust mean based on method and treatment via multiplication
  adjusted_mean <- base_mean + 
    (method_offsets[[method]] - 1) * base_mean + 
    (treatment_offsets[[treatment]] - 1) * base_mean +
    (event_offsets[[event]] - 1) * base_mean +
    (block_offsets[[blk]] - 1) * base_mean
  return(adjusted_mean)
}

# Initialize an empty data frame for results
results_df <- data.frame(duplicate=logical(0))

# Iterate over each row of the combinations to simulate results and their duplicates
for (i in 1:nrow(all_combinations)) {
  row <- all_combinations[i, ]
  analyte <- row$analyte_abbr
  method <- row$method.name
  treatment <- row$treatment
  event <- row$event.count
  blk <- as.character(row$block)  # Convert factor to character for indexing
  
  # Base parameters for each analyte (you can adjust these as necessary)
  base_means <- c(NO3 = 8, NO2 = 0.1, TKN = 5, pH = 7, TP = 0.8, OP = 0.3, 
                  EC = 0.15, TSS = 1000, TDS = 500)
  base_sd <- c(NO3 = 1, NO2 = 0.01, TKN = 4, pH = 0.1, TP = 0.1, OP = 0.05, 
               EC = 0.01, TSS = 200, TDS = 50)
  
  # Adjust mean based on method, treatment, event count, and block
  adjusted_mean <- adjust_mean(base_means[analyte], method, treatment, event, blk)
  
  # Simulate original result using normal distribution
  original_result <- rnorm(1, mean = adjusted_mean, sd = base_sd[analyte])
  # Simulate duplicate result
  duplicate_result <- rnorm(1, mean = adjusted_mean, sd = base_sd[analyte])
  
  # Append original result to results dataframe
  results_df <- rbind(results_df, cbind(row, result=original_result, duplicate=FALSE))
  # Append duplicate result to results dataframe
  results_df <- rbind(results_df, cbind(row, result=duplicate_result, duplicate=TRUE))
}

# Write the results to a csv file
write.csv(results_df, file = "./1_data/sim_data.csv", row.names = FALSE)

View(results_df)

