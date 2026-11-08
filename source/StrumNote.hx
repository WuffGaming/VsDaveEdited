package;

import flixel.FlxSprite;

class StrumNote extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null) {
			centerOffsets();
			centerOrigin();
		}
	}
}
