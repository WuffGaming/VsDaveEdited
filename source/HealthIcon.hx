package;

import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef IconData =
{
	var size:Null<Int>;

	var scale:Array<Float>;

	var solo:Null<Bool>;

	var antialiasing:Null<Bool>;

	var flip:Null<Bool>;

	var animations:Array<IconAnimationData>;
}

typedef IconAnimationData = // taken from character.hx
{
	var name:String; // Name of animation. Should be something like "Normal" or "Losing"
	var prefix:String; // Name of animation in XML

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	/**
	 * The frame rate of this animation.
	 * @default 24
	 */
	var ?frameRate:Int; // Framerate of this specific animation.

	var ?frameIndices:Array<Int>; // If using indices, specify said indices. Plays full animation if null.
}

class HealthIcon extends FlxSprite
{
	/**
	 * Used to represent character icons & the color on the healthbar.
	 */
	public var sprTracker:FlxSprite;

	public var isPlayer:Bool = false;

	public var curIcon:String = 'face';

	public var animatedIcon:Bool = false;

	public var losing:Bool = false;

	public var singleIcon:Bool = false;

	public var iconScale:Array<Float> = [1, 1];

	public function new(char:String = 'face', isPlayer:Bool = false)
	{
		super();

		this.isPlayer = isPlayer;

		changeIcon(char);

		scrollFactor.set();
	}

	function addIcon(char:String, startFrame:Int, singleIcon:Bool = false, flip:Bool = false)
	{
		animation.add(char, !singleIcon ? [startFrame, startFrame + 1] : [startFrame], 0, false, flip ? !isPlayer : isPlayer);
	}

	public function changeIcon(char:String = 'face')
	{
		var iconPath = 'icons/';
		curIcon = char;
		if (Paths.image(iconPath + char) != null)
			curIcon = char;

		if (Assets.exists(Paths.jsonImg('icons/${char}')))
		{
			var jsonData:IconData = Paths.loadJSONImg('icons/${curIcon}');
			var data:IconData = cast jsonData;
			var size:Int = data.size == null ? 150 : data.size;
			var solo:Bool = data.solo == null ? false : data.solo;
			var flip:Bool = data.flip == null ? false : data.flip;
			iconScale = data.scale == null ? [1, 1] : [data.scale[0], data.scale[1]];

			if (solo == true)
				singleIcon = true;

			antialiasing = data.antialiasing == null ? true : data.antialiasing;

			if (data.animations != null)
			{
				trace('${curIcon} is an animated icon! Wow!');
				animatedIcon = true;
				frames = Paths.getSparrowAtlas(iconPath + curIcon);
				for (anim in data.animations)
				{
					var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
					var looped = anim.looped == null ? false : anim.looped;

					if (anim.frameIndices != null)
					{
						animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, isPlayer);
					}
					else
					{
						animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, isPlayer);
					}
				}
				animation.play('normal', true);
			}
			else
			{
				loadGraphic(Paths.image(iconPath + curIcon), true, size, size);
				addIcon(curIcon, 0, solo, flip);
			}
		}
		else
		{
			loadGraphic(Paths.image(iconPath + curIcon), true, 150, 150);

			addIcon(curIcon, 0);
		}

		setGraphicSize(width * iconScale[0], height * iconScale[1]);
		updateHitbox();

		animation.play(curIcon);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var xOffsetPenis:Float = 0;
		var yOffsetPenis:Float = 0;

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);

		offset.set(Std.int(FlxMath.bound(width - (150 * scale.x),0)) + xOffsetPenis,Std.int(FlxMath.bound(height - (150 * scale.y),0)) + yOffsetPenis);
	}
}
