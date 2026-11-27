import flixel.text.FlxText.FlxTextBorderStyle;

var credits:String = 'Screw You!';

function postCreate() {
    PlayState.kadeEngineWatermark.y -= 20;
    var creditsWatermark:FlxText = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
    creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    creditsWatermark.scrollFactor.set();
    creditsWatermark.borderSize = 1.25;
    add(creditsWatermark);
    creditsWatermark.camera = camHUD;
}

var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    PlayState.instance.playerStrums.forEach(function(spr:StrumNote)
    {
        spr.x += Math.sin(elapsedTime) * ((spr.ID % 2) == 0 ? 1 : -1);
        spr.x -= Math.sin(elapsedTime) * 1.5;
    });
    PlayState.instance.dadStrums.forEach(function(spr:StrumNote)
    {
        spr.x -= Math.sin(elapsedTime) * ((spr.ID % 2) == 0 ? 1 : -1);
        spr.x += Math.sin(elapsedTime) * 1.5;
    });
}

function onDadHit() {
    FlxG.camera.shake(0.0075, 0.1);
	PlayState.instance.camHUD.shake(0.0045, 0.1);
    PlayState.instance.health -= 0.01;
}