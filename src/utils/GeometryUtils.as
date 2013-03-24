package utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class GeometryUtils
	{
		public function GeometryUtils()
		{
		}
		
		public static function Distance( a:Number, b:Number, c:Number, d:Number ):Number
		{
			var p1:Point = new Point( a, b );
			var p2:Point = new Point( c, d );
			
			var d:Number = Point.distance(p1, p2);
			return d;
		}
		
		public static function Interpolate(a:Number, b:Number, c:Number, d:Number, f:Number):Vector.<Number>
		{
			// trace ( "GeometryUtils.Interpolate: ", a, b, c, d, f );
			
			var buffer:Vector.<Number> = new Vector.<Number>(2, true)
			var p1:Point = new Point( a, b );
			var p2:Point = new Point( c, d );
			
			var result:Point = Point.interpolate(p1, p2, f);
			buffer[0] = result.x; 
			buffer[1] = result.y; 
			return buffer;
		}
		
		public static function GetCharacterBounds(points:Vector.<Number>):Rectangle 
		{
			var tl:Point = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
			var br:Point = new Point(-Number.MAX_VALUE, -Number.MAX_VALUE);
			var num:uint = points.length;
			for(var i:uint = 0; i < num; i += 2) 
			{
				var px:Number = points[i];
				var py:Number = points[i + 1];
				if(tl.x > px) tl.x = px;
				if(tl.y > py) tl.y = py;
				if(br.x < px) br.x = px;
				if(br.y < py) br.y = py;
			}
			return new Rectangle(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
		}
		
		public static function AddPoint( polyline:Vector.<Number>, a:Number, b:Number ):Boolean
		{
			var exist:Boolean = false;
			var indexOfPx:int = polyline.indexOf(a);
			if ( indexOfPx > -1 )
			{
				var py:Number = polyline[ indexOfPx + 1 ];
				
				if ( py !== b)
				{
					// trace ( a, b, " n'existe pas. On l'ajoute au tableau" );
					
					polyline.push(a, b);
				}
				else 
				{
					// trace ( a, b, " existe déjà. On ne l'ajoute pas au tableau" );
					
					exist = true;
				}
			}
			else
			{
				// trace ( a, b, " n'existe pas. On l'ajoute au tableau" );
				polyline.push(a, b);
			}
			return exist;
		}
		
		
	}
}