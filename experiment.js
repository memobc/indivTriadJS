// update progress bar

function updateProgressBar(){
  // at the end of each trial, update the progress bar
  // based on the current value and the proportion to update for each trial
  var curr_progress_bar_value = jsPsych.getProgressBarCompleted();
  jsPsych.setProgressBar(curr_progress_bar_value + (1/nEvents));
}

// pick an element from an object
pick = (obj, ...keys) => Object.fromEntries(
  keys
  .filter(key => key in obj)
  .map(key => [key, obj[key]])
);

// remove element from an object
omit = (obj, ...keys) => Object.fromEntries(
  Object.entries(obj)
  .filter(([key]) => !keys.includes(key))
);

// remove element from an array
remove = function(array, value){
  var array_copy = [...array];
  var index = array_copy.indexOf(value);
  array_copy.splice(index, 1)
  return array_copy;
}

// returns true when value is blank
function removeBlank(value){
  return !value.people == ''
}

SetInstr = function(){
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

  var success_example = '<div id="jspsych-html-slider-response-wrapper" style="margin: 100px auto;"><div id="jspsych-html-slider-response-stimulus"><div style="margin: auto"><p>How successful were you in imagining a scenario?</p></div></div><div class="jspsych-html-slider-response-container" style="position:relative; margin: 0 auto 3em auto; width:auto;"><input type="range" class="jspsych-slider" value="50" min="0" max="100" step="1" id="jspsych-html-slider-response-response"><div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(5% - (100% / 2) - -7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Unsuccessful</span></div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(95% - (100% / 2) - 7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Successful</span></div></div></div></div>'
  var success_example_SliderMoved = '<div id="jspsych-html-slider-response-wrapper" style="margin: 100px auto;"><div id="jspsych-html-slider-response-stimulus"><div style="margin: auto"><p>How successful were you in imagining a scenario?</p></div></div><div class="jspsych-html-slider-response-container" style="position:relative; margin: 0 auto 3em auto; width:auto;"><input type="range" class="jspsych-slider" value="85" min="0" max="100" step="1" id="jspsych-html-slider-response-response"><div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(5% - (100% / 2) - -7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Unsuccessful</span></div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(95% - (100% / 2) - 7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Successful</span></div></div></div></div>';

  var text_box_example = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Please describe what you were imagining:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder=""></textarea></div></form>'
  var text_box_exampleFilled = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Please describe what you were imagining:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder="I imagined Jennifer Anniston at a bowling alley trying to push a bowling ball down the lane with a hockey stick."></textarea></div></form>'

  var text_box_example_BDS = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Report the numbers that you just saw in reverse order:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder=""></textarea></div></form>'
  var text_box_example_BDS_filled = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Report the numbers that you just saw in reverse order:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder="9 7 5 1 1"></textarea></div></form>'


  // A series of reusable html strings

  var example_blank = '<div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;">'+
                      '<p class="jspsych-survey-text">What items went with <b>Jennifer Anniston</b>?</p>'+
                      '<input type="text" id="input-0" name="#jspsych-survey-text-response-0" data-name="" size="40" autofocus="" required="">'+
                      '</div>'+
                      '<div id="jspsych-survey-text-1" class="jspsych-survey-text-question" style="margin: 2em 0em;">'+
                      '<p class="jspsych-survey-text"></p>'+
                      '<input type="text" id="input-1" name="#jspsych-survey-text-response-1" data-name="" size="40" placeholder="">'+
                      '</div>'+
                      '<input type="submit" value="Continue">'

  var example_correct =  '<div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;">'+
                         '<p class="jspsych-survey-text">What items went with <b>Jennifer Anniston</b>?</p>'+
                         '<input type="text" id="input-0" name="#jspsych-survey-text-response-0" data-name="" size="40" autofocus="" required="" placeholder="Bowling Ball">'+
                         '</div>'+
                         '<div id="jspsych-survey-text-1" class="jspsych-survey-text-question" style="margin: 2em 0em;">'+
                         '<p class="jspsych-survey-text"></p>'+
                         '<input type="text" id="input-1" name="#jspsych-survey-text-response-1" data-name="" size="40" placeholder="Hockey Stick">'+
                         '</div>'+
                         '<input type="submit" value="Continue">'

  var instruct = {
      type: jsPsychInstructions,
      pages: [
          '<p>This is a memory experiment.</p><p>Click next to continue.</p>',
          '<p>You will be asked to study sets of three items.</p>',
          '<p>Each encoding trial will have three items displayed in a triangle. An example is presented below: </p>' + enc_example_1,
          '<p>During this time, try to vividly imagine a scenario linking the three words together.</p>' + enc_example_1,
          '<p style = "inline-size: 80%; margin: auto">After each trial, you will be asked to report how successful you were in imagining a scenario.</p>' + success_example,
          '<p style = "inline-size: 80%; margin: auto">Using your mouse, drag the slider to indicate how successful you were.</p>' + success_example_SliderMoved,
          '<p style = "inline-size: 80%; margin: auto">For some trials, you will be asked to report what you were imagining by typing text into a text box.</p>' + text_box_example,
          '<p style = "inline-size: 80%; margin: auto">Please be as detailed as possible.</p>' + text_box_exampleFilled,
          '<p>You will be asked to recall the words on a later memory test.</p>',
          '<p>After studying the three word triads, you will be asked to complete a short backward digit span task.</p>',
          '<p>In this task, you will be presented with a series of digits one at a time.',
          '<p>You will then be presented with a blank answer text box like the one shown below:</p>' + text_box_example_BDS,
          '<p>Your goal is to type out the digits you saw in the reverse order in which you saw them.</p>' + text_box_example_BDS,
          '<p>So for example, if you were shown the digits "1 - 1 - 5 - 7 - 9", you will need to report back "9 7 5 1 1".</p>' + text_box_example_BDS_filled,
          '<p>The final part of the experiment will be a memory test</p>', 
          '<p>During the memory test, you will be presented with one of the words presented previously along with two blank boxes:</p>' + example_blank,
          '<p>Your task is to remember the items that were presented alongside the keyword in the previous portion of the experiment.<\p>' + example_correct,
          '<p>Leave the boxes blank if you cannot remember the other items. If you can only remember one of the two items, fill that one in.<\p>' + example_correct,
          '<p>You will click the "submit" button at the bottom of the page when you want to submit your answers.<\p>' + example_correct,
          '<p>Click next when you are ready to begin the experiment.</p>'
      ],
      data: {phase: 'enc_instr'},
      post_trial_gap: 1500,
      show_clickable_nav: true,
      css_classes: ['consent_form'],
      on_finish: updateProgressBar
  }
  return(instruct)
}

