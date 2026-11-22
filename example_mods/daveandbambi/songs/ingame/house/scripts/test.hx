function postCreate() {
    boyfriend.x = 1000;
}

var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;

    boyfriend.y += (Math.sin(elapsedTime) * 0.6);
    trace(boyfriend.y + " is boyfriends y according to hscript but idk if thats true becahse hscript sucks");
}