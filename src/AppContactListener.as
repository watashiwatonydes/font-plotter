package
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class AppContactListener extends b2ContactListener
	{
		

		
		public function AppContactListener()
		{
			super();
			
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			if ( contact.GetManifold() )
			{
				if ( contact.GetManifold().m_pointCount > 0 )
				{
					
					var fix1:b2Fixture 	= contact.GetFixtureA();
					var fix2:b2Fixture 	= contact.GetFixtureB();
					
					var body1:b2Body	= fix1.GetBody();
					var body2:b2Body	= fix2.GetBody();
					
					
					if ( body1.GetType() == b2Body.b2_dynamicBody && 
						body2.GetType() == b2Body.b2_dynamicBody )
					{
						contact.SetEnabled(false);	
					}
				}
			}
			
			// PreSolve( contact, oldManifold );
		}
		
		
		
		
		
	}
}