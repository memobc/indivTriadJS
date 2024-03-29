# In order for this to run, the active project in R studio MUST be
# the analysis directory in the indivTriadsJS repository. You will
# get an error if not.
rstudioapi::getActiveProject()

rmarkdown::render('00_accounting.Rmd', output_file = 'accounting.html', output_dir = 'markdowns')
source('01_compile.R')
source('02_tidy_bds.R')
source('02_tidy_encoding.R')
source('02_tidy_surveys.R')
source('03_tidy_retrieval.R')
rmarkdown::render('04_check_subject_exclusions.Rmd', output_file = 'check_subject_exclusions.html', output_dir = 'markdowns')
rmarkdown::render('04_time_spent_analysis.Rmd', output_file = 'time_spent_analysis.html', output_dir = 'markdowns')
source('05_grade_cued_recall.R')
source('06_calculate_dependency.R')
rmarkdown::render('06_secondary_exclusions.Rmd', output_file = 'secondary_exclusions.html', output_dir = 'markdowns')
rmarkdown::render('07_recall_performance.Rmd', output_file = 'recall_performance.html', output_dir = 'markdowns')
source('08_key_analysis.R')
source('09_calculate_bias_index.R')
source('09_proportion_analysis.R')
rmarkdown::render('10_across_subjects_correlations.Rmd', output_file = 'across_subjects_correlations.html', output_dir = 'markdowns')
rmarkdown::render('10_explore_dependency.Rmd', output_file = 'explore_dependency.html', output_dir = 'markdowns')
rmarkdown::render('10_explore_proportion.Rmd', output_file = 'explore_proportion.html', output_dir = 'markdowns')
rmarkdown::render('10_explore_success.Rmd', output_file = 'explore_success.html', output_dir = 'markdowns')
rmarkdown::render('10_familiarity_ratings.Rmd', output_file = 'familiarity_ratings.html', output_dir = 'markdowns')
rmarkdown::render('10_survey_analysis.Rmd', output_file = 'survey_analysis.html', output_dir = 'markdowns')

# winsorize analyses

rmarkdown::render('07_winsor.Rmd', output_file = 'no_winsor.html', output_dir = 'markdowns', params = list(winsorLow = -1, winsorHigh = 2))
rmarkdown::render('07_winsor.Rmd', output_file = '05_95_winsor.html', output_dir = 'markdowns', params = list(winsorLow = 0.05, winsorHigh = 0.95))
rmarkdown::render('07_winsor.Rmd', output_file = '10_90_winsor.html', output_dir = 'markdowns', params = list(winsorLow = 0.1, winsorHigh = 0.9))
rmarkdown::render('07_winsor.Rmd', output_file = '25_75_winsor.html', output_dir = 'markdowns', params = list(winsorLow = 0.25, winsorHigh = 0.75))
