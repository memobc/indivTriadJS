README
================
Kyle Kurkela
2023-04-11

This folder contains scripts used to analyze the data from the TRIADs
project.

The directory is organized by pilot, since there was a number of changes
from pilot to pilot. Specifically:

`pilot1/` = pilot 1 analysis scripts. `pilot2/` = pilot 2 analysis
scripts. `pilot3/` = pilot 3 analysis scripts. `pilot4/` = pilot 4
analysis scripts. `toolbox/` = custom R functions for analyzing the
data.

# Scripts

| Script                  | Description                                                                                                                                                                                                                                                                                                                                           | key output                                                                        |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| `pilot1/1_tidy.R`       | concatenates subject specific data files, separates the data into encoding and retrieval, and tidies for further analysis. Fixes two bugs present in the original stimulus presentation script – 1.) encoding and retrieval trials did not have a column linking the two together 2.) some stimuli were unintentionally presented in multiple TRIADs. | `pilot1/1_raw_concatenated.csv`, `pilot1/1_tidy_enc.csv`, `pilot1/1_tidy_ret.csv` |
| `pilot1/2_analysis.Rmd` | reads in the tidy data from the previous script, creates some graphs to visualize results.                                                                                                                                                                                                                                                            | `pilot1/1_analysis.html`                                                          |
| `pilot2/1_tidy.R`       | concatenates subject specific data files, separates the data into encoding and retrieval, and tidies for further analysis. No bugs in this pilot.                                                                                                                                                                                                     | `pilot2/1_raw_concatenated.csv`, `pilot2/1_tidy_enc.csv`, `pilot2/1_tidy_ret.csv` |
| `pilot2/2_analysis.Rmd` | reads in the tidy data from the previous script, creates some graphs to visualize results.                                                                                                                                                                                                                                                            | `pilot2/1_analysis.html`                                                          |
| `pilot3/1_tidy.R`       | minute. 1-59                                                                                                                                                                                                                                                                                                                                          |                                                                                   |
| `pilot3/2_analysis.Rmd` | second. 1-59                                                                                                                                                                                                                                                                                                                                          |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/2_analysis.Rmd` | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot1/2_analysis.Rmd` | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot1/2_analysis.Rmd` | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |
| `pilot4/1_tidy.R`       | subject identifier, extracted from URL                                                                                                                                                                                                                                                                                                                |                                                                                   |

# Data Cookbook

Data is written to the server in the following manner:

`MM-DD-YYYY-HH-MM-SS_SUBJECTID_experiment_data.csv`  
`MM-DD-YYYY-HH-MM-SS_SUBJECTID_interaction_data.csv`

where:

| Variable  | Description                            |
|-----------|----------------------------------------|
| MM        | month 1-12                             |
| DD        | day. 1-31                              |
| YYYY      | year. 2022+                            |
| HH        | hour. 1-24                             |
| MM        | minute. 1-59                           |
| SS        | second. 1-59                           |
| SUBJECTID | subject identifier, extracted from URL |

## Experiment Data

Below is a table describing what each column of raw experimental data
(`MM-DD-YYYY-HH-MM-SS_SUBJECTID_experiment_data.csv`) refers to:

| Variable Name      | Description                                                                                                                                                                                                                                       |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `rt`               | reaction time , measured in milliseconds.                                                                                                                                                                                                         |
| `stimulus`         | html string displayed during this event.                                                                                                                                                                                                          |
| `response`         | recorded response for this event. Note: the format of this response column depends on the event type. “survey-text” and “survey-likert” events, for example, record responses as json formatted text. Other events simply have numeric responses. |
| `phase`            | Kyle’s custom labels, assigning this event to an arbitrary experimental “phase”. Ex: Encoding, Retrieval, Demographics.                                                                                                                           |
| `trial_type`       | jsPsych event type. See website for further detail.                                                                                                                                                                                               |
| `trial_index`      | a bit of a misnomer. a better name would be “event index”. Number uniquely identifying each event in chronological order.                                                                                                                         |
| `time_elapsed`     | amount of time that has elapsed since the experiment was launched. Measued in milliseconds.                                                                                                                                                       |
| `internal_node_id` | unique identifier for each event, given by jsPsych toolbox. See the webpage for further information.                                                                                                                                              |
| `subject`          | unique numeric subject identifier, retrieved from the URL. Given to each participants by SONA.                                                                                                                                                    |
| `day`              | \[one,two\]. Which session does this data come from?                                                                                                                                                                                              |
| `success`          | Was the event successful? Only useful for certain trial_types (e.g., fullscreen_up, fullscreen_down)                                                                                                                                              |
| `url`              | external url. Only used for presenting the consent form.                                                                                                                                                                                          |
| `question_order`   | the randomized order in which the questions in the likert-survey trial_type was presented.                                                                                                                                                        |
| `view_history`     | a json formatted text string containing data tracking how long participants spent on instructions screens.                                                                                                                                        |
| `objOne`           | The object stimulus presented in position one (the lower left).                                                                                                                                                                                   |
| `objTwo`           | The object stimulus presented in position two (the lower right).                                                                                                                                                                                  |
| `key`              | The place/person stimulus presented in the top of the triad.                                                                                                                                                                                      |
| `encTrialNumber`   | numeric, unique to each encoding trial. Counts up from 0 in chronological order.                                                                                                                                                                  |
| `slider_start`     | What position, on a 1-100 scale, the slider started at. Only applies to the success ratings event from encoding.                                                                                                                                  |
| `resp_opt_1`       | object stimulus assigned to the first response key                                                                                                                                                                                                |
| `resp_opt_2`       | object stimulus assigned to the second response key                                                                                                                                                                                               |
| `resp_opt_3`       | object stimulus assigned to the third response key                                                                                                                                                                                                |
| `resp_opt_4`       | object stimulus assigned to the fourth response key                                                                                                                                                                                               |
| `resp_opt_5`       | object stimulus assigned to the fifth response key                                                                                                                                                                                                |
| `resp_opt_6`       | object stimulus assigned to the sixth response key                                                                                                                                                                                                |
| `enc_trial_index`  | the trial_index of the trial from encoding the corresponds to this retrieval trial.                                                                                                                                                               |

## Interaction Data

Below is a table describing what each column of the raw interaction data
(`MM-DD-YYYY-HH-MM-SS_SUBJECTID_experiment_data.csv`) refers to:

| Variable Name | Description                                                                     |
|---------------|---------------------------------------------------------------------------------|
| `event`       | string, label of the type of interaction event recorded.                        |
| `trial`       | trial_index this interaction event happened on.                                 |
| `time`        | amount of time, in milliseconds, elapsed since the beginning of the experiment. |
