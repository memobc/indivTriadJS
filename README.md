# TRIADs

Repostiory home of the [Memory Modulation Lab's](http://www.thememolab.org/) TRIADs Study.

The TRIADs Study was an online behavioral experiment designed to test a neuroscience inspired hypothesis on the organization of individual differences in memory. This experiment served as the 3 chapter of Kyle Kurkela's dissertation.

## Directories

| directory    | explanation                                                                                                                                                                                                             |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `./analysis` | contains all scripts related to analyzing data collected for the final version of the experiment.                                                                                                                       |
| `./consents` | contains `html` and `pdf` versions of online consent forms from two different IRBs. See `./consents/README.md` for more information.                                                                                    |
| `./data`     | houses the data for the experiment. note: the data files are included in the `.gitignore` file and are NOT tracked by git. Also contains scripts to analyze the pilot data. See `./data/README.md` for more inforation. |
| `./jspsych`  | houses the openly available software package `jspsych`.                                                                                                                                                                 |
| `./pilots`   | houses scripts related to the 4 pilot versions of the experiment.                                                                                                                                                       |
| `./stim`     | contains `.csv` files for the experimental stimuli.                                                                                                                                                                     |

## Key Experimental Files

| directory                        | explanation                                                                                                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `backwards_digit_span_day1.json` | contains the random digit sequences used during the trials of the backwards digit span task for day 1 in `.json` format. Serves as input into `experiment.html`. |
| `backwards_digit_span_day2.json` | contains the random digit sequences used during the trials of the backwards digit span task for day 2 in `.json` format. Serves as input into `experiment.html`. |
| `backwards_digit_span.R`         | R code for creating `backwards_digit_span_day1.json` and `backwards_digit_span_day2.json`.                                                                       |
| `experiment_data.csv`            | an organized list of all possible stimuli for day 1 and day 2.                                                                                                   |
| `generate_experiment_data.R`     | R code for creating `experiment_data.csv`                                                                                                                        |
| `experiment.css`                 | a cascading style sheet (`.css`) file that controls the formating of the TRIADs experiment in `experiment.html`.                                                 |
| `experiment.html`                | the web page (`.html`) file that, when accessed, runs the experiment.                                                                                            |
| `experiment.js`                  | a javascript file containing javascript code (similar to how R code is contained in `.R` files) that is utilized in `experiment.html`                            |
| `generate_stim_banks.R`          | R code for generating the stimuli banks found in the `./stim` directory.                                                                                         |
| `save_data.php`                  | php code for writing data to an online server. See the [jspsych documentation](https://www.jspsych.org/7.3/overview/data/#storing-data-permanently-as-a-file)    |

The experiment is programmed in javascript using the openly available `jspsych` software package. I highly recommend becoming confortable with `javascript`, `html`, and `css` before using `jspsych`. I found the documentation on the [jspsych website](https://www.jspsych.org/7.3/) to be particularly helpful.

## For More Information

I included READMEs within each subdirectoy. These contain much more detailed information concerning the files contained within that subdirectory.