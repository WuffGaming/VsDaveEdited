import stage.Stage;

var pulseEffect:FlxRuntimeShader;
var elapsedTime:Float = FlxG.random.float(-100000, 100000);
var shakeCam:Bool = false;

var nightColor = 0xFF878787;

function postCreate() {
    pulseEffect = new FlxRuntimeShader(Assets.getText(Paths.shader('pulseEffect.frag')));
    pulseEffect.setFloat('uWaveAmplitude', (shakeCam && PlayState.eyesoreson) ? 1 : 0);
    pulseEffect.setFloat('uFrequency', 2);
    pulseEffect.setFloat('uSpeed', 1);
    pulseEffect.setBool('uEnabled', true);
    FlxG.game.setFilters([new ShaderFilter(pulseEffect)]);

    var ourGubbyStage = new Stage('daveHouseNight');
    ourGubbyStage.remove(ourGubbyStage.scriptPack);
    insert(0, ourGubbyStage);
}

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    pulseEffect.setFloat('uTime', elapsedTime);
    PlayState.gf.canDance = !shakeCam;
    if (shakeCam) {
        FlxG.camera.shake(0.015, 0.015);
    }

        if (shakeCam && PlayState.eyesoreson)
        pulseEffect.setFloat('uWaveAmplitude', (shakeCam && PlayState.eyesoreson) ? 1 : 0);
    else
        pulseEffect.setFloat('uWaveAmplitude', pulseEffect.getFloat('uWaveAmplitude') - (elapsed / 2));
}

function beatHit(curBeat:Int) {
    if (shakeCam) PlayState.gf.playAnim('scared', true);
}

function onDestroy() {
    FlxG.game.setFilters([]);
}

function stepHit(curStep:Int) {
    switch(curStep)
    {
        case 1024 | 1312 | 1424 | 1552 | 1664:
            shakeCam = true;
            PlayState.instance.camZooming = true;
        case 1152 | 1408 | 1472 | 1600 | 2048 | 2176:
            shakeCam = false;
            PlayState.instance.camZooming = false;
        case 2432:
            PlayState.boyfriend.canDance = false;
            PlayState.gf.canDance = false;
            PlayState.boyfriend.playAnim('hey', true);
            PlayState.gf.playAnim('cheer', true);
    }
}

function beatHit(curBeat:Int) {
    if (curBeat == 608) {
        PlayState.boyfriend.canDance = false;
        PlayState.gf.canDance = false;
        PlayState.boyfriend.playAnim('hey', true);
        PlayState.gf.playAnim('cheer', true);
        for (bgSprite in PlayState.instance.stage)
        {
            FlxTween.tween(bgSprite, {alpha: 0}, 1);
        }
        var position = PlayState.dad.getPosition();
        FlxG.camera.flash(FlxColor.WHITE, 0.25);
        PlayState.instance.switchDad('dave', position.x, position.y);
        FlxTween.color(PlayState.dad, 0.6, PlayState.dad.color, nightColor);
        FlxTween.color(PlayState.boyfriend, 0.6, PlayState.boyfriend.color, nightColor);
        FlxTween.color(PlayState.gf, 0.6, PlayState.gf.color, nightColor);
        FlxTween.linearMotion(PlayState.dad, PlayState.dad.x, PlayState.dad.y, 350, 260, 0.6, true);
    }
}