function stepHit(curStep:Int) {
    if (curStep == 1776) {
        var position = PlayState.dad.getPosition();
        FlxG.camera.flash(FlxColor.WHITE, 0.25);
        var nightColor = PlayState.dad.color;
        PlayState.instance.switchDad('bambi-angey');
        PlayState.instance.iconP2.changeIcon('bambi-mad');
        PlayState.dad.color = nightColor;
    }
}