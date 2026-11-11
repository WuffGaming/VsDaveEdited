package;

import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import openfl.ui.Keyboard;
import flixel.util.FlxCollision;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	var indexoften:Int = 1;

	var weekNames:Array<String> = [];

	var weekData:Array<String> = [];

	var curWeekSprites:Array<Dynamic> = [];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var curIndex:Int = 0;

	var weekBackground:FlxSprite;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Story Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		weekBackground = new FlxSprite(0, 56).makeGraphic(FlxG.width * 2, 400, FlxColor.WHITE);
		weekBackground.color = 0xFFFFFFFF;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, weekBackground.y + weekBackground.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
		}

		// do prop adding here

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = Paths.getSparrowAtlas('storyMenu/difficulties/arrow');
		leftArrow.animation.addByPrefix('idle', "arrow");
		leftArrow.animation.addByPrefix('press', "arrow push");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.loadGraphic(Paths.image('storyMenu/difficulties/easy'));
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = leftArrow.frames;
		rightArrow.animation.addByPrefix('idle', 'arrow');
		rightArrow.animation.addByPrefix('press', "arrow push", 24, false);
		rightArrow.flipX = true;
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(weekBackground);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, weekBackground.x + weekBackground.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("vcr.ttf"), 32);
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		super.create();
	}

	function FadeOut()
	{
		FlxG.switchState(()->new StoryMenuState());
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new StoryMenuState());
		}
		#end

		scoreText.text = "WEEK SCORE:" + lerpScore;
		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT && !dofunnytristan)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek && !dofunnytristan)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(()->new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (!stopspamming)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "normal";

			switch (curDifficulty)
			{
				case 0:
					diffic = 'easy';
				case 2:
					diffic = 'hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), diffic);
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				PlayState.characteroverride = "none";
				PlayState.curmult = [1, 1, 1, 1];
				switch (PlayState.storyWeek)
				{
					default:
						LoadingState.loadAndSwitchState(new PlayState(), true);

				}
				
			});
			//new FlxTimer().start(1, function(tmr:FlxTimer)
			//{
			//	LoadingState.loadAndSwitchState(new CharacterSelectState(), true);
			//});
			//uncomment out the above code and comment out the other loadandswitchstate to allow for character selection in story mode!
		}
	}
	function updateDifficultySprite()
	{
		sprDifficulty.offset.x = 0;
		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.loadGraphic(Paths.image('storyMenu/difficulties/easy'));
			case 1:
				sprDifficulty.loadGraphic(Paths.image('storyMenu/difficulties/normal'));
			case 2:
				sprDifficulty.loadGraphic(Paths.image('storyMenu/difficulties/hard'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;
		
		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		updateDifficultySprite();

		if(curWeek != 3)
			sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		if(curWeek != 3)
			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curIndex += change;
		if (curIndex >= weekData.length)
			curIndex = 0;
		if (curIndex < 0)
			curIndex = weekData.length - 1;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		updateDifficultySprite();
		
		var bullShit:Int = 0;
		
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - ((curIndex > indexoften) ? curIndex - 1 : curIndex);
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxTween.color(weekBackground, 0.25, weekBackground.color, songColors[curWeek]);

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text = txtTracklist.text += "\n";

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}

typedef StoryWeek = {
	var weekName:String; // Title of the Week.

	var weekTitle:String; // Path to Week's Title

	var weekColor:String; // Color of the week's background.

	var songList:Array<String>; // Every song in a week.

	var props:Array<SpriteDefs.PropData>; // Array of all week props.
}
