package;

import flixel.math.FlxPoint;
import openfl.display.Shader;
import flixel.tweens.FlxTween;
import haxe.Log;
import flixel.input.gamepad.lists.FlxBaseGamepadList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var blackScreen:FlxSprite;

	var curCharacter:String = '';
	var curMod:String = '';

	var dialogueList:Array<DialogueSequence>;

	var dialogueSound:String = 'pixelText';

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	var dialogueData:Dialogue;

	public var finishThing:Void->Void;

	var curPortrait:FlxSprite;

	var textBoxSizeFix:Float = 7;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var debug:Bool = false;

	public static var randomNumber:Int;

	public function new(talkingRight:Bool = true, dialogueJson:String)
	{
		super();

		dialogueData = cast Paths.loadSongJSON(dialogueJson);

		dialogueList = dialogueData.sequences;
		if (dialogueData.music != null) {
			FlxG.sound.playMusic(Paths.externmusic(dialogueData.music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		FlxTween.tween(bgFade, {alpha: 0.7}, 4.15);
		var curBox = 'default';
		if (dialogueData.box != null && Assets.exists(Paths.json('dialogue/boxes/${dialogueData.box}')))
			curBox = dialogueData.box;

		var boxData:Box = cast Paths.loadJSON('dialogue/boxes/$curBox');
		var boxOffset = boxData.offset;
		if (boxOffset == null)
			boxOffset = [0, 0];
		box = new FlxSprite(-20 + boxOffset[0], 400 + boxOffset[1]);
		box.frames = Paths.getSparrowAtlas('ui/dialogue/boxes/' + boxData.sprite);
		box.setGraphicSize(Std.int(box.width / textBoxSizeFix));
		box.updateHitbox();
		
		if (boxData.animations != null) {
			for (anim in boxData.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipx = anim.flipX == null ? false : anim.flipX;
				var flipy = anim.flipY == null ? false : anim.flipY;

				if (anim.indices != null)
				{
					box.animation.addByIndices(anim.name, anim.prefix, anim.indices, "", frameRate, looped, flipx, flipy);
				}
				else
				{
					box.animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipx, flipy);
				}
			}
		}
		else
		{
			box.animation.addByPrefix('open', 'Speech Bubble Normal Open', 24, false);
			box.animation.addByPrefix('idle', 'speech bubble normal', 24, true);
		}
		box.antialiasing = true;
		if (boxData.antialiasing != null)
			box.antialiasing = boxData.antialiasing;

		blackScreen = new FlxSprite(0, 0).makeGraphic(5000, 5000, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 0;
		add(blackScreen);
		
		var hasDialog = true;
		
		if (!hasDialog)
			return;

		curPortrait = new FlxSprite(220, 450);
		curPortrait.visible = false;
		add(curPortrait);

		box.animation.play('open');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = Paths.font(dialogueData.font == null ? 'comic.ttf' : dialogueData.font);
		var shit:Null<String> = dialogueData.textShadowColor == null ? '0xFF00137F' : dialogueData.textShadowColor;
		dropText.color = FlxColor.fromString(shit);
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = Paths.font(dialogueData.font == null ? 'comic.ttf' : dialogueData.font);
		var biggershit:Null<String> = dialogueData.textColor == null ? '0xFF000000' : dialogueData.textColor;
		swagDialogue.color = FlxColor.fromString(biggershit);
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound(dialogueSound), 0.6)];
		add(swagDialogue);

	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'open' && box.animation.curAnim.finished)
			{
				box.animation.play('idle');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted)
		{
			
			FlxG.sound.play(Paths.sound('textclickmodern'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
						
					FlxG.sound.music.fadeOut(2.2, 0);

					for (crap in [box, bgFade, curPortrait, swagDialogue, dropText]) {
						FlxTween.cancelTweensOf(crap);
						FlxTween.tween(crap, {alpha: 0}, 1.2);
					}


					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		curCharacter = dialogueList[0].character == null ? 'dave' : dialogueList[0].character;
		swagDialogue.resetText(dialogueList[0].text);
		var bullshitDelay:Null<Float> = dialogueList[0].delay == null ? 0.04 : dialogueList[0].delay;
		swagDialogue.start(bullshitDelay, true);

		for (text in [dropText, swagDialogue])
			text.font = Paths.font(dialogueList[0].font == null ? (dialogueData.font == null ? 'comic.ttf' : dialogueData.font) : dialogueList[0].font);

		if (dialogueList[0].events != null)
			for (event in dialogueList[0].events)
				causeEvent(event);
		
		if (curCharacter != 'generic')
		{
			curPortrait.visible = true;
			var pos = dialogueList[0].position.toLowerCase() == null ? 'left' : dialogueList[0].position.toLowerCase();
			changePortrait(curCharacter, pos);
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound(dialogueSound), 0.6)];
		}
		else
		{
			curPortrait.visible = false;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		}
	}

	function changePortrait(character:String, side:String)
	{
		curPortrait.loadGraphic(Paths.image('ui/dialogue/portraits/$character'));
		curPortrait.offset.set(0, 0);
		
		if (Assets.exists(Paths.json('dialogue/boxes/$character'))) {
			var portraitData:PortraitChar = cast Paths.loadJSON('dialogue/boxes/$character');

			curPortrait.antialiasing = true;
			if (portraitData.antialiasing != null) curPortrait.antialiasing = portraitData.antialiasing;

			var bullshit:Array<Float> = portraitData.offset == null ? [0,0] : portraitData.offset; // OH MY GOD
			curPortrait.offset.set(bullshit[0], bullshit[1]);
			dialogueSound = portraitData.dialogueSound == null ? 'pixelText' : portraitData.dialogueSound;
		}
		curPortrait.flipX = false;
		FlxTween.cancelTweensOf(curPortrait);
		switch(side.toLowerCase()) {
			case 'right':
				box.flipX = false;
				curPortrait.flipX = true;
				curPortrait.setPosition(920, 220);
				curPortrait.alpha = 0;
				FlxTween.tween(curPortrait, {x: curPortrait.x - 150, alpha: 1}, 0.15);
			case 'middle':
				box.flipX = false;
				curPortrait.setPosition(70, 220);
				curPortrait.screenCenter(X);
				curPortrait.y += 150;
				curPortrait.alpha = 0;
				
				FlxTween.tween(curPortrait, {y: curPortrait.y - 150, alpha: 1}, 0.15);
			default:
				box.flipX = true;
				curPortrait.setPosition(70, 220);
				curPortrait.alpha = 0;
				FlxTween.tween(curPortrait, {x: curPortrait.x + 150, alpha: 1}, 0.15);

		}
	}

	function causeEvent(event) {
		switch (event)
		{
			case 'to_black':
				FlxTween.tween(blackScreen, {alpha:1}, 0.25);
		}
	}
}

