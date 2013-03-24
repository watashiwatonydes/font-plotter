package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Shape;
	import flash.geom.Point;

	public class VerticeBody extends Shape
	{
		
		private var world:b2World				= null;
		private var worldScale:int      		= 30;
		public var pixelBasedPosition:Point    = null;// Initial point provided to initilalize
		private var _body:b2Body                = null;
		private var fixture:b2Fixture           = null;
		private var bodyType:uint;
		private const coord:Point				= new Point();
		
		public function VerticeBody( pixelBasedPosition:Point, world:b2World, worldScale:int, bodyType:uint )
		{
			this.pixelBasedPosition = pixelBasedPosition;
			this.world = world;
			this.worldScale = worldScale;
			this.bodyType = bodyType;
			
			this.init();
		}
		
		private function init():void
		{
			var bodyDef:b2BodyDef                 = new b2BodyDef();
			bodyDef.position.Set( pixelBasedPosition.x / worldScale, pixelBasedPosition.y / worldScale );
			
			bodyDef.type 			    = bodyType; 
			
			bodyDef.linearDamping	    = 1;
			bodyDef.angularDamping	    = 1;
			
			var circularShape:b2CircleShape	= new b2CircleShape( 1 / this.worldScale );
			
			var fixtureDef:b2FixtureDef	= new b2FixtureDef();
			fixtureDef.shape			= circularShape;
			fixtureDef.friction			= 1;
			fixtureDef.density			= 1;
			fixtureDef.restitution		= .5;
			
			this.body                    = this.world.CreateBody( bodyDef );
			this.fixture                 = this.body.CreateFixture( fixtureDef );
		}
		
		public function  get pixelCoordinates():Point
		{
			var position:b2Vec2 = this.body.GetPosition();
			coord.x = position.x * this.worldScale;
			coord.y = position.y * this.worldScale;
			return coord;
		}
		
		public function update():void
		{
			var position:Point = this.pixelCoordinates;
			this.x = position.x;
			this.y = position.y;
			
			var angle:Number = body.GetAngle();
			this.rotation = angle * 180 / Math.PI;
		}
		
		public function draw( scale:Number = 1, color:Number = 0xFF0000 ):void
		{
			var radius:Number  = 4 * scale;
			
			
			graphics.clear();
			graphics.beginFill( color );
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}

		public function get body():b2Body
		{
			return _body;
		}

		public function set body(value:b2Body):void
		{
			_body = value;
		}

		
	}
}


	





