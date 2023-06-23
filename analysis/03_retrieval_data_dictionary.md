---
output:
  pdf_document: default
  html_document: default
---

# Data Description

This is the retrieval data from the TRIADs study. In the TRIADs study, participants studied 24 triads that consisted of three words presented in a triangle. Two of the words were common objects. One word was either a famous person OR a famous place. Participant's goal was to imagine a scenario linking the famous person/famous place to the two objects. They were later tested on their memory for the TRIADs. In the memory test, participants were presented with one of the words from the TRIAD and were asked if they could remember the other two words.

The `retrieval_tidy.xlsx` contains data from 61 subjects. 49/61 subjects completed session 1 and session 2. 2/61 do not have data from session 1. 10/61 did not come back for session 2.

Every row of the `retrieval_tidy.xlsx` file corresponds to retrieval trial. The columns are described below:  

# Data Dictionary

| variable                   | varType                                        | description |
| ----------                 | ------                                     | ---------------------- |
| `subject_id`               | **string**.  | randomized identifier provided by Prolific. Uniquely identifies participants. |
| `study_id`                 | **string**.  | randomized identifier provided by Prolific. Uniquely identifies Prolific studies. |
| `subject_id`               | **string**.  | randomized identifier provided by Prolific. Uniquely identifies participants/study combinations. |
| `session`                  | **factor**.  | Identifies the Prolific study as either the first or second session. Levels: [`session1`, `session2`]. |
| `trial_index`              | **integer**. | jsPsych provided variable that uniquely identifies every "event" in a study. Starts from 0 and counts up in chronological order. |
| `time_elapsed`             | **double**.  | The amount of time that has elapsed since the beginning of the experiment to when this event begins. In milliseconds. |
| `rt`                       | **double**.  | The amount of time between when the trial started and when the participants hit "submit". In milliseconds. |
| `encTrialNum`              | **integer**. | The encoding trial number that this retrieval trial is asking about. Starts from 1. |
| `ret_probe`                | **string**.  | Retrieval probe. The word used to cue participants recall -- "What went with x?" |
| `ret_resp_1`               | **string**.  | What participants typed in to the first text box. |
| `ret_resp_2`               | **string**.  | What participants typed in to the second text box. |
| `trial_index_enc_pres`     | **integer**. | The jsPsych trial_index corresponding to the presentation event from the encoding trial this retrieval trial is asking about. |
| `time_elapsed_enc_pres`    | **double**.  | The amount of time that has elapsed since the beginning of the experiment to when the encoding trial corresponding to this retrieval trial began. In milliseconds. |
| `objOne`                   | **string**.  | The word that appeared in the lower left corner of the encoding TRIAD. |
| `objTwo`                   | **string**.  | The word that appeared in the lower right corner of the encoding TRIAD. |
| `key`                      | **string**.  | The word that appeared in the top of the encoding TRIAD. |
| `condition`                | **factor**.  | Was this a famous person or famous place TRIAD? Levels: [`famous person`, `famous place`] |
| `trial_index_enc_slider`   | **integer**. | The jsPsych trial_index corresponding to the slider event from the encoding trial this retrieval trial is asking about. |
| `rt_slider`                | **double**.  | The amount of time between when the encoding slider event started and when the participants hit "submit". In milliseconds. |
| `response_slider`          | **integer**. | On a scale of 0-100, where the participants marked on a slider their success in imagining the encoding TRIAD. |
| `time_elapsed_enc_slider`  | **integer**. | The amount of time that has elapsed since the beginning of the experiment to when the slider event of the encoding trial corresponding to this retrieval trial began. In milliseconds. |

# Task Description

The goal of this task is to grade participants' cued recalls. In other words, compare the `ret_resp_1` and `ret_resp_2` columns with the correct answers in the `objOne`, `objTwo`, and `key` columns.  

1. Create new columns `ret_resp_1_isCorrect` and `ret_resp_2_isCorrect`.
2. Go through each row of the `retrieval_tidy.xlsx` excel sheet and mark a 1 if the response was correct and 0 is the response was incorrect. Mark a "?" if you are unsure for any reason.

When grading, use your best judgement. Participants must uniquely identify the correct answer in order to be considered correct. For example, if one of the correct answers was "Times Square, New York" and they just put "New York" that would be incorrect -- there are multiple possible answers that involve New York (for example: Central Park, New York). They did not identify the correct answer uniquely.

Spelling does NOT matter. As long as they are in the ballpark.  