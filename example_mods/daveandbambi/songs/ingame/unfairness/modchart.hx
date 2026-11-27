import flixel.text.FlxText.FlxTextBorderStyle;

var credits:String = 'Ghost tapping is forced off! Screw you!';

function preCreate() {
    PlayState.downscroll = true;
}

function postCreate() {
    PlayState.theFunne = false;
    PlayState.kadeEngineWatermark.y -= 20;
    var creditsWatermark:FlxText = new FlxText(4, healthBarBG.y + 50, 0, credits, 16);
    creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    creditsWatermark.scrollFactor.set();
    creditsWatermark.borderSize = 1.25;
    add(creditsWatermark);
    creditsWatermark.camera = camHUD;

    PlayState.instance.health = 2;
}

var elapsedTime:Float = 0;

function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    PlayState.instance.playerStrums.forEach(function(spr:StrumNote)
    {
        spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedTime + (spr.ID)) * 300);
        spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedTime + (spr.ID)) * 300);
    });
    PlayState.instance.dadStrums.forEach(function(spr:StrumNote)
    {
        spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedTime + (spr.ID )) * 2) * 300);
        spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedTime + (spr.ID)) * 2) * 300);
    });
}

function onNoteCreation(note:Note, isSustain:Bool) {
    if (FlxG.random.int(0, 120) == 1)
        note.scrollSpeed = 0.1;
    else
        note.scrollSpeed = FlxG.random.float(1,3);
}

function onDadHit() {
    FlxG.camera.shake(0.0075, 0.1);
	PlayState.instance.camHUD.shake(0.0045, 0.1);
    PlayState.instance.health -= (0.01 / 6);
}