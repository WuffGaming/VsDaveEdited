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
    switch (curStep)
    {
        case 480 | 681 | 1390 | 1445 | 1515 | 1542 | 1598 | 1655:
            shakeCam = true;
            PlayState.instance.camZooming = true;
        case 512 | 688 | 1420 | 1464 | 1540 | 1558 | 1608 | 1745:
            shakeCam = false;
            PlayState.instance.camZooming = false;
    }
}