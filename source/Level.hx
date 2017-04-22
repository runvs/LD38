package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import hxnoise.Perlin;

/**
 * ...
 * @author 
 */
class Level extends FlxObject
{
	
	public var tiles : FlxTypedGroup<Tile>;
	
	public var collisionTiles : FlxSpriteGroup;
	
	public var trees : FlxTypedGroup<Tree>;
	public var rocks : FlxTypedGroup<Rock>;
	
	public function new() 
	{
		super();
		
		tiles = new FlxTypedGroup<Tile>();
		collisionTiles = new FlxSpriteGroup();
		trees = new FlxTypedGroup<Tree>();
		rocks = new FlxTypedGroup<Rock>();
		CreateLevel();
	}
	
	
	
	function CreateLevel() 
	{
		FlxG.worldBounds.set(0, 0, GP.TileSize * GP.WorldSizeInTiles, GP.TileSize * GP.WorldSizeInTiles);
		
		var perlin : Perlin = new Perlin();
		tiles.clear();
		
		var arr : Array<Float> = new Array < Float>();
		for (i in 0 ... GP.WorldSizeInTiles)
		for (j in 0 ... GP.WorldSizeInTiles)
		{
			var idx = i + GP.WorldSizeInTiles * j;
			var fi : Float = i / GP.WorldLengthScale;
			var fj : Float = j / GP.WorldLengthScale;
			arr.push(perlin.perlin(fi / GP.WorldSizeInTiles, fj / GP.WorldSizeInTiles, 1));
		}
		
		var min : Float = 1000;
		var max : Float = -1;
		
		for (h in arr)
		{
			min = (h < min) ? h : min;
			max = (h > max) ? h : max;
		}
		trace(min + " " + max);
		
		for ( i in 0...arr.length)
		{
			arr[i] = (arr[i] - min) / (max - min);
			
		}
		
		var stonecount : Int = 0;
		var watercount : Int = 0;
		var grasscount : Int = 0;
		
		for (i in 0 ... GP.WorldSizeInTiles)
		for (j in 0 ... GP.WorldSizeInTiles)
		{
			
			var idx = i + GP.WorldSizeInTiles * j;
			var h = arr[idx];
			var type : TileType = TileType.GRASS;
			if (h < GP.WorldWaterLevel)
			{
				type = TileType.WATER;
				watercount++;
			}
			else if (h > GP.WorldStoneLevel)
			{
				type = TileType.STONE;
				stonecount++;
			}
			else
			{
				grasscount++;
			}
			
			var t : Tile = new Tile(type, i, j);
			tiles.add(t);
		}
		
		CreateObjects();
		
		trace("Water: " + watercount);
		trace("Stone: " + stonecount);
		trace("Grass: " + grasscount);
		
		CreateAutoTiles();
		
		CreateCollisionTiles();
	}
	
	function CreateAutoTiles() 
	{
		for (i in 0... GP.WorldSizeInTiles)
		for (j in 0... GP.WorldSizeInTiles)
		{
			var t = getTileAtIntPosition(i, j);
			if (t.type == TileType.WATER)
			{
				var tlt : Tile = getTileAtIntPositionUnsafe(i-1, j - 1);
				var tct : Tile = getTileAtIntPositionUnsafe(i,   j - 1);
				var trt : Tile = getTileAtIntPositionUnsafe(i+1, j - 1);
				
				var tlc : Tile = getTileAtIntPositionUnsafe(i - 1, j + 0);
				var tcc : Tile = getTileAtIntPositionUnsafe(i, j );
				var trc : Tile = getTileAtIntPositionUnsafe(i+1, j + 0);
				
				var tlb : Tile = getTileAtIntPositionUnsafe(i-1, j + 1);
				var tcb : Tile = getTileAtIntPositionUnsafe(i,   j + 1);
				var trb : Tile = getTileAtIntPositionUnsafe(i+1, j + 1);
				
				if (tlt != null && tlt.type != TileType.WATER)
				{
					t.addAutoTileID(1);
				}
				if (tct != null && tct.type != TileType.WATER)
				{
					t.addAutoTileID(2);
				}
				if (trt != null && trt.type != TileType.WATER)
				{
					t.addAutoTileID(4);
				}
				if (tlc != null && tlc.type != TileType.WATER)
				{
					t.addAutoTileID(8);
				}
				if (tcc != null && tcc.type != TileType.WATER)
				{
					t.addAutoTileID(16);
				}
				if (trc != null && trc.type != TileType.WATER)
				{
					t.addAutoTileID(32);
				}
				if (tlb != null && tlb.type != TileType.WATER)
				{
					t.addAutoTileID(64);
				}
				if (tcb != null && tcb.type != TileType.WATER)
				{
					t.addAutoTileID(128);
				}
				if (trb != null && trb.type != TileType.WATER)
				{
					t.addAutoTileID(256);
				}
				
				t.SelectAutoTile();
			}
		}
	}
	
	function SpawnPostionOnMap () : FlxPoint
	{
		return new FlxPoint(FlxG.random.float(0, GP.WorldSizeInTiles * GP.TileSize), FlxG.random.float(0, GP.WorldSizeInTiles * GP.TileSize));
	}
	
	function CreateObjects() 
	{
		
		CreateTrees();
		
		CreateRocks();
		
		
		
	}
	