calculate_top = function(){
  var responses    = jsPsych.data.getLastTrialData().values()[0].response;
  
  // people
  var people = responses.people;
  var sortedPeople = Object.keys(people).sort(function(a,b){return people[b]-people[a]});
  topPeople        = sortedPeople.slice(0,14);
  
  // places
  var places = responses.places;
  var sortedPlaces = Object.keys(places).sort(function(a,b){return places[b]-places[a]});
  topPlaces        = sortedPlaces.slice(0,14);
  allKeyStim       = topPlaces.concat(topPeople);

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

  // for key
  for (let i = 0; i < enc_trial_data.length; i++) {

    // this key
    var thisKey = enc_trial_data[i].key;

    var this_trial = {
      key: thisKey,
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // for object one
  for (let i = 0; i < enc_trial_data.length; i++) {

    // object One
    var objOne = enc_trial_data[i].objOne;

    var this_trial = {
      key: objOne,
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // for object Two
  for (let i = 0; i < enc_trial_data.length; i++) {

    // this key
    var objTwo = enc_trial_data[i].objTwo;

    var this_trial = {
      key: objTwo,
      enc_trial_index: enc_trial_data[i].trial_index
    }

    ret_trials.push(this_trial)

  }

  // randomly sort the ret_trials array
  ret_trials = jsPsych.randomization.sampleWithoutReplacement(ret_trials, ret_trials.length)

}

function mock_stim() {
  // hand picked set of 14 people and 14 places. 
  // useful for debugging encoding and retrieval 
  // without having to repeatedly do the 
  // people/places surveys.
  allKeyStim = ['Octavia Spencer',
    'Paul McCartney',
    'Julianne Moore',
    'Stephen Hawking',
    'Nicholas Cage',
    'Bradley Cooper',
    'Hugh Jackman',
    'Anne Hathaway',
    'Audrey Hepburn',
    'John F. Kennedy',
    'Mother Teresa',
    'Daniel Radcliffe',
    'Emily Blunt',
    'Mark Zuckerberg',
    'The Golden Gate Bridge, San Francisco',
    'Napa Valley, California',
    'Niagara Falls',
    'Burj Khalifa, Dubai',
    'The Tower of Pisa, Italy',
    'The Lincoln Memorial, Washington D.C.',
    'Neuschwanstein Castle, Germany',
    'The London Eye',
    'The University of Oxford, England',
    'Epcot Center, Orlando',
    'United Nations Headquarters, New York',
    'The Pyramids of Giza',
    'The Brandenburg Gate, Berlin',
    'The Empire State Building, New York'
    ]
}

function mock_retTrials(objectList){
  // create a mock set of ret_trials
  // useful for debugging retrieval without having to click through encoding

  // create a copy of the allKeyStim array
  var fauxAllKeyStim = [...allKeyStim];

  // remove two elements at the end of the array
  //   the elements at the beginning of the array are
  //   people. these two people will be the catch trials
  fauxAllKeyStim.pop();
  fauxAllKeyStim.pop();

  // remove two elements at the beginning of the array
  //   the elements at the end of the array are places. 
  //   these two places will be the catch trials
  fauxAllKeyStim.shift();
  fauxAllKeyStim.shift();

  // create a fake object list. remove 4 trials worth of data
  // Why? For the catch trials.
  var fauxObjectList = [...objectList];
  fauxObjectList.pop();
  fauxObjectList.pop();
  fauxObjectList.shift();
  fauxObjectList.shift();

  // for keys
  for (let i = 0; i < fauxAllKeyStim.length; i++) {

    // this key
    var key = fauxAllKeyStim[i];

    var this_trial = {
      key: key,
      enc_trial_index: NaN
    }

    ret_trials.push(this_trial)

  }

  // for objOne
  for (let i = 0; i < fauxObjectList.length; i++) {

    // this key
    var key = fauxObjectList[i].first;

    var this_trial = {
      key: key,
      enc_trial_index: NaN
    }

    ret_trials.push(this_trial)

  }

  // for objTwo
  for (let i = 0; i < fauxObjectList.length; i++) {

    // this key
    var key = fauxObjectList[i].second;

    var this_trial = {
      key: key,
      enc_trial_index: NaN
    }

    ret_trials.push(this_trial)

  }

  ret_trials = jsPsych.randomization.sampleWithoutReplacement(ret_trials, ret_trials.length)

}

construct_retrieval_stimulus = function(){

  cc=++cc;

  var keyWord = ret_trials[cc].key;
  var resp_opt_1 = ret_trials[cc].resp_opt_1;
  var resp_opt_2 = ret_trials[cc].resp_opt_2;
  var resp_opt_3 = ret_trials[cc].resp_opt_3;
  var resp_opt_4 = ret_trials[cc].resp_opt_4;
  var resp_opt_5 = ret_trials[cc].resp_opt_5;
  var resp_opt_6 = ret_trials[cc].resp_opt_6;

  var html = '<div class="outer_wrap">'+
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
    saveData('datetime-' + datestring + '_sub-' + urlvar.subject + '_ses-' + urlvar.day + "_data-experiment.csv", jsPsych.data.get().csv());
    saveData('datetime-' + datestring + '_sub-' + urlvar.subject + '_ses-' + urlvar.day + "_data-interaction.csv", jsPsych.data.getInteractionData().csv());

    // Display the link so participants can give themselves SONA credit
    var el = jsPsych.getDisplayElement();
    var a = document.createElement('a');
    var farewell_paragraph = document.createElement('p');
    
    // farewell message based on the session
    var farewell_message;
    if(urlvar.day == '1') {
      farewell_messsage = "Thank you for participating! The link to complete Part 2 of the experiment will be available on SONA in 24 hours. You will then have 24 hours to complete Part 2.";
    } else {
      farewell_messsage = "Thank you for participating!";
    }
    
    var farewell_text = document.createTextNode(farewell_messsage);
    farewell_paragraph.appendChild(farewell_text);
    
    var linkText = document.createTextNode("Follow This Link To Get SONA Credit");
    a.appendChild(linkText);
    
    // farewell link based on the session
    var farewell_link;
    if(urlvar.day == '1'){
      farewell_link = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1296&credit_token=4e26aa97c80e4ed498758f301ff269aa&survey_code=" + urlvar.subject;
    } else {
      farewell_link = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1297&credit_token=a2cfc2ea894e46689484c27d86ed1642&survey_code=" + urlvar.subject;
    }
    a.href = farewell_link;
    
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

async function backwards_digit_span(){

  var timeline_vars = await fetch('backwards_digit_span.json')
  .then((response) => response.json())
  .then((value) => value);

  var trial
  var procedure = {timeline: []}
  for (let i = 0; i < timeline_vars.length; i++) {
    trial = {
      timeline: [
        {
          type: jsPsychHtmlKeyboardResponse,
          choices: "NO_KEYS",
          trial_duration: 500,
          post_trial_gap: 500,
          timeline: timeline_vars[i]
        },
        {
          type: jsPsychSurveyText,
          questions: [
            {prompt: 'Report the numbers that you just saw in reverse order:', rows: 2, required: true}
          ],
          on_finish: updateProgressBar
        }
      ],
    }
    procedure.timeline.push(trial)
  }

  return(procedure)
};

function set_up_sam(){
  
}