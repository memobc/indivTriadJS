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

  var instruct = {
      type: jsPsychInstructions,
      pages: [
          '<p>This is a memory experiment.</p><p style = "margin:auto; inline-size: 40%">Your task is to <b>vividly imagine</b> a scenario composed of three words in as much detail as possible.</p><p>Click next to continue.</p>',
          '<p>Here is an example of what you will be asked to do:</p>' + enc_example_1,
          '<p>Each trial will have three words displayed in a triangle.</p>' + enc_example_1,
          '<p>During this time, try to vividly imagine a scenario linking the three words together.</p>' + enc_example_1,
          '<p>You will be asked to recall the words on a later memory test.</p>' + enc_example_1,
          '<p>Click next when you are ready to begin the experiment.</p>'
      ],
      data: {phase: 'enc_instr'},
      post_trial_gap: 1500,
      show_clickable_nav: true
  }
  return(instruct)
}

calculate_top_twelvePeople = function(data){
  var responses = data.response;
  var sortedPeople = Object.keys(responses).sort(function(a,b){return responses[b]-responses[a]});
  topTwelvePeople = sortedPeople.slice(0,12);
}

calculate_top_twelvePlaces = function(data){
  var responses = data.response;
  var sortedPlaces = Object.keys(responses).sort(function(a,b){return responses[b]-responses[a]});
  topTwelvePlaces = sortedPlaces.slice(0,12);
  allKeyStim = topTwelvePlaces.concat(topTwelvePeople)
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
  var allOptions = objOneList.concat(objTwoList);

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

SetRetInstr = function(){
  /* retrieval instructions */

  // A series of reusable html strings
  var expKeyword = 'Jennifer Aniston';
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
        '<p>We will now test your memory for the previously presented events.</p>',
        '<p>Here is an example of how we will test your memory:</p>' + example_blank,
        '<p>You will be presented with one of the words presented previously along with 6 response options.</p>' + example_blank,
        '<p>Your task is to select the option that was presented alongside the keyword.<\p>' + example_correct,
        '<p>Please use the 1-6 keys at the top of the keyboard to indicate your response.<\p>' + example_correct,
        '<p>Click next when you are ready to begin the experiment.</p>'
      ],
      data: {phase: 'ret_instr'},
      post_trial_gap: 1500,
      show_clickable_nav: true
  }

  return(instruct)
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
  jsPsych.data.write(ret_trials[cc])
  var html = '<div style="width: 100vmin; height:100vmin; font-size: 4vmin; position: relative; line-height: normal;">'+
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
    a.href = "https://bc.sona-systems.com/webstudy_credit.aspx?experiment_id=1127&credit_token=2d1623ee4a54413d826ed9a1b282539d&survey_code=" + urlvar.subject;
    el.appendChild(farewell_paragraph);
    el.appendChild(a);

}

//saveData = function(name, data){
//  var xhr = new XMLHttpRequest();
//  xhr.open('POST', 'write_data.php'); // 'write_data.php' is the path to the php file described above.
//  xhr.setRequestHeader('Content-Type', 'application/json');
//  xhr.send(JSON.stringify({filename: name, filedata: data}));
//  console.log(JSON.stringify({filename: name, filedata: data}))
//}

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
