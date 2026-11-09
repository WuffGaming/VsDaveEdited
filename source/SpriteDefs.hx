package;

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

	var offset:Array<Int>; // Offset of Animation

	var flippedOffset:Array<Int>; // Optional parameter for Characters.hx

	var flipX:Null<Bool>;

	var flipY:Null<Bool>;
}