typedef PortraitChar = {
	var antialiasing:Null<Bool>; // Yeah

	var dialogueSound:String; // What sound does the Portrait use?

	var offset:Array<Float>; // Portrait offsets.
}

typedef Box = {
	var sprite:Null<String>; // Where the box's spritesheet is located at.

	var antialiasing:Null<Bool>; // I think you get this one.

	var animations:Array<SpriteDefs.AnimationData>; // Box's animations.

	var offset:Array<Float>; // Box Offsets
}

typedef DialogueSequence = {
	var character:Null<String>; // Character to be used for the dialogue sequence.
	var position:Null<String>; // Position of the character. 'LEFT', 'MIDDLE', or 'RIGHT'
	var font:Null<String>; // Possible override font.
	var text:Null<String>; // Text within the dialogue sequence.
	var delay:Null<Float>; // Delay between each character.
	var events:Array<String>; // Every event that happens during a sequence.
}

typedef Dialogue = {
	var box:Null<String>; // Box variant that will be used for the Dialogue Sequences
	var music:Null<String>; // The song that plays during the Dialogue Sequences.
	var textColor:Null<String>; // Color of the text
	var textShadowColor:Null<String>; // Ditto for the drop shadow.
	var font:Null<String>; // Default font to be used for each sequence.
	var sequences:Array<DialogueSequence>; // Every Dialogue Sequence that will occur.
}