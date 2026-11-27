package;

import flixel.tweens.misc.ColorTween;
import flixel.math.FlxRandom;
import openfl.net.FileFilter;
import openfl.filters.BitmapFilter;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flash.system.System;
#if desktop
import Discord.DiscordClient;
#end

import modding.scripting.HScriptPack;

#if sys 
import sys.io.File;
import sys.io.Process;
#end

import stage.Stage;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var characteroverride:String = "none";
	public static var formoverride:String = "none";
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var curmult:Array<Float> = [1, 1, 1, 1];

	public var elapsedtime:Float = 0;

	public var storyDifficultyText:String = "";
	public var iconRPC:String = "";
	public var detailsText:String = "";
	public var detailsPausedText:String = "";

	public var boyfriendOldIcon:String = 'bf-old';

	public var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var instance:PlayState = null; // Current PlayState, allows other objects to access certain values.

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;

	public static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;

	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var dadStrums:FlxTypedGroup<StrumNote>;

	public var camZooming:Bool = false;
	public var focusOnDadGlobal:Bool = true;
	public var autoZoomCam:Bool = true;
	public var curSong:String = "";


	public var iconDanceBeat:Int = 4;
	public var camDanceBeat:Int = 4;

	public var health:Float = 1;
	public var combo:Int = 0;

	public var misses:Int = 0;

	public var accuracy:Float = 0.00;
	public var totalNotesHit:Float = 0;
	public var totalPlayed:Int = 0;
	public var ss:Bool = false;

	public static var eyesoreson = true;

	public static var downscroll:Bool = false;

	public static var healthBarBG:FlxSprite;
	public static var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camDialogue:FlxCamera;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var dialogue:String = '';

	public var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public var fc:Bool = true;

	public var talking:Bool = true;
	public var songScore:Int = 0;

	public static var scoreTxt:FlxText;

	public static var kadeEngineWatermark:FlxText;
	
	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	public var inCutscene:Bool = false;

	public var doIconBounce:Bool = true; // for icons

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	public var stage:Stage;

	public var scriptPack:HScriptPack;

	override public function create()
	{
		instance = this;
		super.create();
		theFunne = Settings.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		eyesoreson = Settings.data.eyesores;
		downscroll = Settings.data.downscroll;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;

		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();

		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay Mode: ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		curStage = "";

		// Updating Discord Rich Presence.
		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end



		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camDialogue = new FlxCamera();
		camDialogue.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camDialogue, false);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('house', 'hard');
		scriptPack = new HScriptPack(Paths.getScriptArray(SONG.song.toLowerCase()));

		scriptPack.setScripts("camHUD", camHUD);
		scriptPack.setScripts("camGame", camGame);
		scriptPack.setScripts("camDialogue", camDialogue);
		
		scriptPack.setScripts("add", add);
		scriptPack.setScripts("remove", remove);
		scriptPack.setScripts("insert", insert);

		scriptPack.callScripts("preCreate");

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		
		var defaultDialoguePath = 'ingame/' + SONG.song + '/dialogue';
		if (Assets.exists(Paths.songJson(defaultDialoguePath)))
			dialogue = defaultDialoguePath;

		
		stage = new Stage(SONG.stage);
		curStage = stage.name;
		defaultCamZoom = stage.cameraZoom;
		add(stage);

		var gfVersion:String = 'gf';

		if(SONG.gf != null)
		{
			gfVersion = SONG.gf;
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		gf.x += gf.gameOffset[0];
		gf.y += gf.gameOffset[1];

		dad = new Character(100, 100, SONG.player2);

		dad.x += dad.gameOffset[0];
		dad.y += dad.gameOffset[1];
		

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + dad.camOffset[0], dad.getGraphicMidpoint().y + dad.camOffset[1]);

		if (formoverride == "none" || formoverride == "bf")
		{
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		}
		else
		{
			boyfriend = new Boyfriend(770, 450, formoverride);
		}

		boyfriend.x += boyfriend.gameOffset[0];
		boyfriend.y += boyfriend.gameOffset[1];

		boyfriendOldIcon = boyfriend.altIcon;

		for (char in [gf, dad,boyfriend]) {
			add(char);
			hookToChar(char.curCharacter, char);
		}
		scriptPack.callScripts("create");

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();

		dadStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('ui/game/healthBar'));
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		
		var engineName:String = 'Dav:E';
		kadeEngineWatermark = new FlxText(4, healthBarBG.y + 50, 0,
		SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + " - " + engineName + " Engine (KE 1.2)", 16);
		kadeEngineWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		kadeEngineWatermark.borderSize = 1.25;
		add(kadeEngineWatermark);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 40, 0, "", 20);
		if (!Settings.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.5;
		add(scoreTxt);

		// add icons because i felt like it
		iconP1 = new HealthIcon(boyfriend.icon, true);
		iconP2 = new HealthIcon(dad.icon, false);

		add(iconP1);
		add(iconP2);

		updateIcons();

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		doof.cameras = [camDialogue];

		startingSong = true;

		if (isStoryMode || Settings.data.freeplayCuts)
		{
			// find dialogue
			if (Assets.exists(Paths.songJson(defaultDialoguePath)))
				startDialogue(doof);
			else
				startCountdown();
		}
		else
		{
			startCountdown();
		}
		scriptPack.setScripts("scoreTxt", scoreTxt);
		scriptPack.setScripts("kadeEngineWatermark", kadeEngineWatermark);
		scriptPack.setScripts("iconP1", iconP1);
		scriptPack.setScripts("iconP2", iconP2);
		scriptPack.setScripts("isStoryMode", isStoryMode);
		scriptPack.setScripts("healthBarBG", healthBarBG);
		scriptPack.setScripts("healthBar", healthBar);

		for (i in [scriptPack, stage.scriptPack])
			i.callScripts("postCreate");
	}

	function startDialogue(?dialogueBox:DialogueBox, isStart:Bool = true):Void
	{
		scriptPack.callScripts("onStartDialogue", [dialogueBox, isStart]);
		inCutscene = true;
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x - 200, dad.getGraphicMidpoint().y - 10);
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var stupidBasics:Float = 1;
		if (isStart)
		{
			FlxTween.tween(black, {alpha: 0}, stupidBasics);
		}
		else
		{
			black.alpha = 0;
			stupidBasics = 0;
		}
		new FlxTimer().start(stupidBasics, function(fuckingSussy:FlxTimer)
		{
			if (dialogueBox != null)
			{
				add(dialogueBox);
			}
			else
			{
				startCountdown();
			}
		});
		scriptPack.callScripts("postStartDialogue", [dialogueBox, isStart]);
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		scriptPack.callScripts("onCountdown");
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.dance();
			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/game/ready'));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
					focusOnDadGlobal = true;
					ZoomCam(true);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/game/set'));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/game/go'));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
					focusOnDadGlobal = true;
					ZoomCam(true);
				case 4:
			}
			swagCounter += 1;
		}, 5);
		scriptPack.callScripts("onPostCountdown");
	}

	var previousFrameTime:Float = 0;
	var lastReportedPlayheadPosition:Float = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		scriptPack.callScripts("onSongStart");
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst('ingame/' + PlayState.SONG.song + '/song'), 1, false);
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		FlxG.sound.music.onComplete = endSong;
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		// ok lets preload the song stuff
		FlxG.sound.load(Paths.inst('ingame/' + PlayState.SONG.song + '/song'));
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices('ingame/' + PlayState.SONG.song + '/song'));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		// this handles note creation crap and stuff lol
		for (section in noteData)
		{

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, daNoteStyle);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				scriptPack.callScripts('onNoteCreation', [swagNote, false]);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, gottaHitNote);
					sustainNote.scrollFactor.set();
					scriptPack.callScripts('onNoteCreation', [sustainNote, true]);

					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		scriptPack.callScripts("onGenerateStaticArrows", [player]);
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(0, strumLine.y);
			var style = player == 1 ? boyfriend.noteStyle : dad.noteStyle;

			babyArrow.frames = Paths.getSparrowAtlas('ui/game/notes/' + style);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				dadStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
			scriptPack.callScripts("onStrumNoteCreation", [babyArrow]);
		}
		scriptPack.callScripts("onPostGenerateStaticArrows", [player]);
	}
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") |",
				"Acc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
			scriptPack.callScripts("postPause");
		}

		super.openSubState(SubState);
	}

	public override function destroy() {
		scriptPack.callScripts("onDestroy");
		super.destroy();

		instance = null;
	}

	override function closeSubState()
	{
		if (paused)
		{
			scriptPack.callScripts("onUnpause");
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			if (startTimer.finished)
				{
					#if desktop
					DiscordClient.changePresence(detailsText
						+ " "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") ",
						"\nAcc: "
						+ truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, true,
						FlxG.sound.music.length
						- Conductor.songPosition);
					#end
				}
				else
				{
					#if desktop
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
					#end
				}
			scriptPack.callScripts("postUnpause");
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		scriptPack.callScripts("update", [elapsed]);
		super.update(elapsed);
		elapsedtime += elapsed;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == boyfriendOldIcon)
			{
				var isBF:Bool = formoverride == 'bf' || formoverride == 'none';
				iconP1.animation.play(isBF ? SONG.player1 : formoverride);
			}
			else
			{
				iconP1.animation.play(boyfriendOldIcon);
			}
		}

		if (Settings.data.accuracyDisplay)
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% ";
		}
		else
		{
			scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% ";
		}
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			var doGitaroo:Bool = true;
			scriptPack.callScripts("onPause", [doGitaroo]);

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1) && doGitaroo)
			{
				// gitaroo man easter egg
				FlxG.switchState(()->new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			var chartEditor:Bool = true;
			scriptPack.callScripts("onChartEditor", [chartEditor]);
			if (chartEditor) {
				//FlxG.switchState(()->new ChartingState());
				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
			}
		}

		if (doIconBounce) {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.8)),Std.int(FlxMath.lerp(150, iconP1.height, 0.8)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.8)),Std.int(FlxMath.lerp(150, iconP2.height, 0.8)));

			iconP1.updateHitbox();
			iconP2.updateHitbox();

			var iconOffset:Int = 26;

			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;

		if (iconP1.animatedIcon != true)
		{
			healthBar.percent < 20 ? {iconP1.animation.curAnim.curFrame = 1; iconP1.losing = true;} : {iconP1.animation.curAnim.curFrame = 0; iconP1.losing = false;};
		}
		if (iconP2.animatedIcon != true)
		{
			healthBar.percent > 80 ? {iconP2.animation.curAnim.curFrame = 1; iconP2.losing = true;} : {iconP2.animation.curAnim.curFrame = 0; iconP2.losing = false;};
		}
		if (iconP1.animatedIcon == true)
		{
			healthBar.percent < 20 ? iconP1.losing = true : iconP1.losing = false;
		}
		if (iconP2.animatedIcon != true)
		{
			healthBar.percent > 80 ? iconP2.losing = true : iconP2.losing = false;
		}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0)
		{
			if(!perfectMode)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
	
				vocals.stop();
				FlxG.sound.music.stop();
			}

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, boyfriend.deadForm));

			#if desktop
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") ",
				"\nAcc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				dunceNote.finishedGenerating = true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					//'LEFT', 'DOWN', 'UP', 'RIGHT'
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(daNote.noteData)) % 4];
					if(dad.nativelyPlayable)
					{
						switch(notestuffs[Math.round(Math.abs(daNote.noteData)) % 4])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
					scriptPack.callScripts('onDadHit', [daNote]);
					scriptPack.callScripts('onNoteHit', [daNote]);
					dad.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
					dadStrums.forEach(function(sprite:StrumNote) {
					if (Math.abs(Math.round(Math.abs(daNote.noteData)) % 4) == sprite.ID)
						{
							sprite.playAnim('confirm', true);
							sprite.centerOffsets();

							sprite.animation.onFinish.add(function(name:String)
							{
								sprite.playAnim('static',true);
								sprite.centerOffsets();
							});

						}
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				var strumliney = daNote.linkedStrumNote != null ? daNote.linkedStrumNote.y : strumLine.y;

				if (downscroll)
					daNote.y = (strumliney - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(SONG.speed * daNote.scrollSpeed, 2)));
				else
					daNote.y = (strumliney - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed * daNote.scrollSpeed, 2)));
				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				//todo: better method?
				

				if (daNote.y >= strumliney + 106 && downscroll || daNote.y < -daNote.height && !downscroll)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						if(daNote.mustPress && daNote.finishedGenerating)
							noteMiss(daNote.noteData);
						health -= 0.075;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		ZoomCam(focusOnDadGlobal);

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		scriptPack.callScripts("postUpdate", [elapsed]);
	}

	public function switchDad(char:String, x:Float = 100, y:Float = 100, reposition:Bool = true)
	{
		if (dad != null)
			remove(dad);
		dad = new Character(x, y, char, false);
		if (reposition)
		{
			dad.x += dad.gameOffset[0];
			dad.y += dad.gameOffset[1];
		}
		add(dad);
		hookToChar(dad.curCharacter, dad);
	}

	public function switchBf(char:String, x:Float = 100, y:Float = 100, reposition:Bool = true)
	{
		if (boyfriend != null)
			remove(boyfriend);
		boyfriend = new Boyfriend(x, y, char);
		if (reposition)
		{
			boyfriend.x += boyfriend.gameOffset[0];
			boyfriend.y += boyfriend.gameOffset[1];
		}
		add(boyfriend);
		hookToChar(boyfriend.curCharacter, boyfriend);
	}

	public function switchGf(char:String, x:Float = 100, y:Float = 100, reposition:Bool = true)
	{
		if (gf != null)
			remove(gf);
		gf = new Character(x, y, char, false);
		if (reposition)
		{
			gf.x += gf.gameOffset[0];
			gf.y += gf.gameOffset[1];
		}
		add(gf);
		hookToChar(gf.curCharacter, gf);
	}

	public function ZoomCam(focusondad:Bool):Void
	{
		scriptPack.callScripts("onZoomCam", [focusondad]);
		var bfplaying:Bool = false;
		if (focusondad)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (!bfplaying)
				{
					if (daNote.mustPress)
					{
						bfplaying = true;
					}
				}
			});
		}
		if (focusondad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150 + dad.camOffset[0], dad.getMidpoint().y - 100 + dad.camOffset[1]);
		}

		if (!focusondad)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.camOffset[0], boyfriend.getMidpoint().y - 100 + boyfriend.camOffset[1]);
		}
		scriptPack.callScripts("postZoomCam", [focusondad]);
	}

	function endSong():Void
	{
		var canEnd:Bool = true;
		scriptPack.callScripts("onEndSong", [canEnd]);
		if (canEnd) {
			inCutscene = false;
			canPause = false;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;
			if (SONG.validScore)
			{
				trace("score is valid");
				#if !switch
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, characteroverride == "none"
					|| characteroverride == "bf" ? "bf" : characteroverride);
				#end
			}

			if (isStoryMode) {
				campaignScore += songScore;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0) // end dialogue shit
				{
					FlxG.switchState(()->new StoryMenuState());

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore,
							storyDifficulty, characteroverride == "none" || characteroverride == "bf" ? "bf" : characteroverride);
					}

					Settings.save();
				}
				else
					nextSong();
			}
			else
				FlxG.switchState(()->new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	function nextSong()
	{
		var canContinue:Bool = true;
		scriptPack.callScripts("onNextSong", [canContinue]);
		var difficulty:String = "normal";

		if (storyDifficulty == 0)
			difficulty = 'easy';

		if (storyDifficulty == 2)
			difficulty = 'hard';

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), difficulty);
		FlxG.sound.music.stop();
		if (canContinue)
			LoadingState.loadAndSwitchState(new PlayState());
	}
	private function popUpScore(strumtime:Float, notedata:Int):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = -3000;
			ss = false;
			shits++;
		}
		else if (noteDiff < Conductor.safeZoneOffset * -2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = -3000;
			ss = false;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'bad';
			score = -1000;
			totalNotesHit += 0.2;
			ss = false;
			bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			totalNotesHit += 0.65;
			score = 200;
			ss = false;
			goods++;
		}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			sicks++;
		}
		switch (notedata)
		{
			case 2:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[2], 0), Int);
			case 3:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[3], 0), Int);
			case 1:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[1], 0), Int);
			case 0:
				score = cast(FlxMath.roundDecimal(cast(score, Float) * curmult[0], 0), Int);
		}

		scriptPack.callScripts("onPopupScore", [daRating, score]);

		if (daRating != 'shit' || daRating != 'bad')
		{
			rating.loadGraphic(Paths.image('ui/game/rating/$daRating'));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/game/rating/combo'));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;

			comboSpr.updateHitbox();
			rating.updateHitbox();

			scriptPack.callScripts("onRatingPopup", [rating, comboSpr]);
			songScore += score;

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/game/rating/num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				scriptPack.callScripts("onNumScorePopup", [numScore]);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						remove(numScore, true);
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					remove(coolText, true);
					remove(comboSpr, true);
					remove(rating, true);

					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && daNote.finishedGenerating)
				{
					possibleNotes.push(daNote);
				}
			});

			possibleNotes.sort((a, b) -> Std.int(a.noteData - b.noteData)); //sorting twice is necessary as far as i know
			haxe.ds.ArraySort.sort(possibleNotes, function(a, b):Int {
				var notetypecompare:Int = Std.int(a.noteData - b.noteData);

				if (notetypecompare == 0)
				{
					return Std.int(a.strumTime - b.strumTime);
				}
				return notetypecompare;
			});

			

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				var lasthitnote:Int = -1;
				var lasthitnotetime:Float = -1;

				for (note in possibleNotes) 
				{
					if (controlArray[note.noteData % 4])
					{
						if (lasthitnotetime > Conductor.songPosition - Conductor.safeZoneOffset
							&& lasthitnotetime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.2)) //reduce the past allowed barrier just so notes close together that aren't jacks dont cause missed inputs
						{
							if ((note.noteData % 4) == (lasthitnote % 4))
							{
								continue; //the jacks are too close together
							}
						}
						lasthitnote = note.noteData;
						lasthitnotetime = note.strumTime;
						goodNoteHit(note);
					}
				}
				
				if (daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
			else if (!theFunne)
			{
				if(!inCutscene)
					badNoteCheck(null);
			}
		}

		if ((up || right || down || left) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			switch (spr.ID)
			{
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
					{
						spr.playAnim('pressed');
					}
					if (upR)
					{
						spr.playAnim('static');
					}
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.playAnim('pressed');
					if (rightR)
					{
						spr.playAnim('static');
					}
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.playAnim('pressed');
					if (downR)
					{
						spr.playAnim('static');
					}
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.playAnim('pressed');
					if (leftR)
					{
						spr.playAnim('static');
					}
			}
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			var healthDetriment = 0.04;
			var scoreDetriment = 10;
			var missDetriment = 1;
			var gfSad:Bool = true;
			var loseCombo:Bool = true;
			var missSound:Bool = true;
			var missAnimation:Bool = true;
			var updateAccuracyOnMiss:Bool = true;

			scriptPack.callScripts("onMiss", [healthDetriment, scoreDetriment, missDetriment, gfSad, loseCombo, missSound, missAnimation, updateAccuracyOnMiss]);
			health -= healthDetriment;
			if (combo > 5 && gf.animOffsets.exists('sad') && gfSad)
			{
				gf.playAnim('sad');
			}
			if (loseCombo) combo = 0;
			misses += missDetriment;

			songScore -= scoreDetriment;

			if (missSound) FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if (missAnimation) {
				if (boyfriend.animation.getByName("singLEFTmiss") != null)
				{
					//'LEFT', 'DOWN', 'UP', 'RIGHT'
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % 4];
					if(!boyfriend.nativelyPlayable)
					{
						switch(notestuffs[Math.round(Math.abs(direction)) % 4])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
					boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou + "miss", true);
				}
				else
				{
					boyfriend.color = 0xFF000084;
					//'LEFT', 'DOWN', 'UP', 'RIGHT'
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(direction)) % 4];
					if(!boyfriend.nativelyPlayable)
					{
						switch(notestuffs[Math.round(Math.abs(direction)) % 4])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
					boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
				}
			}
			if (updateAccuracyOnMiss) updateAccuracy();
		}
	}

	function badNoteCheck(note:Note = null)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		if (note != null)
		{
			if(note.mustPress && note.finishedGenerating)
			{
				noteMiss(note.noteData);
			}
			return;
		}
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		if (downP)
			noteMiss(1);
		updateAccuracy();
	}

	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			fc = false;
		else
			fc = true;
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;

		scriptPack.callScripts('onUpdateAccuracy', [accuracy]);
	}

	function noteCheck(keyP:Bool, note:Note):Void // sorry lol
	{
		if (keyP)
		{
			goodNoteHit(note);
		}
		else if (!theFunne)
		{
			badNoteCheck(note);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			scriptPack.callScripts("onPlayerHit", [note]);
			scriptPack.callScripts('onNoteHit', [note]);
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note.noteData);
				if (Settings.data.donoteclick)
				{
					FlxG.sound.play(Paths.sound('note_click'));
				}
				combo += 1;

			}
			else
				totalNotesHit += 1;

			if (note.isSustainNote)
				health += 0.004;
			else
				health += 0.023;

			//'LEFT', 'DOWN', 'UP', 'RIGHT'
			var fuckingDumbassBullshitFuckYou:String;
			fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(note.noteData)) % 4];
			if(!boyfriend.nativelyPlayable)
			{
				switch(notestuffs[Math.round(Math.abs(note.noteData)) % 4])
				{
					case 'LEFT':
						fuckingDumbassBullshitFuckYou = 'RIGHT';
					case 'RIGHT':
						fuckingDumbassBullshitFuckYou = 'LEFT';
				}
			}
			boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}


	override function stepHit()
	{
		super.stepHit();
		scriptPack.setScripts("curStep", curStep);
		scriptPack.callScripts("stepHit", [curStep]);

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
		scriptPack.callScripts("postStepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();
		scriptPack.setScripts("curBeat", curBeat);
		scriptPack.callScripts("beatHit", [curBeat]);

		if (generatedMusic && autoZoomCam && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				focusOnDadGlobal = true;
				ZoomCam(true);
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				focusOnDadGlobal = false;
				ZoomCam(false);
			}
		}
		
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if (dad.animation.finished && dad.holdTimer <= 0 && curBeat % dad.dancingBeat == 0)
		{
			dad.dance();
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % camDanceBeat == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		var funny:Float = (healthBar.percent * 0.01) + 0.01;

		//health icon bounce but epic
		
		scriptPack.callScripts("onIconBounce", [doIconBounce]);
		if (doIconBounce) {
			iconP1.setGraphicSize(Std.int(iconP1.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
			iconP2.setGraphicSize(Std.int(iconP2.width + (50 * (2 - funny))),Std.int(iconP2.height - (25 * (2 - funny))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (curBeat % gf.dancingBeat == 0)
		{
			gf.dance();
		}
		// hi im taking icon code from gapple:e
		if (curBeat % iconDanceBeat == 0)
		{
			if (iconP1.animatedIcon)
			{
				if (iconP1.losing && !iconP1.singleIcon)
					iconP1.animation.play('losing', true);
				else
					iconP1.animation.play('normal', true);
			}
			if (iconP2.animatedIcon)
			{
				if (iconP2.losing && !iconP2.singleIcon)
					iconP2.animation.play('losing', true);
				else
					iconP2.animation.play('normal', true);
			}
		}


		// bf dancing crap is right here
		if(curBeat % boyfriend.dancingBeat == 0)
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.canDance && boyfriend.animation.curAnim != null)
				boyfriend.dance();
		scriptPack.callScripts("postBeatHit", [curBeat]);
	}

	public function preload(graphic:String) //preload assets
	{
		if (boyfriend != null)
		{
			boyfriend.stunned = true;
		}
		var newthing:FlxSprite = new FlxSprite(9000,-9000).loadGraphic(Paths.image(graphic));
		add(newthing);
		remove(newthing);
		if (boyfriend != null)
		{
			boyfriend.stunned = false;
		}
	}

	public function updateIcons()
	{
		var cancelled:Bool = false;
		scriptPack.callScripts("onUpdateIcons", [cancelled]);
		if (!cancelled) {
			iconP1.y = healthBar.y - (iconP1.height / 2);
			iconP2.y = healthBar.y - (iconP2.height / 2);
		}
	}

	public function hookToChar(curCharacter:String, character:Character) {
		#if debug trace('Attempting script pack for ' + curCharacter); #end
		var charPack:HScriptPack = new HScriptPack([Paths.file('data/characters/${curCharacter}.hx'), Paths.file('data/characters/${curCharacter}.hxc')], false);
		for (script in charPack.loadedScripts) {
			scriptPack.loadedScripts.push(script);
			script.run();
			script.set('parent', character);
		}
	}
}
