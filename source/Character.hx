package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;

typedef CharacterData =
{
	var path:String; // Path to the character's asset.

	var globalOffset:Array<Float>; // Offsets added directly to the pre-existing offset. Kept in for compatability reasons.
	var gameOffset:Array<Float>; // Proper offset
	var camOffset:Array<Float>; // Camera offset

	var ?bopper:Bool; // Does the character bop left and right?

	var ?nativelyPlayable:Bool; // Can the character be played natively?

	var ?flipX:Bool; // Flip the character sprite?

	var ?causeCameraShake:Bool; // Does camera shake when character shakes?

	var ?vsliceHold:Bool; // Does the character have Vslice-like holding of the note?

	var ?antialiasing:Bool; // Alias the character?

	var ?scaleSize:Bool; // Should you change the scale of the character or do setGraphicSize?

	var scale:Null<Float>; // Changes scale/graphicsize by amount.

	var floater:Null<Bool>; // Does the character float? Will be deprecated for scripting in the future.

	var noteStyle:String; // What style of notes should the character use?

	var altIcon:String; // Easter egg icon when you press 9 on the keyboard

	var icon:String; // What icon should be used?

	var deathSkin:String; // What skin is used when character dies?

	var animations:Array<AnimationData>; // Array of all animations. Offsets are handled in the data/offsets
}

