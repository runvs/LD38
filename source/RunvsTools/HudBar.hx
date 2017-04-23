package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author 
 */
class HudBar extends FlxSprite
{

	var _vertical : Bool;
	public var _background : FlxSprite;
	public var _text : FlxText;
	
	public function new(X:Float=0, Y:Float=0, w : Float, h : Float, vertical: Bool =true, col: FlxColor, text :String = "") 
	{
		super();
		x = X;
		y = Y;
		_vertical = vertical;
		if (w < 0) w *= -1;
		if (h < 0) h *= -1;
		
		this.origin.set(0, 0);
		this.scrollFactor.set();

		_background = new FlxSprite(x-2,y-2);
		_background.makeGraphic(Std.int(w) + 4, Std.int(h) + 4, FlxColor.fromRGB( 100,100,100, 100));
		_background.scrollFactor.set();
		if (vertical)
		{
			this.origin.set(0, height);
			makeGraphic(Std.int(w), Std.int(h), col);
		}
		else
		{
			SpriteFunctions.createHorizontalBar(this, Std.int(w), Std.int(h), Std.int(h / 6.0), col);
			this.origin.set(0, height);
		}
		
		_text = new FlxText(x, y, 0, text, 8);
		_text.scrollFactor.set();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var val : Float = health ;
		if (val < 0 ) val = 0;
		if (val > 1) val = 1;
			
		if (_vertical)
		{
			scale.set(1, val);
		}
		else
		{
			scale.set(val, 1);
		}
	}
	
	public override function draw() : Void 
	{
		//trace("draw");
		_background.draw();
		super.draw();
		_text.draw();
	}
	
}