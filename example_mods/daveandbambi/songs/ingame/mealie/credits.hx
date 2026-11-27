import flixel.text.FlxText.FlxTextBorderStyle;

var credits:String = 'Original Song made by Alexander Cooper 19!';

function postCreate() {
    PlayState.kadeEngineWatermark.y -= 20;
    var creditsWatermark:FlxText = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
    creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    creditsWatermark.scrollFactor.set();
    creditsWatermark.borderSize = 1.25;
    add(creditsWatermark);
    creditsWatermark.camera = camHUD;
}