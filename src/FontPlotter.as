package
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.exporters.AS3GraphicsDataShapeExporter;
	import com.codeazur.as3swf.tags.TagDefineFont3;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	

	[SWF(backgroundColor="0x111111", frameRate="60", width="1200", heightPercent="100")]
	public class FontPlotter extends Sprite
	{
		
		
		[Embed(source="/Library/Fonts/Didot.ttc", fontName="rune", mimeType="application/x-font-truetype", 
		advancedAntiAliasing="false", embedAsCFF="false", unicodeRange="U+0020-007E")]
		private var FontClass:Class;

		private var _world:b2World;
		public static const WORLD_SCALE:int = 30;
		public static const DEG2RAD:Number = 0.0174532925;

		private var _dragVerticeBody:VerticeBody;
		private var _dragJointConnection:JointConnection;
		private var _mouseJoint:b2MouseJoint;
		private var _letters:Vector.<Letter>;

		private var _swf:SWF;

		private var _font:TagDefineFont3;

		private var GOODS:Array;
		private var _timer:Timer;

		private var _sound:Sound;
		
		public function FontPlotter()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var font:* = new FontClass();
			
			init();
		}
		
		private function init( event:Event = null ):void
		{
			var gravity:b2Vec2  = new b2Vec2( 0.0 , 1 );
			_world 	= new b2World( gravity, true );
			
			// _world.SetContactListener( new AppContactListener() );
			
			
			// Floor
			var bodyDef:b2BodyDef	= new b2BodyDef();
			bodyDef.position.Set( (stage.stageWidth) / WORLD_SCALE, (stage.stageHeight) / WORLD_SCALE );
			bodyDef.type 					= b2Body.b2_staticBody;
			
			var polygonShape:b2PolygonShape	= new b2PolygonShape();
			polygonShape.SetAsBox( (2 * stage.stageWidth) / WORLD_SCALE, 1 / WORLD_SCALE );
			var fixtureDef:b2FixtureDef		= new b2FixtureDef();
			fixtureDef.shape				= polygonShape;
			
			var theFloor:b2Body				= _world.CreateBody( bodyDef );	
			theFloor.CreateFixture( fixtureDef );
			
			// Right
			var bodyDefR:b2BodyDef	= new b2BodyDef();
			bodyDefR.position.Set( (stage.stageWidth * 1) / WORLD_SCALE, (stage.stageHeight/2) / WORLD_SCALE );
			bodyDefR.type 					= b2Body.b2_staticBody;
			
			var polygonShapeR:b2PolygonShape	= new b2PolygonShape();
			polygonShapeR.SetAsBox( 1 / WORLD_SCALE, (stage.stageHeight/2) / WORLD_SCALE );
			var fixtureDefR:b2FixtureDef		= new b2FixtureDef();
			fixtureDefR.shape				= polygonShapeR;
			
			var theFloorR:b2Body				= _world.CreateBody( bodyDefR );	
			theFloorR.CreateFixture( fixtureDefR );
			
			
			// Parse the SWF file and extract font informations
			_swf = new SWF(loaderInfo.bytes);
			_font = _swf.getCharacter(1) as TagDefineFont3;
			
			GOODS = [ 22, 34, 66, 66, 67, 68, 79, 80, 81 ]
			
			
			// Creates a Letter 
			_letters = new  Vector.<Letter>();
			
			
			
			_timer = new Timer( 13000, 9 );
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			onTimer(null);

			
			_sound = new Sound();
			_sound.addEventListener(Event.COMPLETE, function(event:Event):void 
			{
				_sound.play(0);
			} )
			_sound.load( new URLRequest( "assets/satie.mp3" ) );
				
			
			/*
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			*/
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		protected function onTimer(event:TimerEvent):void
		{
		
			var ln:int 			= GOODS.length;
			
			if ( ln > 0 )
			{
				var r:int 			= Math.floor( Math.random() * ln );
				
				var exported:int 	= GOODS[ r ];	
				GOODS.splice( r, 1);
				
				var exporter:AS3GraphicsDataShapeExporter = new AS3GraphicsDataShapeExporter(_swf);			
				_font.export(exporter, exported);
				
				var letter:Letter 	= new Letter( exporter, _world, WORLD_SCALE, stage );
				
				addChild( letter );
				
				letter.applyImpulse();
				
				var oldLetter:Letter = _letters.pop();
				if ( oldLetter )
				{
					
					oldLetter.destroy();	
				}
				
				_letters.push( letter );
				
			}
		}
		
		protected function update(event:Event):void
		{
			_world.Step( 1/30, 3, 3 );
			_world.ClearForces();
			
			var l:Letter;
			for each ( l in _letters )
			{
				l.draw();	
			}
		}
		
		
		
		/* Interactions */
		protected function mouseToWorld():b2Vec2
		{
			var buffer:b2Vec2 = new b2Vec2( stage.mouseX / WORLD_SCALE, stage.mouseY / WORLD_SCALE );
			return buffer;
		}
		
		/*
		protected function handleMouseUp(event:MouseEvent):void
		{
			if( _mouseJoint )
			{
				_world.DestroyJoint( _mouseJoint );
				_mouseJoint = null;
			}
			
			if(_dragVerticeBody)
			{
				removeChild( _dragVerticeBody );
				_world.DestroyBody(_dragVerticeBody.body);
				_dragVerticeBody.graphics.clear();
				_dragVerticeBody.body = null;
				_dragVerticeBody = null;
			}
			
			if(_dragJointConnection)
			{
				removeChild( _dragJointConnection );
				_world.DestroyJoint(_dragJointConnection.joint);
				_dragJointConnection.graphics.clear();
				_dragJointConnection.joint = null;
				_dragJointConnection = null;
			}
		}
		
		protected function handleMouseMove(event:MouseEvent):void
		{
			var mousePos = null;
			if( event.buttonDown )
			{
				if( _mouseJoint ){
					
					mousePos = mouseToWorld();
					_mouseJoint.SetTarget( mousePos );
				}
			}
		}
		
		protected function handleMouseDown(event:MouseEvent):void
		{
			
			var mousePosition:Point = new Point( stage.mouseX, stage.mouseY );
			var someVerticeBody:VerticeBody = null;
			var vb:VerticeBody = null;
			var d:Number = Number.MAX_VALUE;
			
			for each(vb in VerticesBodies)
			{
				var dist2Point:Number = Point.distance( vb.pixelCoordinates, mousePosition );
				if( dist2Point < d )
				{
					someVerticeBody = vb;
					d = dist2Point;
				}
			}
			
			
			_dragVerticeBody = new VerticeBody( mousePosition, _world, WORLD_SCALE, b2Body.b2_dynamicBody);
			addChild( _dragVerticeBody );
			_dragVerticeBody.draw( 30 );
			
			trace ( _dragVerticeBody );
			
			_dragJointConnection = new JointConnection( JointConnection.ROPE_JOINT, _dragVerticeBody.body, someVerticeBody.body, _world, WORLD_SCALE);
			addChild( _dragJointConnection );
			
			_world.QueryPoint( this.queryCallback, mouseToWorld() );
			
		}
		
		private function queryCallback( fixture:b2Fixture ):void
		{
			if (fixture)
			{
				var touchedBody:b2Body         = fixture.GetBody();
				if( touchedBody.GetType() == b2Body.b2_dynamicBody )
				{
					var jointDef:b2MouseJointDef = new b2MouseJointDef();
					
					jointDef.bodyA 		    = _world.GetGroundBody();
					jointDef.bodyB 		    = touchedBody;
					jointDef.target 	    = mouseToWorld();
					jointDef.maxForce	    = 300 * touchedBody.GetMass();
					jointDef.frequencyHz    = 4;
					jointDef.dampingRatio   = .2;
					
					_mouseJoint			= _world.CreateJoint( jointDef ) as b2MouseJoint;
					
					
					var mousePos = null;
					if( _mouseJoint )
					{
							
						mousePos = mouseToWorld();
						_mouseJoint.SetTarget( mousePos );
					}
					
				}
			}
		}
		*/
		
		
				
		
		
				
		
		
	}
}