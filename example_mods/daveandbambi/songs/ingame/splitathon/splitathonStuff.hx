// this is pretty much all copied from the source code

var daveExpressionSplitathon:Character;

var thing:FlxSprite = new FlxSprite(0, 250);
var splitathonExpressionAdded:Bool = false;

var BAMBICUTSCENEICONHURHURHUR:HealthIcon;

var stupidx:Float = 0;
var stupidy:Float = 0; // stupid velocities for cutscene
var updatevels:Bool = false;

var AUGHHHH:String;
var AHHHHH:String;

var nightColor = 0xFF878787;

function postCreate() {
    daveExpressionSplitathon = new Character(-100, 260, 'dave-splitathon');
    add(daveExpressionSplitathon);
    daveExpressionSplitathon.visible = false;
}

function stepHit(curStep:Int) {
    switch (curStep)
    {
        case 4750:
            dad.canDance = false;
            dad.playAnim('scared', true);
            camHUD.shake(0.015, (Conductor.stepCrochet / 1000) * 50);
        case 4800:
            FlxG.camera.flash(FlxColor.WHITE, 1);
            splitterThonDave('what');
            PlayState.instance.switchDad("bambi-splitathon");
            PlayState.dad.color = nightColor;
            throwThatBitchInThere('bambi', 'dave');
        case 5824:
            FlxG.camera.flash(FlxColor.WHITE, 1);
            splitathonExpression('bambi-what', -100, 550);
            PlayState.instance.switchDad("dave-splitathon");
            PlayState.dad.color = nightColor;
            throwThatBitchInThere('dave', 'bambi');
        case 6080:
            FlxG.camera.flash(FlxColor.WHITE, 1);
            splitterThonDave('happy');
            PlayState.instance.switchDad("bambi-splitathon");
            PlayState.dad.color = nightColor;
            throwThatBitchInThere('bambi', 'dave');
        case 8384:
            FlxG.camera.flash(FlxColor.WHITE, 1);
            splitathonExpression('bambi-corn', -100, 550);
            PlayState.instance.switchDad("dave-splitathon");
            PlayState.dad.color = nightColor;
            throwThatBitchInThere('dave', 'bambi');
    }
}

function update(elapsed:Float) {
    if (updatevels)
    {
        stupidx *= 0.98;
        stupidy += elapsed * 6;
        if (BAMBICUTSCENEICONHURHURHUR != null)
        {
            BAMBICUTSCENEICONHURHURHUR.x += stupidx;
            BAMBICUTSCENEICONHURHURHUR.y += stupidy;
        }
    }
}

function splitathonExpression(expression:String, x:Float, y:Float):Void
{
    daveExpressionSplitathon.visible = false;
    if (expression != 'lookup')
    {
        camFollow.setPosition(dad.getGraphicMidpoint().x + 100, boyfriend.getGraphicMidpoint().y + 150);
    }
    thing.color = nightColor;
    thing.x = x;
    thing.y = y;
    thing.visible = true;
    remove(dad);

    switch (expression)
    {
        case 'bambi-what':
            thing.frames = Paths.getSparrowAtlas('stages/splitathon/Bambi_WaitWhatNow');
            thing.animation.addByPrefix('uhhhImConfusedWhatsHappening', 'what', 24);
            thing.animation.play('uhhhImConfusedWhatsHappening');
        case 'bambi-corn':
            thing.frames = Paths.getSparrowAtlas('stages/splitathon/Bambi_ChillingWithTheCorn');
            thing.animation.addByPrefix('justGonnaChillHereEatinCorn', 'cool', 24);
            thing.animation.play('justGonnaChillHereEatinCorn');
    }
    if (!splitathonExpressionAdded)
    {
        splitathonExpressionAdded = true;
        add(thing);
    }
    thing.antialiasing = true;
}

//this is cuz splitathon dave expressions are now baked INTO the sprites! so cool! bonuses of this include:
// - Not having to cache every expression
// - Being able to reuse them for other things (ie. lookup for scared)
function splitterThonDave(expression:String):Void
{
    thing.visible = false;
    daveExpressionSplitathon.visible = true;
    
    daveExpressionSplitathon.color = nightColor;
    daveExpressionSplitathon.canDance = false;
    daveExpressionSplitathon.playAnim(expression, true);
}

function throwThatBitchInThere(guyWhoComesIn:String = 'bambi', guyWhoFliesOut:String = 'dave')
{
    updatevels = false;
    if(BAMBICUTSCENEICONHURHURHUR != null)
    {
        remove(BAMBICUTSCENEICONHURHURHUR);
    }
    BAMBICUTSCENEICONHURHURHUR = new HealthIcon(guyWhoComesIn, false);
    BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
    add(BAMBICUTSCENEICONHURHURHUR);
    BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
    BAMBICUTSCENEICONHURHURHUR.x = -100;
    FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
    AUGHHHH = guyWhoComesIn;
    AHHHHH = guyWhoFliesOut;
    new FlxTimer().start(0.3, ()->{
        iconP2.changeIcon(AUGHHHH, true);
        BAMBICUTSCENEICONHURHURHUR.changeIcon(AHHHHH, true, false, 1);
        stupidx = -5;
        stupidy = -5;
        updatevels = true;
    });
}