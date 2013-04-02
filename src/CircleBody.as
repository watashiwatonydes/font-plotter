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
	
	public class CircleBody extends Shape
	{
		private var world:b2World				= null;
		private var worldScale:int      		= 30;
		public  var pixelBasedPosition:Point    = null;
		private var _body:b2Body                = null;
		private var fixture:b2Fixture           = null;
		private var bodyType:uint;
		private const coord:Point				= new Point();
		private var radius:Number;
		
		public function CircleBody(pixelBasedPosition:Point, world:b2World, worldScale:int, bodyType:uint, radius:Number = 100)
		{
			this.pixelBasedPosition = pixelBasedPosition;
			this.world = world;
			this.worldScale = worldScale;
			this.bodyType = bodyType;
			this.radius = radius;
			
			this.init();
		}
		
		public function init( ):void
		{
			var bodyDef             = new b2BodyDef();
			bodyDef.position.Set( pixelBasedPosition.x / this.worldScale, pixelBasedPosition.y / this.worldScale );
			bodyDef.type 			= b2Body.b2_dynamicBody;
			bodyDef.fixedRotation	= false;
			bodyDef.linearDamping	= .1;
			bodyDef.angularDamping	= .1;
			
			
			var circleShape:b2CircleShape	= new b2CircleShape( this.radius / this.worldScale );
			
			var fixtureDef  		= new b2FixtureDef();
			fixtureDef.shape		= circleShape;
			fixtureDef.friction		= .1;
			fixtureDef.density		= 1 * radius;
			fixtureDef.restitution	= 0.8;
			
			_body					= this.world.CreateBody( bodyDef );
			_body.CreateFixture( fixtureDef );
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
			var r:Number  = radius * scale;
			
			graphics.clear();
			graphics.beginFill( color );
			graphics.drawCircle(0, 0, r);
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