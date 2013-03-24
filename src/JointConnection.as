package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RopeJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Shape;
	
	public class JointConnection extends Shape
	{
		public static const DISTANCE_JOINT:int 	= 0;	
		public static const REVOLUTE_JOINT:int 	= 1;	
		public static const ROPE_JOINT:int 		= 2;	
		
		private var bodyA:b2Body;
		private var bodyB:b2Body;
		private var world:b2World;
		private var worldScale:int;
		private var jointType:int;
		public var joint:b2Joint;
		private var frequencyHz:Number;
		private var dampingRatio:Number;
		
		public function JointConnection(jointType:int, bodyA:b2Body, bodyB:b2Body, world:b2World, worldScale:int, 
										freqHz:Number = 4, dampingRatio:Number = .1)
		{
			this.jointType = jointType;
			this.bodyA = bodyA;
			this.bodyB = bodyB;
			this.world = world;
			this.worldScale = worldScale;
			this.frequencyHz = freqHz;
			this.dampingRatio = dampingRatio;
			
			
			this.init();
		}
		
		private function init():void
		{
			
			
			switch(jointType)
			{
				case JointConnection.DISTANCE_JOINT:
				
					var distanceJointDef:b2DistanceJointDef = null;;
					var localAnchorA:b2Vec2    = bodyA.GetWorldCenter();
					var localAnchorB:b2Vec2    = bodyB.GetWorldCenter();
					
					distanceJointDef = new b2DistanceJointDef();
					distanceJointDef.Initialize( bodyA, bodyB, localAnchorA, localAnchorB );
					distanceJointDef.collideConnected   = false;
					distanceJointDef.frequencyHz        = this.frequencyHz;
					distanceJointDef.dampingRatio       = this.dampingRatio; // Super Elastic
					
					this.joint                  = this.world.CreateJoint(distanceJointDef);
					
				break;
				case JointConnection.ROPE_JOINT:
					
					var ropeJointDef:b2RopeJointDef = new b2RopeJointDef();
					ropeJointDef.bodyA 				= bodyA;
					ropeJointDef.bodyB 				= bodyB;
					
					ropeJointDef.localAnchorA 		= new b2Vec2(0,0);
					ropeJointDef.localAnchorB 		= new b2Vec2(0,0);
					ropeJointDef.maxLength	 		= 6;
					ropeJointDef.collideConnected 	= true;
					
					this.joint	= this.world.CreateJoint(ropeJointDef);
				
				break;
					
			}
			
			
		}		
		
		public function draw( scale:int = 1, color:Number = 0x0000FF ):void
		{
			var posBodyA:b2Vec2 = this.bodyA.GetPosition();
			var posBodyB:b2Vec2 = this.bodyB.GetPosition();
			
			graphics.clear();
			graphics.lineStyle( 1, color );
			graphics.moveTo(posBodyA.x * this.worldScale, posBodyA.y * this.worldScale);
			graphics.lineTo(posBodyB.x * this.worldScale, posBodyB.y * this.worldScale);
		}
			
	}
}


		




