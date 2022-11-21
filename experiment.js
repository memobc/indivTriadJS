pick = (obj, ...keys) => Object.fromEntries(
  keys
  .filter(key => key in obj)
  .map(key => [key, obj[key]])
);

omit = (obj, ...keys) => Object.fromEntries(
  Object.entries(obj)
  .filter(([key]) => !keys.includes(key))
);

remove = function(array, value){
  var array_copy = [...array];
  var index = array_copy.indexOf(value);
  array_copy.splice(index, 1)
  return array_copy;
}

SetEncInstr = function(){
  /* encoding instructions */

  // A series of reusable html strings
  var expKeyword = 'Jennifer Aniston';
  var expObjOne = 'Bowling Ball';
  var expObjTwo = 'Hockey Stick';
  var enc_example_1 = '<div style="width: 65vmin; height: 35vmin; font-size: 3vmin; position: relative; margin: auto">'+
                      '<div class="centertop">'+expKeyword+'</div>'+
                      '<div class="lowerleft">'+expObjOne+'</div>'+
                      '<div class="lowerright">'+expObjTwo+'</div>'+
                      '</div>'

  var succss_example = '<div id="jspsych-html-slider-response-wrapper" style="margin: 100px auto; width: 80vmin;"><div id="jspsych-html-slider-response-stimulus"><div style="margin: auto"><p>How successful were you in imagining a scenario?</p></div></div><div class="jspsych-html-slider-response-container" style="position:relative; margin: 0 auto 3em auto; width:auto;"><input type="range" class="jspsych-slider" value="50" min="0" max="100" step="1" id="jspsych-html-slider-response-response"><div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(5% - (100% / 2) - -7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Unsuccessful</span></div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(95% - (100% / 2) - 7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Successful</span></div></div></div></div>'

  var text_box_example = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Please describe what you were imagining:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder=""></textarea></div></form>'

  // A series of reusable html strings
  var resp_opt_1 = 'Bowling Ball';
  var resp_opt_2 = 'Screw';
  var resp_opt_3 = 'Earrings';
  var resp_opt_4 = 'Candle';
  var resp_opt_5 = 'Button';
  var resp_opt_6 = 'Apron';
  var example_blank = '<div style="width: 55vmin; height:50vmin; font-size: 3vmin; position: relative; line-height: normal; margin:auto">'+
                   '<div class="center">'+expKeyword+'</div>'+
                   '<div class="resp_opt_1">'+'1: '+resp_opt_1+'</div>'+
                   '<div class="resp_opt_2">'+'2: '+resp_opt_2+'</div>'+
                   '<div class="resp_opt_3">'+'3: '+resp_opt_3+'</div>'+
                   '<div class="resp_opt_4">'+'4: '+resp_opt_4+'</div>'+
                   '<div class="resp_opt_5">'+'5: '+resp_opt_5+'</div>'+
                   '<div class="resp_opt_6">'+'6:  '+resp_opt_6+'</div>'+
                   '</div>'
  var example_correct = '<div style="width: 55vmin; height:50vmin; font-size: 3vmin; position: relative; line-height: normal; margin:auto">'+
                   '<div class="center">'+expKeyword+'</div>'+
                   '<div class="resp_opt_1"; style="background-color: powderblue">'+'1: '+resp_opt_1+'</div>'+
                   '<div class="resp_opt_2">'+'2: '+resp_opt_2+'</div>'+
                   '<div class="resp_opt_3">'+'3: '+resp_opt_3+'</div>'+
                   '<div class="resp_opt_4">'+'4: '+resp_opt_4+'</div>'+
                   '<div class="resp_opt_5">'+'5: '+resp_opt_5+'</div>'+
                   '<div class="resp_opt_6">'+'6:  '+resp_opt_6+'</div>'+
                   '</div>'

  var instruct = {
      type: jsPsychInstructions,
      pages: [
          '<p>This is a memory experiment.</p><p style = "margin:auto; inline-size: 40%">Your task is to vividly imagine a scenario composed of three words in as much detail as possible.</p><p>Click next to continue.</p>',
          '<p>Here is an example of what you will be asked to do:</p>' + enc_example_1,
          '<p>Each trial will have three words displayed in a triangle.</p>' + enc_example_1,
          '<p>During this time, try to vividly imagine a scenario linking the three words together.</p>' + enc_example_1,
          '<p style = "inline-size: 80%; margin: auto">After each trial, you will be asked to report how successful you were in imagining a scenario:</p>' + succss_example,
          '<p style = "inline-size: 80%; margin: auto">Using your mouse, drag the slider to indicate how successful you were.</p>' + succss_example,
          '<p style = "inline-size: 80%; margin: auto">For some trials, you will be asked to report what you were imagining by typing text into a text box. Please be as detailed as possible.</p>' + text_box_example,
          '<p>You will be asked to recall the words on a later memory test.</p>',
          '<p>Here is an example of how we will test your memory:</p>' + example_blank,
          '<p>You will be presented with one of the words presented previously along with 6 response options.</p>' + example_blank,
          '<p>Your task is to select the option that was presented alongside the keyword in the previous portion of the experiment.<\p>' + example_correct,
          '<p>Please use the 1-6 keys at the top of the keyboard to indicate your response.<\p>' + example_correct,
          '<p>Click next when you are ready to begin the experiment.</p>'
      ],
      data: {phase: 'enc_instr'},
      post_trial_gap: 1500,
      show_clickable_nav: true
  }
  return(instruct)
}

