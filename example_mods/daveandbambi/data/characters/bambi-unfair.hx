var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    parent.y += (Math.sin(elapsedTime) * 0.6);
}