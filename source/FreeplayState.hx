package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var bg:FlxSprite = new FlxSprite();

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var curChar:String = "unknown";

	private var inFreeplay:Bool = false;

	private var curIcon:FlxSprite;

	private var categoryList:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplay/categoryList'));

	private var curCategory:Int = 0;

	private var nameAlpha:Alphabet;

	var loadingPack:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		
		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		bg.loadGraphic(MainMenuState.randomizeBG());
		bg.color = 0xFF4965FF;
		add(bg);

		curIcon = new FlxSprite(0,0).loadGraphic(Paths.image('freeplay/categories/' + (categoryList[curCategory].toLowerCase())));

		curIcon.centerOffsets(false);
		curIcon.x = (FlxG.width / 2) - 256;
		curIcon.y = (FlxG.height / 2) - 256;
		curIcon.antialiasing = true;

		nameAlpha = new Alphabet(40,(FlxG.height / 2) - 282,categoryList[curCategory],true,false);
		nameAlpha.screenCenter(X);
		Highscore.load();
		add(nameAlpha);

		add(curIcon);

		super.create();
	}

	public function loadPackSongs()
	{
		var categoryData:CategoryData = cast Paths.loadJSON('freeplay/categories/' + categoryList[curCategory].toLowerCase());
		for (song in categoryData.songs) {
			var name:String = song.name == null ? 'House' : song.name;
			var displayName = song.displayName == null ? name : song.displayName;
			var color:FlxColor = song.color == null ? 0xFF4965FF : FlxColor.fromString(song.color);
			var icon:String = song.icon == null ? 'face' : song.icon;
			var charSelect:Bool = song.characterSelect == null ? true : song.characterSelect;
			addSong(name, displayName, color, icon, charSelect);
		}
	}

	public function toSongList()
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].displayName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.y = -200;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.y = -200;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.y = -200;

		add(diffText);

		add(scoreText);

		FlxTween.tween(scoreBG,{y: 0},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(scoreText,{y: 5},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(diffText,{y: 40},0.5,{ease: FlxEase.expoInOut});

		changeSelection();
		changeDiff();

	}

	public function addSong(songName:String, displayName:String, color:FlxColor, songCharacter:String, charSelect:Bool)
	{
		songs.push(new SongMetadata(songName, displayName, color, songCharacter, charSelect));
	}

	public function updatePackSelection(change:Int)
	{
		curCategory += change;
		if (curCategory == -1)
		{
			curCategory = categoryList.length - 1;
		}
		if (curCategory == categoryList.length)
		{
			curCategory = 0;
		}
		var categoryData:CategoryData = cast Paths.loadJSON('freeplay/categories/' + categoryList[curCategory].toLowerCase());
		nameAlpha.destroy();
		nameAlpha = new Alphabet(40,(FlxG.height / 2) - 282,(categoryData.displayName == null ? categoryList[curCategory] : categoryData.displayName),true,false);
		nameAlpha.screenCenter(X);
		add(nameAlpha);
		curIcon.loadGraphic(Paths.image('freeplay/categories/' + (categoryData.icon == null ? categoryList[curCategory].toLowerCase() : categoryData.icon)));
	}

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);


		if (!inFreeplay) 
		{
			if (controls.LEFT_P)
			{
				updatePackSelection(-1);
			}
			if (controls.RIGHT_P)
			{
				updatePackSelection(1);
			}
			if (controls.ACCEPT && !loadingPack)
			{
				loadingPack = true;
				loadPackSongs();
				FlxTween.tween(curIcon, {alpha: 0}, 0.3);
				FlxTween.tween(nameAlpha, {alpha: 0}, 0.3);
				new FlxTimer().start(0.5, function(Dumbshit:FlxTimer)
				{
					curIcon.visible = false;
					nameAlpha.visible = false;
					toSongList();
					inFreeplay = true;
					loadingPack = false;
				});
			}
			if (controls.BACK)
			{
				FlxG.switchState(()->new MainMenuState());
			}	
		
			return;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(()->new FreeplayState());
		}

		if (accepted)
		{
			var chartOfSong:String = Highscore.getDifficulty(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(chartOfSong);

			PlayState.SONG = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), chartOfSong);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			LoadingState.loadAndSwitchState((songs[curSelected].charSelect ? new CharacterSelectState() : new PlayState()));
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end
		curChar = Highscore.getChar(songs[curSelected].songName, curDifficulty);
		updateDifficultyText();
		
	}

	function updateDifficultyText()
	{
		var stupidBitch = curChar;
		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY" + " - " + stupidBitch.toUpperCase();
			case 1:
				diffText.text = 'NORMAL' + " - " + stupidBitch.toUpperCase();
			case 2:
				diffText.text = "HARD" + " - " + stupidBitch.toUpperCase();
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
			curSelected = 0;

		if (curDifficulty < 0)
			curDifficulty = 2;

		if (curDifficulty > 2)
			curDifficulty = 0;

		curChar = Highscore.getChar(songs[curSelected].songName, curDifficulty);
		updateDifficultyText();

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		FlxTween.color(bg, 0.25, bg.color, songs[curSelected].color);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var displayName:String = "";
	public var color:FlxColor = 0xFF4965FF;
	public var songCharacter:String = "";
	public var charSelect:Bool = true;

	public function new(song:String, displayName:String, color:FlxColor, songCharacter:String, charSelect:Bool)
	{
		this.songName = song;
		this.displayName = displayName;
		this.color = color;
		this.songCharacter = songCharacter;
		this.charSelect = charSelect;
	}
}

typedef CategoryData = {
	var icon:Null<String>; // Path to category's icon.
	var displayName:Null<String>; // Display name for the category.
	var songs:Array<CategorySong>; // Every song in the category.
}

typedef CategorySong = {
	var name:Null<String>; // Name of the song in the category.
	var displayName:Null<String>; // Optional display name for the song.
	var color:Null<String>; // Color of the song in the category.
	var icon:Null<String>; // Icon Name of the song in the category.
	var characterSelect:Null<Bool>; // Does category let you select custom characters?
}