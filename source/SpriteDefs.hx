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

	var ?indices:Array<Int>; // If using indices, specify said indices. Plays full animation if null.

	var offset:Array<Int>; // Offset of Animation

	var flippedOffset:Array<Int>; // Optional parameter for Characters.hx

	var flipX:Null<Bool>;

	var flipY:Null<Bool>;
}

// moved here for storyMenus
typedef PropData =
{
	var position:Array<Float>; // Where is prop located?

	var scale:Array<Float>; // How big or small is the prop?

	var graphicSize:Null<Float>; // Uses graphicSize instead.

	var name:String; // Name of prop

	var path:String; // Where prop is located

	var animations:Array<SpriteDefs.AnimationData>; // Every animation the prop has.

	var visible:Null<Bool>; // Is prop visible?

	var flipX:Null<Bool>; // Is prop flipped by X?

	var flipY:Null<Bool>; // Is prop flipped by Y?

	var alpha:Null<Float>; // Specify the alpha of prop.

	var antialiasing:Null<Bool>; // Antialised?

	var scroll:Array<Float>; // What is the scroll factor? x,y
}