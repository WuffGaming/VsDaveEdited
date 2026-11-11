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

import story.WeekTitle;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var weekList:Array<String> = CoolUtil.coolTextFile(Paths.txt('storymode/weekList'));

	var weekNames:Array<String> = [];

	var weekSongs:Array<Dynamic> = [];

	var weekColors:Array<FlxColor> = [];

	var weekTitles:FlxTypedGroup<WeekTitle>;

	var weekDatas:Array<Dynamic> = [];

	var curWeekSprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var propsCanDance:Bool = true;

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var curDifficulty:Int = 1;

	var weekBackground:FlxSprite;

	var txtTracklist:FlxText;
	var scoreText:FlxText;
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

		for (week in weekList) {
			if (Assets.exists(Paths.json('storymode/weeks/$week'))) {
				var weekData:StoryWeek = Paths.loadJSON('storymode/weeks/$week');
				weekDatas.push(weekData);
				weekNames.push(weekData.weekName);
				weekSongs.push(weekData.songList);
				weekColors.push(FlxColor.fromString(weekData.weekColor));
			}
			else {
				weekList.remove(week);
			}
		}

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		weekTitles = new FlxTypedGroup<WeekTitle>();
		add(weekTitles);

		weekBackground = new FlxSprite(0, 56).makeGraphic(FlxG.width * 2, 400, FlxColor.WHITE);
		add(weekBackground);

		for (i in 0...weekList.length)
		{
			var weekData:StoryWeek = weekDatas[i];

			var weekThing:WeekTitle = new WeekTitle(0, weekBackground.y + weekBackground.height + 10, weekData.weekTitle);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekTitles.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
		}

		
		add(weekBackground);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		add(curWeekSprites);

		addWeekProps(weekDatas[curWeek]);
		weekBackground.color = weekColors[curWeek];
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(weekTitles.members[0].x + weekTitles.members[0].width + 10, weekTitles.members[0].y + 10);
		leftArrow.frames = Paths.getSparrowAtlas('storyMenus/difficulties/arrow');
		leftArrow.animation.addByPrefix('idle', "arrow0");
		leftArrow.animation.addByPrefix('press', "arrow push0");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 55, leftArrow.y - 10);
		sprDifficulty.loadGraphic(Paths.image('storyMenus/difficulties/easy'));
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 5, leftArrow.y);
		rightArrow.frames = Paths.getSparrowAtlas('storyMenus/difficulties/arrow');
		rightArrow.animation.addByPrefix('idle', 'arrow0');
		rightArrow.animation.addByPrefix('press', "arrow push0", 24, false);
		rightArrow.flipX = true;
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

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

	function addWeekProps(weekData:StoryWeek) {
		// ok we clear it
		for (prop in curWeekSprites) prop.destroy();
		curWeekSprites.clear();

		for (prop in weekData.props) {
			var propSprite:FlxSprite = new FlxSprite(prop.position[0], prop.position[1]);
            if (prop.animations != null)
            {
                var tex:FlxAtlasFrames = Paths.getSparrowAtlas('storyMenus/weekProps/' + prop.path);
                propSprite.frames = tex;
                if (propSprite.frames != null)
                    for (anim in prop.animations)
                    {
                        var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
                        var looped = anim.looped == null ? true : anim.looped;

                        if (anim.indices != null)
                        {
                            propSprite.animation.addByIndices(anim.name, anim.prefix, anim.indices, "", frameRate, looped, anim.flipX);
                        }
                        else
                        {
                            propSprite.animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, anim.flipX);
                        }
                        if (anim.offset != null)
                        {
                            propSprite.x += anim.offset[0];
                            propSprite.y += anim.offset[1];
                        }
                        propSprite.animation.play(anim.name, true);
                    }
            }
            else
            {
                propSprite.loadGraphic(Paths.image('storyMenus/weekProps/' + prop.path));
            }

            if (prop.antialiasing != null)
                propSprite.antialiasing = prop.antialiasing;
            else
                propSprite.antialiasing = true;
            if (prop.scale != null)
                propSprite.scale.set(prop.scale[0], prop.scale[1]);

            if (prop.graphicSize != null)
                propSprite.setGraphicSize(Std.int(propSprite.width * prop.graphicSize));

            if (prop.scroll != null)
                propSprite.scrollFactor.set(prop.scroll[0], prop.scroll[1]);

            if (prop.visible != null)
                propSprite.visible = prop.visible;

            if (prop.flipX != null)
                propSprite.flipX = prop.flipX;

            if (prop.flipY != null)
                propSprite.flipY = prop.flipY;

            if (prop.alpha != null)
                propSprite.alpha = prop.alpha;

            propSprite.updateHitbox();
            curWeekSprites.add(propSprite);
		}
	}
	
	override function beatHit() {
		super.beatHit();
		for (prop in curWeekSprites) {
			if (prop.animation.exists('idle') && propsCanDance) prop.animation.play('idle');
		}
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

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
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
		if (!stopspamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			weekTitles.members[curWeek].startFlashing();
			stopspamming = true;
		}

		propsCanDance = false;
		for (prop in curWeekSprites) if (prop.animation.exists('hey')) prop.animation.play('hey', true);

		PlayState.storyPlaylist = weekSongs[curWeek];
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
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}
	function updateDifficultySprite()
	{
		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.loadGraphic(Paths.image('storyMenus/difficulties/easy'));
			case 1:
				sprDifficulty.loadGraphic(Paths.image('storyMenus/difficulties/normal'));
			case 2:
				sprDifficulty.loadGraphic(Paths.image('storyMenus/difficulties/hard'));
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

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;
		if (curWeek >= weekList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekList.length - 1;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		addWeekProps(weekDatas[curWeek]);
		updateDifficultySprite();
		
		var bullShit:Int = 0;
		
		for (item in weekTitles.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxTween.color(weekBackground, 0.25, weekBackground.color, weekColors[curWeek]);

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekSongs[curWeek];

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
