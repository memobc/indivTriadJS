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

  var succss_example = '<div id="jspsych-html-slider-response-wrapper" style="margin: 100px auto; width: 80vmin;"><div id="jspsych-html-slider-response-stimulus"><div style="margin: auto"><p>How successful were you in imagining a scenario?</p></div></div><div class="jspsych-html-slider-response-container" style="position:relative; margin: 0 auto 3em auto; width:auto;"><input type="range" class="jspsych-slider" value="50" min="0" max="100" step="1" id="jspsych-html-slider-response-response"><div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(5% - (100% / 2) - -7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Unsuccessful</span></div><div style="border: 1px solid transparent; display: inline-block; position: absolute; left:calc(95% - (100% / 2) - 7.5px); text-align: center; width: 100%;"><span style="text-align: center; font-size: 80%;">Successful</span></div></div></div></div>'

  var text_box_example = '<form id="jspsych-survey-text-form" autocomplete="off"><div id="jspsych-survey-text-0" class="jspsych-survey-text-question" style="margin: 2em 0em;"><p class="jspsych-survey-text">Please describe what you were imagining:</p><textarea id="input-0" name="#jspsych-survey-text-response-0" data-name="" cols="40" rows="5" autofocus="" required="" placeholder=""></textarea></div></form>'

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
          '<p>This is a memory experiment.</p><p style = "margin:auto; inline-size: 40%">Your task is to vividly imagine a scenario composed of three words in as much detail as possible.</p><p>Click next to continue.</p>',
          '<p>Here is an example of what you will be asked to do:</p>' + enc_example_1,
          '<p>Each trial will have three words displayed in a triangle.</p>' + enc_example_1,
          '<p>During this time, try to vividly imagine a scenario linking the three words together.</p>' + enc_example_1,
          '<p style = "inline-size: 80%; margin: auto">After each trial, you will be asked to report how successful you were in imagining a scenario:</p>' + succss_example,
          '<p style = "inline-size: 80%; margin: auto">Using your mouse, drag the slider to indicate how successful you were.</p>' + succss_example,
          '<p style = "inline-size: 80%; margin: auto">For some trials, you will be asked to report what you were imagining by typing text into a text box. Please be as detailed as possible.</p>' + text_box_example,
          '<p>You will be asked to recall the words on a later memory test.</p>',
          '<p>Here is an example of how we will test your memory:</p>' + example_blank,
          '<p>You will be presented with one of the words presented previously along with two blank boxes.</p>' + example_blank,
          '<p>Your task is to remember the items that were presented alongside the keyword in the previous portion of the experiment.<\p>' + example_correct,
          '<p>Leave the boxes blank if you cannot remember the other items. If you can only remember one of the two items, fill that one in.<\p>' + example_correct,
          '<p>You will click the "submit" button at the bottom of the page when you want to submit your answers.<\p>' + example_correct,
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

mock_retrieval_trials = function(){
  ret_trials.push({
    key: 'The Washington Monument, Washington D.C.',
    resp_opt_1: 'sewing machine',
    resp_opt_2: 'measuring cup',
    resp_opt_3: 'cash register',
    resp_opt_4: 'dream catcher',
    resp_opt_5: 'bowling ball',
    resp_opt_6: 'light switch'})

    ret_trials.push({
      key: 'Oprah',
      resp_opt_1: 'cd',
      resp_opt_2: 'key',
      resp_opt_3: 'bow',
      resp_opt_4: 'ring',
      resp_opt_5: 'kite',
      resp_opt_6: 'dice'})

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
    if(urlvar.day == 'one') {
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
    if(urlvar.day == 'one'){
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
            {prompt: 'Report the numbers that you saw in reverse order:', rows: 5, required: true}
          ]
        }
      ],
    }
    procedure.timeline.push(trial)
  }

  return(procedure)
};