calculate_top_People = function(data){
  var responses = data.response;
  var sortedPeople = Object.keys(responses).sort(function(a,b){return responses[b]-responses[a]});
  topTwelvePeople = sortedPeople.slice(0,14);
}

calculate_top_Places = function(data){
  var responses = data.response;
  var sortedPlaces = Object.keys(responses).sort(function(a,b){return responses[b]-responses[a]});
  topTwelvePlaces = sortedPlaces.slice(0,14);
  allKeyStim = topTwelvePlaces.concat(topTwelvePeople)
}

construct_encoding_stimulus = function(){
  c=++c;
  var first = jsPsych.timelineVariable('first');
  var second = jsPsych.timelineVariable('second');
  var keyWord = allKeyStim[randperm[c]];
  var html = '<div style="width: 75vmin; height: 35vmin; font-size: 4vmin; position: relative;">'+
             '<div class="centertop">'+keyWord+'</div>'+
             '<div class="lowerleft">'+first+'</div>'+
             '<div class="lowerright">'+second+'</div>'+
             '</div>'
  return html
};

set_up_retrieval = function(){

  var catchTrialNumbers = jsPsych.data.get().filter({phase: 'enc'}).filter({trial_type: 'survey-text'}).values().map(x => x.encTrialNum)

  // once done with encoding, set up the retrieval trials
  enc_trial_data = jsPsych.data.get().filter({phase: 'enc'}).filter({rt: null}).filterCustom(function(trial){
    return !catchTrialNumbers.includes(trial.encTrialNum)
  }).values();

  // make retrieval trials
  var objOneList = enc_trial_data.map(x => x.objOne);
  var objTwoList = enc_trial_data.map(x => x.objTwo);
  var allOptions = objOneList.concat(objTwoList);

  // for key -- object one
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
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // for key -- object two
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
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // for objOne -- objTwo
  for (let i = 0; i < enc_trial_data.length; i++) {

    // randomly select either the first or second object as the cue
    var OneOrTwo = [1, 2];
    var randSelection = jsPsych.randomization.sampleWithoutReplacement(OneOrTwo, 1);

    if(randSelection == 1){

      // this key
      var thisKey = enc_trial_data[i].objOne;

      // the correct answer
      var correct = enc_trial_data[i].objTwo;

    } else {

      // this key
      var thisKey = enc_trial_data[i].objTwo;

      // the correct answer
      var correct = enc_trial_data[i].objOne;

    }

    // remove the correct answer and the key from the bank of possible lures
    var possible_lures = [];
    possible_lures = remove(allOptions, correct);
    possible_lures = remove(possible_lures, thisKey);

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
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // randomly sort the ret_trials array
  ret_trials = jsPsych.randomization.sampleWithoutReplacement(ret_trials, ret_trials.length)

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

  var html = '<div style="width: 90vmin; height:80vmin; font-size: 4vmin; position: relative; line-height: normal;">'+
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

finish_experiment = function(){

    // a unique data/time string
    // mm-dd-yyyy-hh-mm-ss
    var today = new Date();
    var datestring = today.getMonth() + '-' + today.getDate() + '-' + today.getFullYear() + '-' + today.getHours() + '-' + today.getMinutes() + '-' + today.getSeconds()

    // Save Data w/ unique data/time string
    saveData(datestring + '_' + urlvar.subject + "_experiment_data.csv", jsPsych.data.get().csv());
    saveData(datestring + '_' + urlvar.subject + "_interaction_data.csv", jsPsych.data.getInteractionData().csv());

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a = document.createElement('a');
    var farewell_paragraph = document.createElement('p');
    var farewell_text = document.createTextNode("Thank you for participating!");
    farewell_paragraph.appendChild(farewell_text);
    var linkText = document.createTextNode("Follow This Link To Get SONA Credit");
    a.appendChild(linkText);
    a.href = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1287&credit_token=c497d6c0727547be816b76ce8b8b1b52&survey_code=" + urlvar.subject;
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

}

finish_experiment_dayOne = function(){

    // a unique data/time string
    // mm-dd-yyyy-hh-mm-ss
    var today = new Date();
    var datestring = today.getMonth() + '-' + today.getDate() + '-' + today.getFullYear() + '-' + today.getHours() + '-' + today.getMinutes() + '-' + today.getSeconds()

    // Save Data w/ unique data/time string
    saveData(datestring + '_' + urlvar.subject + "_experiment_data.csv", jsPsych.data.get().csv());
    saveData(datestring + '_' + urlvar.subject + "_interaction_data.csv", jsPsych.data.getInteractionData().csv());

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a = document.createElement('a');
    var farewell_paragraph = document.createElement('p');
    var farewell_text = document.createTextNode("Thank you for participating!");
    farewell_paragraph.appendChild(farewell_text);
    var linkText = document.createTextNode("Follow This Link To Get SONA Credit");
    a.appendChild(linkText);
    a.href = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1296&credit_token=4e26aa97c80e4ed498758f301ff269aa&survey_code=" + urlvar.subject;
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

}

finish_experiment_dayTwo = function(){

    // a unique data/time string
    // mm-dd-yyyy-hh-mm-ss
    var today = new Date();
    var datestring = today.getMonth() + '-' + today.getDate() + '-' + today.getFullYear() + '-' + today.getHours() + '-' + today.getMinutes() + '-' + today.getSeconds()

    // Save Data w/ unique data/time string
    saveData(datestring + '_' + urlvar.subject + "_experiment_data.csv", jsPsych.data.get().csv());
    saveData(datestring + '_' + urlvar.subject + "_interaction_data.csv", jsPsych.data.getInteractionData().csv());

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a = document.createElement('a');
    var farewell_paragraph = document.createElement('p');
    var farewell_text = document.createTextNode("Thank you for participating!");
    farewell_paragraph.appendChild(farewell_text);
    var linkText = document.createTextNode("Follow This Link To Get SONA Credit");
    a.appendChild(linkText);
    a.href = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1297&credit_token=a2cfc2ea894e46689484c27d86ed1642&survey_code=" + urlvar.subject;
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

}

// jsPsych savedata function
function saveData(filename, filedata){
   $.ajax({
type:'post',
      cache: false,
      url: 'save_data.php', // this is the path to the above PHP script
      data: {filename: filename, filedata: filedata},
      success: function(data) {
        if (data == "ok") {
          console.log("Success!")
        }
}
   });
 }