typedef AnimationData =
{
	var name:String; // Name of animation.
	var prefix:String; // Name of animation in XML

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Null<Bool>;

	/**
	 * The frame rate of this animation.
	 * @default 24
	 */
	var ?frameRate:Int; // Framerate of this specific animation.

	var ?frameIndices:Array<Int>; // If using indices, specify said indices. Plays full animation if null.

	var offset:Array<Int>;

	var flipX:Null<Bool>;

	var flipY:Null<Bool>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var icon:String = 'face';
	public var altIcon:String = 'bf-old';
	public var noteStyle:String = 'default';

	public var holdTimer:Float = 0;
	public var furiosityScale:Float = 1.02;
	public var canDance:Bool = true;
	public var useVSliceSustains = false;
	public var deadForm:String = 'bf-dead';

	public var canFloat:Bool = false;
	public var bopper:Bool = false;

	public var nativelyPlayable:Bool = false;

	public var globaloffset:Array<Float> = [0, 0];
	public var gameOffset:Array<Float> = [0, 0];
	public var camOffset:Array<Float> = [0, 0];
	public var charScale:Float = 1;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'dave':
				// DAVE SHITE ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/dave/dave_sheet');
				frames = tex;
				animation.addByPrefix('idle', 'idleDance', 24, false);
				animation.addByPrefix('singUP', 'Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Right', 24, false);
				animation.addByPrefix('singDOWN', 'Down', 24, false);
				animation.addByPrefix('singLEFT', 'Left', 24, false);
	
				addOffset('idle');
				addOffset("singUP", 18, 12);
				addOffset("singRIGHT", 5, -2);
				addOffset("singLEFT", 29, 2);
				addOffset("singDOWN", -5, 2);
				icon = 'dave';
				playAnim('idle');
			case 'dave-annoyed':
				// DAVE SHITE ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/dave/Dave_insanity_lol');
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Right', 24, false);
				animation.addByPrefix('singDOWN', 'Down', 24, false);
				animation.addByPrefix('singLEFT', 'Left', 24, false);
				animation.addByPrefix('scared', 'Scared', 24, true);
	
				addOffset('idle');
				addOffset("singUP", 3, 18);
				addOffset("singRIGHT", 16, -18);
				addOffset("singLEFT", 85, -12);
				addOffset("singDOWN", 0, -34);
				addOffset("scared", 0, -2);
				icon = 'dave';
				playAnim('idle');
			case 'dave-angey':
				// DAVE SHITE ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/dave/Dave_Furiosity');
				frames = tex;
				animation.addByPrefix('idle', 'IDLE', 24, false);
				animation.addByPrefix('singUP', 'UP', 24, false);
				animation.addByPrefix('singRIGHT', 'RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'LEFT', 24, false);
		
				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				setGraphicSize(Std.int(width * furiosityScale),Std.int(height * furiosityScale));
				updateHitbox();
				antialiasing = false;

				canFloat = true;
				icon = 'dave-3d';
				playAnim('idle');

			case 'bambi-3d':
				// BAMBI SHITE ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/bambi/bambi_angryboy');
				frames = tex;
				animation.addByPrefix('idle', 'DaveAngry idle dance', 24, false);
				animation.addByPrefix('singUP', 'DaveAngry Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'DaveAngry Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'DaveAngry Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'DaveAngry Sing Note LEFT', 24, false);
		
				addOffset('idle');
				addOffset("singUP", 20, -10);
				addOffset("singRIGHT", 80, -20);
				addOffset("singLEFT", 0, -10);
				addOffset("singDOWN", 0, 10);
				globaloffset[0] = 150;
				globaloffset[1] = 450; //this is the y
				setGraphicSize(Std.int(width / furiosityScale));
				updateHitbox();
				antialiasing = false;
				canFloat = true;
				icon = 'bambi-3d';
				playAnim('idle');
			case 'bambi-unfair':
				// BAMBI SHITE ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/bambi/unfair_bambi');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'singUP', 24, false);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'singLEFT', 24, false);
		
				addOffset('idle');
				addOffset("singUP", 140, 70);
				addOffset("singRIGHT", -180, -60);
				addOffset("singLEFT", 250, 0);
				addOffset("singDOWN", 150, 50);
				globaloffset[0] = 150 * 1.3;
				globaloffset[1] = 450 * 1.3; //this is the y
				setGraphicSize(Std.int((width * 1.3) / furiosityScale));
				updateHitbox();
				antialiasing = false;
				canFloat = true;
				icon = 'bambi-unfair';
				playAnim('idle');
			case 'tristan':
				var tex = Paths.getSparrowAtlas('characters/tristan/TRISTAN');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
	
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);
	
				addOffset('idle');
				addOffset("singUP", -59, 57);
				addOffset("singRIGHT", -58, -6);
				addOffset("singLEFT", -4, -2);
				addOffset("singDOWN", -40, -30);
				addOffset("singUPmiss", -59, 57);
				addOffset("singRIGHTmiss", -58, -6);
				addOffset("singLEFTmiss", -4, -2);
				addOffset("singDOWNmiss", -40, -30);
				addOffset("hey", -2, 1);
				addOffset('firstDeath', 17, 1);
				addOffset('deathLoop', 17, 5);
				addOffset('deathConfirm', 12, 36);
				addOffset('scared', 6, 3);
	
				playAnim('idle');
				icon = 'tristan';
				nativelyPlayable = true;
	
				flipX = true;
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/shared/bfChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				playAnim('idle');
				icon = 'bf';
				nativelyPlayable = true;

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/shared/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");
				if (!PlayState.curStage.startsWith('school'))
				{
					globaloffset[0] = -200;
					globaloffset[1] = -175;
				}
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;
				icon = 'bf-pixel';
				nativelyPlayable = true;

				flipX = true;
				
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/shared/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				nativelyPlayable = true;
				flipX = true;

			case 'bambi':
				var tex = Paths.getSparrowAtlas('characters/bambi/bambi');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS0', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS0', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
	
				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				playAnim('idle');

				nativelyPlayable = true;
				flipX = true;
				icon = 'bambi';

			case 'bambi-old':
				var tex = Paths.getSparrowAtlas('characters/bambi/bambi-old');
				frames = tex;
				animation.addByPrefix('idle', 'MARCELLO idle dance', 24, false);
				animation.addByPrefix('singUP', 'MARCELLO NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'MARCELLO NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'MARCELLO NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'MARCELLO NOTE DOWN0', 24, false);
				animation.addByPrefix('idle', 'MARCELLO idle dance', 24, false);
				animation.addByPrefix('singUPmiss', 'MARCELLO MISS UP0', 24, false);
				animation.addByPrefix('singLEFTmiss', 'MARCELLO MISS LEFT0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'MARCELLO MISS RIGHT0', 24, false);
				animation.addByPrefix('singDOWNmiss', 'MARCELLO MISS DOWN0', 24, false);

				animation.addByPrefix('firstDeath', "MARCELLO dead0", 24, false);
				animation.addByPrefix('deathLoop', "MARCELLO dead0", 24, true);
				animation.addByPrefix('deathConfirm', "MARCELLO dead0", 24, false);
	
				addOffset('idle');
				addOffset("singUP", -16, 3);
				addOffset("singRIGHT", 0, -4);
				addOffset("singLEFT", -10, -2);
				addOffset("singDOWN", -10, -17);
				addOffset("singUPmiss", -6, 4);
				addOffset("singRIGHTmiss", 0, -4);
				addOffset("singLEFTmiss", -10, -2);
				addOffset("singDOWNmiss", -10, -17);

				playAnim('idle');

				nativelyPlayable = true;
				icon = 'bambi-joke';
				flipX = true;
				
			case 'bambi-new':
				frames = Paths.getSparrowAtlas('characters/bambi/bambiRemake');
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);

				addOffset('idle');
				addOffset("singUP", 36, -5);
				addOffset("singRIGHT", -45, -11);
				addOffset("singLEFT", -10, -9);
				addOffset("singDOWN", -12, -48);
				icon = 'bambi';
				playAnim('idle');

			case 'dave-splitathon':
				frames = Paths.getSparrowAtlas('characters/dave/Splitathon_Dave');
				animation.addByPrefix('idle', 'SplitIdle', 24, false);
				animation.addByPrefix('singDOWN', 'SplitDown', 24, false);
				animation.addByPrefix('singUP', 'SplitUp', 24, false);
				animation.addByPrefix('singLEFT', 'SplitLeft', 24, false);
				animation.addByPrefix('singRIGHT', 'SplitRight', 24, false);
				animation.addByPrefix('scared', 'Nervous', 24, true);
				animation.addByPrefix('what', 'Mad', 24, true);
				animation.addByPrefix('happy', 'Happy', 24, true);

				addOffset('idle');
				addOffset("singUP", -12, 20);
				addOffset("singRIGHT", -40, -13);
				addOffset("singLEFT", 32, 8);
				addOffset("singDOWN", 3, -21);
				addOffset("scared", -15, 11);
				addOffset("what", -3, 1);
				addOffset("happy", -3, 1);
				icon = 'dave';
				playAnim('idle');
				
			case 'bambi-splitathon':
				frames = Paths.getSparrowAtlas('characters/bambi/Splitathon_Bambi');
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singDOWN', 'Down', 24, false);
				animation.addByPrefix('singUP', 'Up', 24, false);
				animation.addByPrefix('singLEFT', 'Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Right', 24, false);
							
				addOffset('idle');
				addOffset("singUP", -24, 15);
				addOffset("singRIGHT", -34, -6);
				addOffset("singLEFT", -3, 6);
				addOffset("singDOWN", -20, -10);
				icon = 'bambi';
				playAnim('idle');
				
			case 'tristan-golden':
				var tex = Paths.getSparrowAtlas('characters/tristan/tristan_golden');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
	
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);
	
				addOffset('idle');
				addOffset("singUP", -59, 57);
				addOffset("singRIGHT", -58, -6);
				addOffset("singLEFT", -4, -2);
				addOffset("singDOWN", -40, -30);
				addOffset("singUPmiss", -59, 57);
				addOffset("singRIGHTmiss", -58, -6);
				addOffset("singLEFTmiss", -4, -2);
				addOffset("singDOWNmiss", -40, -30);
				addOffset("hey", -2, 1);
				addOffset('firstDeath', 17, 1);
				addOffset('deathLoop', 17, 5);
				addOffset('deathConfirm', 12, 36);
				addOffset('scared', 6, 3);
				addOffset('hit', 13, 25);
	
				playAnim('idle');
				icon = 'tristan-golden';
				nativelyPlayable = true;
	
				flipX = true;
			case 'bambi-angey':
				frames = Paths.getSparrowAtlas('characters/bambi/bambimaddddd');
				animation.addByPrefix('idle', 'idle', 24, true);
				animation.addByPrefix('singLEFT', 'left', 24, false);
				animation.addByPrefix('singDOWN', 'down', 24, false);
				animation.addByPrefix('singUP', 'up', 24, false);
				animation.addByPrefix('singRIGHT', 'right', 24, false);

				addOffset('idle');
				addOffset('singLEFT');
				addOffset('singDOWN');
				addOffset('singUP', 0, 20);
				addOffset('singRIGHT');
				icon = 'bambi-3d';
				playAnim('idle');
			case 'bambi-bevel':
				var tex = Paths.getSparrowAtlas('characters/bambi/bevel_bambi');
				frames = tex;
				animation.addByPrefix('idle', 'MARCELLO idle dance', 24, false);
				animation.addByPrefix('singUP', 'MARCELLO NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'MARCELLO NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'MARCELLO NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'MARCELLO NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'MARCELLO NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'MARCELLO NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'MARCELLO NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'MARCELLO NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'MARCELLO HEY', 24, false);

				animation.addByPrefix('firstDeath', "MARCELLO dies", 24, false);
				animation.addByPrefix('deathLoop', "MARCELLO Dead Loop", 24, true);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'MARCELLO idle shaking', 24);
				animation.addByPrefix('hit', 'MARCELLO hit', 24, false);

				addOffset('idle');
				addOffset("singUP", -59, 37);
				addOffset("singRIGHT", -38, -3);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -59, 37);
				addOffset("singRIGHTmiss", -38, -3);
				addOffset("singLEFTmiss", 12, -6);
				addOffset("singDOWNmiss", -10, -50);
				addOffset("hey", 3, 21);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('scared', -24, -10);
				icon = 'bambi-joke';
				playAnim('idle');

				nativelyPlayable = true;

				flipX = true;
			case 'what-lmao':
				var tex = Paths.getSparrowAtlas('characters/bambi/what');
				frames = tex;
				animation.addByPrefix('idle', 'MARCELLO idle dance', 24, false);
				animation.addByPrefix('singUP', 'MARCELLO NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'MARCELLO NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'MARCELLO NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'MARCELLO NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'MARCELLO NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'MARCELLO NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'MARCELLO NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'MARCELLO NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'MARCELLO HEY', 24, false);

				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'MARCELLO idle shaking', 24);
				animation.addByPrefix('hit', 'MARCELLO hit', 24, false);

				addOffset('idle');
				addOffset("singUP", -59, 37);
				addOffset("singRIGHT", -38, -3);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -59, 37);
				addOffset("singRIGHTmiss", -38, -3);
				addOffset("singLEFTmiss", 12, -6);
				addOffset("singDOWNmiss", -10, -50);
				addOffset("hey", 3, 21);
				addOffset('scared', -24, -10);
				icon = 'bambi-joke';
				playAnim('idle');

				nativelyPlayable = true;

				flipX = true;
			default:
				parseDataFile();
		}
		dance();

		if(isPlayer)
		{
			flipX = !flipX;
		}
	}

	public function parseDataFile()
	{
		var path:String = Paths.json('characters/${curCharacter}');
		if (!Assets.exists(path))
			curCharacter = 'bf';
		trace('PARSING CHARACTER: ' + curCharacter);
		var rawJson = Assets.getText(Paths.json('characters/${curCharacter}'));
		var jsonData:CharacterData = cast Json.parse(rawJson);

		var data:CharacterData = cast jsonData;

		var tex:FlxAtlasFrames;
		tex = Paths.getSparrowAtlas(data.path);
		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipx = anim.flipX == null ? false : anim.flipX;
				var flipy = anim.flipY == null ? false : anim.flipY;

				if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipx, flipy);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipx, flipy);
				}
				addOffset(anim.name, anim.offset[0], anim.offset[1]);
			}

		// do dances use DanceLeft / DanceRight?
		bopper = data.bopper == null ? false : data.bopper;

		antialiasing = data.antialiasing == null ? true : data.antialiasing;

		nativelyPlayable = data.nativelyPlayable == null ? false : data.nativelyPlayable;

		flipX = data.flipX == null ? false : data.flipX;

		if (data.causeCameraShake)
			PlayState.shakingChars.push(curCharacter);

		useVSliceSustains = data.vsliceHold == null ? false : data.vsliceHold;

		canFloat = data.floater == null ? false : data.floater; // add easy

		charScale = data.scale == null ? 1 : data.scale; // add normal

		noteStyle = data.noteStyle == null ? 'default' : data.noteStyle; // add hard

		altIcon = data.altIcon == null ? 'bf-old' : data.altIcon; // add extreme

		deadForm = data.deathSkin == null ? 'bf' : data.deathSkin; // add extremely impossible

		icon = data.icon;

		if (data.scaleSize)
			scale.set(charScale, charScale); // scale can be a float
		else
			setGraphicSize(Std.int(width * charScale), Std.int(height * charScale)); // setGraphicSize cannot

		updateHitbox();
		globaloffset = data.globalOffset; // mostly dependency for tha cores
		gameOffset = data.gameOffset;
		camOffset = data.camOffset;

		playAnim(data.bopper ? 'danceRight' : 'idle');
	}

	override function update(elapsed:Float)
	{
		if (animation == null)
		{
			super.update(elapsed);
			return;
		}
		else if (animation.curAnim == null)
		{
			super.update(elapsed);
			return;
		}
		if (!nativelyPlayable && !isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (bopper && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR DANCING SHIT
	 */
	public function dance()
	{
		if (canDance)
		{
			if (bopper)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight', true);
				else
					playAnim('danceLeft', true);
			}
			else
				playAnim('idle', true);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) == null)
		{
			return; //why wasn't this a thing in the first place
		}
		if(AnimName.toLowerCase() == 'idle' && !canDance)
		{
			return;
		}
		animation.play(AnimName, Force, Reversed, Frame);
	
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			if (isPlayer)
			{
				if(!nativelyPlayable)
				{
					offset.set((daOffset[0] * -1) + globaloffset[0], daOffset[1] + globaloffset[1]);
				}
				else
				{
					offset.set(daOffset[0] + globaloffset[0], daOffset[1] + globaloffset[1]);
				}
			}
			else
			{
				if(nativelyPlayable)
				{
					offset.set((daOffset[0] * -1), daOffset[1]);
				}
				else
				{
					offset.set(daOffset[0], daOffset[1]);
				}
			}
		}
		else
			offset.set(0, 0);
	
		if (bopper)
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}
	
			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
