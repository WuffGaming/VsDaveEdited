function postCreate() {
    boyfriend.x = 1000;

    trace('this script should only run if the song is House');
}

var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;

    boyfriend.y += (Math.sin(elapsedTime) * 0.6);
    
}