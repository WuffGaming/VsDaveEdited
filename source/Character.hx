package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;

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
	public var bopDance:Bool = false;

	public var nativelyPlayable:Bool = false;

	public var globalOffset:Array<Float> = [0, 0];
	public var gameOffset:Array<Float> = [0, 0];
	public var camOffset:Array<Float> = [0, 0];
	public var charScale:Float = 1;

	public var danced:Bool = false; // has danced?

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;


		parseDataFile();
		dance();

		if(isPlayer)
		{
			flipX = !flipX;
		}
	}

	public function parseDataFile()
	{
		if (!Assets.exists(Paths.json('characters/${curCharacter}')))
			curCharacter = 'bf';

		trace('PARSING CHARACTER: ' + curCharacter);
		
		var data:CharacterData = cast Paths.loadJSON('characters/$curCharacter');

		bopDance = data.bopper == null ? false : data.bopper;

		antialiasing = data.antialiasing == null ? true : data.antialiasing;

		nativelyPlayable = data.nativelyPlayable == null ? false : data.nativelyPlayable;

		flipX = data.flipX == null ? false : data.flipX;

		useVSliceSustains = data.vsliceHold == null ? false : data.vsliceHold;

		charScale = data.scale == null ? 1 : data.scale; // add normal

		noteStyle = data.noteStyle == null ? 'default' : data.noteStyle; // add hard

		altIcon = data.altIcon == null ? 'bf-old' : data.altIcon; // add extreme

		deadForm = data.deathSkin == null ? 'bf' : data.deathSkin; // add extremely impossible

		icon = data.icon;

		// im moving this down here Lol!
		var tex:FlxAtlasFrames;
		tex = Paths.getSparrowAtlas(data.path);
		frames = tex;
		if (frames != null)
			for (anim in data.animations)
			{
				var offset = anim.offset == null ? [0,0] : anim.offset;
				if ((isPlayer && !nativelyPlayable || !isPlayer && nativelyPlayable) && anim.flippedOffset != null)
					offset = anim.flippedOffset;
				var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
				var looped = anim.looped == null ? false : anim.looped;
				var flipx = anim.flipX == null ? false : anim.flipX;
				var flipy = anim.flipY == null ? false : anim.flipY;

				if (anim.indices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.indices, "", frameRate, looped, flipx, flipy);
				}
				else
				{
					animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipx, flipy);
				}
				addOffset(anim.name, anim.offset[0], anim.offset[1]);
			}

		if (data.scaleSize)
			scale.set(charScale, charScale); // scale can be a float
		else
			setGraphicSize(Std.int(width * charScale), Std.int(height * charScale)); // setGraphicSize cannot

		updateHitbox();

		// you deadass gotta check everything bro
		globalOffset = data.globalOffset == null ? [0,0] : data.globalOffset;
		gameOffset = data.gameOffset == null ? globalOffset : data.gameOffset; // we already checked for if globalOffset is null so we can just use that Lol
		camOffset = data.camOffset == null ? [0,0] : data.camOffset;

		playAnim(bopDance ? 'danceRight' : 'idle');
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

		if (bopDance && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		super.update(elapsed);
	}

	/**
	 * FOR DANCING SHIT
	 */
	public function dance()
	{
		if (canDance)
		{
			if (bopDance)
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
		if (animation.getByName(AnimName) == null || AnimName.toLowerCase().startsWith('idle') && !canDance)
			return;
		animation.play(AnimName, Force, Reversed, Frame);
	
		// offset crud
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			if (isPlayer)
			{
				if(!nativelyPlayable)
				{
					offset.set((daOffset[0] * -1) + globalOffset[0], daOffset[1] + globalOffset[1]);
				}
				else
				{
					offset.set(daOffset[0] + globalOffset[0], daOffset[1] + globalOffset[1]);
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

		// loop crud
		if (animation.exists(AnimName + '-loop') && animation.finished)
		{
			animation.play(AnimName + '-loop', Force, Reversed, Frame);
		}
	
		if (bopDance)
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

typedef CharacterData =
{
	var path:String; // Path to the character's asset.

	var globalOffset:Array<Float>; // Offsets added directly to the pre-existing offset. Kept in for compatability reasons.
	var gameOffset:Array<Float>; // Proper offset
	var camOffset:Array<Float>; // Camera offset

	var ?bopper:Bool; // Does the character bop left and right?

	var ?nativelyPlayable:Bool; // Can the character be played natively?

	var ?flipX:Bool; // Flip the character sprite?

	var ?vsliceHold:Bool; // Does the character have Vslice-like holding of the note?

	var ?antialiasing:Bool; // Alias the character?

	var ?scaleSize:Bool; // Should you change the scale of the character or do setGraphicSize?

	var scale:Null<Float>; // Changes scale/graphicsize by amount.

	var noteStyle:String; // What style of notes should the character use?

	var altIcon:String; // Easter egg icon when you press 9 on the keyboard

	var icon:String; // What icon should be used?

	var deathSkin:String; // What skin is used when character dies?

	var animations:Array<SpriteDefs.AnimationData>; // Array of all animations. Offsets are handled in the data/offsets
}