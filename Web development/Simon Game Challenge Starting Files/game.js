
// Range of colors //
buttonColours = ["red", "blue", "green", "yellow"];
// Creating an Empty array game pattern // 
gamePattern = [];
// User clicked pattern //
userClickedPattern = [];



// Handler Function 
$(".btn").click(function() {
    //User choosen color 
    var userChosenColour = $(this).attr("id"); 
    //Add the contents to the empty array "userClickedPattern"
    userClickedPattern.push(userChosenColour);
    playsound(userChosenColour)
});


// Function creating random colors from the range of colors mentioned above // 
function nextSequence(){
    // Generate random number ranging from 0 to 4
    var randomNumber = Math.floor(Math.random() * 4);
    randomChosenColour = buttonColours[randomNumber];
    gamePattern.push(randomChosenColour);
    // $ script to Show the Sequence to the User with Animations and Sounds //
    $( "#" + randomChosenColour).fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100); 
    playsound(randomChosenColour)

    for (i=0;i < 100; i++) {
        $h1("h1").text("level"+ i)
   }
}


function playsound(name) {
      //3. Take the code we used to play sound in the nextSequence() function and add it to playSound().
        var audio = new Audio("sounds/" + name + ".mp3");
        audio.play();
}

function animatePress(currentColor){
    $("#" + currentColor).addClass(".pressed");
    setTimeout(function(){                                              // Ask the question where can we use the current color argument inside the funciton // 
        $("#" + currentColor).removeClass(".pressed");
      //....and whatever else you need to do
}, 100);
}

$document.keypress(function(event) {
     nextSequence().event.key;
});



      