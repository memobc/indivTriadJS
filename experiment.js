pick = (obj, ...keys) => Object.fromEntries(
  keys
  .filter(key => key in obj)
  .map(key => [key, obj[key]])
);

remove = function(array, value){
  var array_copy = [...array];
  var index = array_copy.indexOf(value);
  array_copy.splice(index, 1)
  return array_copy;
}

construct_encoding_stimulus = function(){
  c=++c;
  var first = jsPsych.timelineVariable('first');
  var second = jsPsych.timelineVariable('second');
  var keyWord = allKeyStim[randperm[c]];
  var html = '<div style="width: 85vmin; height: 50vmin; font-size: 4vmin; position: relative;">'+
             '<div class="centertop">'+keyWord+'</div>'+
             '<div class="lowerleft">'+first+'</div>'+
             '<div class="lowerright">'+second+'</div>'+
             '</div>'
  return html

};

set_up_retrieval = function(){
  // once done with encoding, set up the retrieval trials
  enc_trial_data = jsPsych.data.get().filter({phase: 'enc'}).values();

  // make retrieval trials
  var objOneList = enc_trial_data.map(x => x.objOne);
  var objTwoList = enc_trial_data.map(x => x.objTwo);
  var allOptions = [];
  allOptions = objOneList.concat(objTwoList);

  // for object one
  for (let i = 0; i < enc_trial_data.length; i++) {

    // this key
    var thisKey = enc_trial_data[i].key;

    // this correct answer
    var correct = enc_trial_data[i].objOne;

    // the other answer
    var other_correct = enc_trial_data[i].objTwo;

    // remove the correct answer and the other correct answer from the bank
    // of possible lures
    var possible_lures = [];
    possible_lures = remove(allOptions, correct);
    possible_lures = remove(possible_lures, other_correct);

    // Randomly Pick 5 Lures
    var these_lures = jsPsych.randomization.sampleWithoutReplacement(possible_lures, 5);

    // concatenate the correct answer and the lures. Randomize their order
    var all_resp_options = these_lures.concat(correct);
    randomized_resp_options = jsPsych.randomization.sampleWithoutReplacement(all_resp_options, 6);

    var this_trial = {
      key: thisKey,
      resp_opt_1: randomized_resp_options[0],
      resp_opt_2: randomized_resp_options[1],
      resp_opt_3: randomized_resp_options[2],
      resp_opt_4: randomized_resp_options[3],
      resp_opt_5: randomized_resp_options[4],
      resp_opt_6: randomized_resp_options[5],
    }

    ret_trials.push(this_trial)

  }

  // for object two
  for (let i = 0; i < enc_trial_data.length; i++) {

    // this key
    var thisKey = enc_trial_data[i].key;

    // this correct answer
    var correct = enc_trial_data[i].objTwo;

    // the other answer
    var other_correct = enc_trial_data[i].objOne;

    // remove the correct answer and the other correct answer from the bank
    // of possible lures
    var possible_lures = [];
    possible_lures = remove(allOptions, correct);
    possible_lures = remove(possible_lures, other_correct);

    // Randomly Pick 5 Lures
    var these_lures = jsPsych.randomization.sampleWithoutReplacement(possible_lures, 5);

    // concatenate the correct answer and the lures. Randomize their order
    var all_resp_options = these_lures.concat(correct);
    randomized_resp_options = jsPsych.randomization.sampleWithoutReplacement(all_resp_options, 6);

    var this_trial = {
      key: thisKey,
      resp_opt_1: randomized_resp_options[0],
      resp_opt_2: randomized_resp_options[1],
      resp_opt_3: randomized_resp_options[2],
      resp_opt_4: randomized_resp_options[3],
      resp_opt_5: randomized_resp_options[4],
      resp_opt_6: randomized_resp_options[5],
    }

    ret_trials.push(this_trial)

  }
}

construct_retrieval_stimulus = function(){
  cc=++cc;
  console.log(cc)
  var keyWord = ret_trials[cc].key;
  var resp_opt_1 = ret_trials[cc].resp_opt_1;
  var resp_opt_2 = ret_trials[cc].resp_opt_2;
  var resp_opt_3 = ret_trials[cc].resp_opt_3;
  var resp_opt_4 = ret_trials[cc].resp_opt_4;
  var resp_opt_5 = ret_trials[cc].resp_opt_5;
  var resp_opt_6 = ret_trials[cc].resp_opt_6;
  console.log(keyWord.length)
  var html = '<div style="width: 100vmin; height:100vmin; font-size: 4vmin; position: relative; background-color: powderblue;">'+
             '<div class="center">'+keyWord+'</div>'+
             '<div class="resp_opt_1">'+'1: '+resp_opt_1+'</div>'+
             '<div class="resp_opt_2">'+'2: '+resp_opt_2+'</div>'+
             '<div class="resp_opt_3">'+'3: '+resp_opt_3+'</div>'+
             '<div class="resp_opt_4">'+'4: '+resp_opt_4+'</div>'+
             '<div class="resp_opt_5">'+'5: '+resp_opt_5+'</div>'+
             '<div class="resp_opt_6">'+'6:  '+resp_opt_6+'</div>'+
             '</div>'
  return html
}

finish_experiment = function() {

    // a unique data/time string
    // mm-dd-yyyy-hh-mm-ss
    var today = new Date();
    var datestring = today.getMonth() + '-' + today.getDate() + '-' + today.getFullYear() + '-' + today.getHours() + '-' + today.getMinutes() + '-' + today.getSeconds()

    // Save Data w/ unique data/time string
    saveData(datestring + '_' + urlvar.subject + "_experiment_data", jsPsych.data.get().csv());
    saveData(datestring + '_' + urlvar.subject + "_interaction_data", jsPsych.data.getInteractionData().csv());

    // Update available_lists.csv
    // var Updated_Available_Lists = convertToCSV(available_lists)
    // saveData("available_lists.csv", Updated_Available_Lists)

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a = document.createElement('a');
    var farewell_paragraph = document.createElement('p');
    var farewell_text = document.createTextNode("Thank you for participating!");
    farewell_paragraph.appendChild(farewell_text);
    var linkText = document.createTextNode("Follow This Link To Get SONA Credit");
    a.appendChild(linkText);
    a.href = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1127&credit_token=2d1623ee4a54413d826ed9a1b282539d&survey_code=" + urlvar.subject;
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

}