	function CreateRocks() 
	{
		while(true)
		{	
			if (rocks.length >= GP.WorldRockCount)
			{
				break;
			}
			
			var ix : Int = FlxG.random.int(0, GP.WorldSizeInTiles - 1);
			var iy : Int = FlxG.random.int(0, GP.WorldSizeInTiles - 1);
			
			var tile : Tile = getTileAtIntPosition(ix, iy);
			if (tile == null) continue;
			if (tile.type == TileType.STONE)
			{
				var r : Rock = new Rock(ix * GP.TileSize, iy * GP.TileSize);
				rocks.add(r);
				collisionTiles.add(r);
			}
		}
		// sort trees for correct drawing order
		trees.members.sort(function(a, b) : Int {
			if (a.y < b.y) return -1;
			else if (a.y > b.y ) return 1;
			else return 0;
		});
	}
	
	public function getTileAtPosition(X : Float, Y : Float) : Tile
	{
		if (X < 0 || X > GP.TileSize * (GP.WorldSizeInTiles + 1)) 
			throw ("Error: Cannot get Tile at position : " + Std.string(X) + " " + Std.string(Y));
		if (Y < 0 || Y > GP.TileSize * (GP.WorldSizeInTiles + 1)) 
			throw ("Error: Cannot get Tile at position : " + Std.string(X) + " " + Std.string(Y));
			
		var ix : Int = Std.int(X / GP.TileSize);
		var iy : Int = Std.int(Y / GP.TileSize);
		
		var idx = iy + GP.WorldSizeInTiles * ix;
		
		return tiles.members[idx];
	}
	
	public function getTileAtIntPosition(X : Int, Y : Int) : Tile
	{
		if (X < 0 || X >= (GP.WorldSizeInTiles)) 
			throw ("Error: Cannot get Tile at position : " + Std.string(X) + " " + Std.string(Y));
		if (Y < 0 || Y >= GP.TileSize * (GP.WorldSizeInTiles)) 
			throw ("Error: Cannot get Tile at position : " + Std.string(X) + " " + Std.string(Y));
			
		
		var idx = Y + GP.WorldSizeInTiles * X;
		
		return tiles.members[idx];
	}
	
	public function getTileAtIntPositionUnsafe(X : Int, Y : Int) : Tile
	{
		if (X < 0 || X >= (GP.WorldSizeInTiles)) 
			return null;
		if (Y < 0 || Y >= GP.TileSize * (GP.WorldSizeInTiles)) 
			return null;
			
		
		var idx = Y + GP.WorldSizeInTiles * X;
		
		return tiles.members[idx];
	}
	
	function CreateCollisionTiles() 
	{
		for (t in tiles)
		{
			if (t.blocking)
			{
				var s : FlxSprite = new FlxSprite(t.x, t.y);
				s.makeGraphic(GP.TileSize, GP.TileSize);
				s.immovable = true;
				collisionTiles.add(s);
			}
		}
	}
	
	function CreateTrees():Void 
	{
		while(true)
		{	
			if (trees.length >= GP.WorldWoodCount)
			{
				break;
			}
			
			var ix : Int = FlxG.random.int(0, GP.WorldSizeInTiles - 1);
			var iy : Int = FlxG.random.int(0, GP.WorldSizeInTiles - 1);
			
			var tile : Tile = getTileAtIntPosition(ix, iy);
			if (tile == null) continue;
			if (tile.type == TileType.GRASS)
			{
				var t : Tree = new Tree(ix * GP.TileSize, iy * GP.TileSize);
				trees.add(t);
				collisionTiles.add(t.collisionSprite);
			}
		}
		// sort trees for correct drawing order
		trees.members.sort(function(a, b) : Int {
			if (a.y < b.y) return -1;
			else if (a.y > b.y ) return 1;
			else return 0;
		});
	}
	
	public override function draw ()
	{
		super.draw();
		tiles.draw();
		

	}
	
	public function drawAbovePlayer()
	{
		trees.draw();
		rocks.draw();
	}
	
	
	public override function update (elapsed : Float)
	{
		super.update(elapsed);
		tiles.update(elapsed);
		collisionTiles.update(elapsed);
		trees.update(elapsed);
		rocks.update(elapsed);
	}
	
	public inline function updateVisibility(p:Player) 
	{
		for (t in tiles)
		{
			if (t.visited) continue;
			var dx : Float = t.x - p.x;
			if (dx > GP.PlayerViewRange) continue;
			
			var dy : Float = t.y - p.y;
			if (dy > GP.PlayerViewRange) continue;
			
			var l = dx * dx + dy * dy;
			if ( l < GP.PlayerViewRange * GP.PlayerViewRange)
			{
				t.visitMe(); 
			}
		}
		
		for (t in trees)
		{
			if (t.visited) continue;
			var dx : Float = t.x - p.x;
			if (dx > GP.PlayerViewRange * 1.2) continue;
			
			var dy : Float = t.y - p.y;
			if (dy > GP.PlayerViewRange * 1.2) continue;
			
			var l = dx * dx + dy * dy;
			if ( l < GP.PlayerViewRange * GP.PlayerViewRange * 1.2 * 1.2)
			{
				t.visitMe(); 
			}
		}
		
		for (r in rocks)
		{
			if (r.visited) continue;
			var dx : Float = r.x - p.x;
			if (dx > GP.PlayerViewRange * 1.2) continue;
			
			var dy : Float = r.y - p.y;
			if (dy > GP.PlayerViewRange * 1.2) continue;
			
			var l = dx * dx + dy * dy;
			if ( l < GP.PlayerViewRange * GP.PlayerViewRange * 1.2 * 1.2)
			{
				r.visitMe(); 
			}
		}
	}
}