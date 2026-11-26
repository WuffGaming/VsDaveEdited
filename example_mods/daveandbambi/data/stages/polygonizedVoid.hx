import lime.utils.Assets;

var glitchEffect:FlxRuntimeShader;
var elapsedTime:Float = 0;

function postCreate() {
    glitchEffect = new FlxRuntimeShader(Assets.getText(Paths.shader('glitchEffect.frag')));
    glitchEffect.setFloat('uWaveAmplitude', 0.1);
    glitchEffect.setFloat('uFrequency', 5);
    glitchEffect.setFloat('uSpeed', 2);
    glitchEffect.setBool('uEnabled', true);
    glitchEffect.setFloat('uTime', 0);
    sky.shader = glitchEffect; 
}

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    glitchEffect.setFloat('uTime', elapsedTime);
}