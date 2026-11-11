package stage;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

class Stage extends FlxGroup {
    public var propNames:Map<String, Dynamic> = new Map<String, Dynamic>();

    public var cameraZoom:Float = 1.05;

    public function new(name:String) {
        super();

        generateStage(name);
        if (PlayState.instance != null) {
            generatePlayStateOffsets(name);
        }
    }

    public function generateStage(name) {
        var data:StageData = cast Paths.loadJSON('stages/${name}');

        cameraZoom = data.cameraZoom;
        for (prop in data.props)
        {
            var propSprite:FlxSprite = new FlxSprite(prop.position[0], prop.position[1]);
            if (prop.animations != null)
            {
                var tex:FlxAtlasFrames = Paths.getSparrowAtlas(prop.path);
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
                propSprite.loadGraphic(Paths.image(prop.path));
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
            addProp(propSprite, prop.name);
        }
    }

    public function generatePlayStateOffsets(name) {
        var data:StageData = cast Paths.loadJSON('stages/${name}');
        if (data.bfOffset != null)
        {
            PlayState.boyfriend.x += data.bfOffset[0];
            PlayState.boyfriend.y += data.bfOffset[1];
        }
        if (data.gfOffset != null)
        {
            PlayState.gf.x += data.gfOffset[0];
            PlayState.gf.y += data.gfOffset[1];
        }
        if (data.dadOffset != null)
        {
            PlayState.dad.x += data.dadOffset[0];
            PlayState.dad.y += data.dadOffset[1];
        }
        // scroll overrides
        if (data.bfScroll != null)
        {
            PlayState.boyfriend.scrollFactor.x = data.bfScroll[0];
            PlayState.boyfriend.scrollFactor.x = data.bfScroll[1];
        }
        if (data.gfScroll != null)
        {
            PlayState.gf.scrollFactor.x = data.gfScroll[0];
            PlayState.gf.scrollFactor.x = data.gfScroll[1];
        }
        if (data.dadScroll != null)
        {
            PlayState.dad.scrollFactor.x = data.dadScroll[0];
            PlayState.dad.scrollFactor.x = data.dadScroll[1];
        }
    }

    public function addProp(prop:Dynamic, ?name:String = null):Void
	{
		if (name != null)
		{
			propNames.set(name, prop);
		}
		this.add(prop);
	}

    public function getProp(prop):Dynamic
	{
		return this.propNames.get(prop);
	}

}

typedef StageData =
{
	var cameraZoom:Float; // Path to the character's asset.

	// Offsets are added into the current character positions.
	var bfOffset:Array<Float>;
	var gfOffset:Array<Float>;
	var dadOffset:Array<Float>;
	var bfScroll:Array<Float>;
	var gfScroll:Array<Float>;
	var dadScroll:Array<Float>;

	var props:Array<PropData>; // Array of all props.
}

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