var pulseEffect:FlxRuntimeShader;
var elapsedTime:Float = FlxG.random.float(-100000, 100000);
var shakeCam:Bool = false;

function postCreate() {
    pulseEffect = new FlxRuntimeShader(Assets.getText(Paths.shader('pulseEffect.frag')));
    pulseEffect.setFloat('uWaveAmplitude', (shakeCam && PlayState.eyesoreson) ? 1 : 0);
    pulseEffect.setFloat('uFrequency', 2);
    pulseEffect.setFloat('uSpeed', 1);
    pulseEffect.setBool('uEnabled', true);
    FlxG.game.setFilters([new ShaderFilter(pulseEffect)]);
}

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    pulseEffect.setFloat('uTime', elapsedTime);
    PlayState.gf.canDance = !shakeCam;
    if (shakeCam) {
        FlxG.camera.shake(0.015, 0.015);
    }

    pulseEffect.setFloat('uWaveAmplitude', (shakeCam && PlayState.eyesoreson) ? 1 : 0);
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