function postCreate() {
    PlayState.instance.boyfriend.x = 1000;
}

var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;

    PlayState.instance.boyfriend.y += (Math.sin(elapsedTime) * 0.6);
}