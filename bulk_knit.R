# bulk_knit.R
# Knits all .Rmd files in this folder and subfolders to HTML.
# Usage: Open in RStudio and click Source, or run from the Modules folder.

library(rmarkdown)

# Set base path to this script's folder
# Change this if you move the script
base_dir <- "C:/Users/swest/Desktop/Teaching/NEW - PAF 512/Modules"

cat("Base directory:", base_dir, "\n")

# Find all Rmd files (case-insensitive)
rmds <- list.files(
  path = base_dir,
  # This looks for any file that ends in _WEB.Rmd (case-insensitive)
  pattern = "_[Ww][Ee][Bb]\\.[Rr][Mm][Dd]$",
  full.names = TRUE,
  recursive = TRUE
)

cat("Found", length(rmds), "Rmd files to knit.\n")

if (length(rmds) == 0) {
  stop("No .Rmd files found. Check the base_dir path.")
}

# Storage for summary
results <- data.frame(
  file = basename(rmds),
  folder = basename(dirname(rmds)),
  status = NA_character_,
  time_sec = NA_real_,
  stringsAsFactors = FALSE
)

cat("\n=== Bulk knitting started ===\n")
start_all <- Sys.time()

for (i in seq_along(rmds)) {
  rmd_file <- rmds[i]
  cat("\n[", i, "/", length(rmds), "] Knitting:", basename(rmd_file), "\n")

  t0 <- Sys.time()

  tryCatch(
    {
      render(rmd_file, quiet = TRUE)
      elapsed <- round(as.numeric(Sys.time() - t0, units = "secs"), 2)
      results$status[i] <- "success"
      results$time_sec[i] <- elapsed
      cat("  Done in", elapsed, "seconds\n")
    },
    error = function(e) {
      elapsed <- round(as.numeric(Sys.time() - t0, units = "secs"), 2)
      results$status[i] <<- "error"
      results$time_sec[i] <<- elapsed
      cat("  ERROR:", conditionMessage(e), "\n")
    }
  )
}

total_time <- round(as.numeric(Sys.time() - start_all, units = "secs"), 2)

cat("\n=== Bulk knitting finished ===\n")
cat("Total time:", total_time, "seconds\n\n")
print(results, row.names = FALSE)

failures <- sum(results$status == "error", na.rm = TRUE)
if (failures > 0) {
  cat("\n", failures, "file(s) failed. Review errors above.\n")
} else {
  cat("\nAll files knitted successfully.\n")
}
