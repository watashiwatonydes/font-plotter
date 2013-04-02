package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import com.codeazur.as3swf.exporters.AS3GraphicsDataShapeExporter;
	import com.codeazur.utils.BitArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Letter extends Sprite
	{
		private var _exporter:AS3GraphicsDataShapeExporter;
		private var _outlinePoints:Vector.<Point>;
		private var _verticesBodies:Vector.<VerticeBody>;
		private var _jointConnections:Vector.<JointConnection>;
		private var _commandToVerticeBodyMapper:Array;
		
		private var _world:b2World;
		
		private var _worldScale:Number;
		private var _delaunay:Delaunay;
		private var _drawing:BitmapData;
		private var _stage:Stage;
		private var _loopCounter:int = 0;
		
		
		private static const DEG2RAD:Number 	= 0.0174532925;
		private var _fillRect:Rectangle;
		
		
		public function Letter( exporter:AS3GraphicsDataShapeExporter, world:b2World, worldScale:Number, stage:Stage )
		{
			_exporter 	= exporter;
			_world 		= world; 	
			_worldScale = worldScale;
			_stage		= stage;	
			
			
			
			init( null );
		}
		
		private function init( event:Event = null ):void
		{
			//_drawing	= new BitmapData( _stage.stageWidth, _stage.stageHeight, true, 0x00000000 );

			//_stage.addChild( new Bitmap( _drawing ) );
			
			
			for(var i:uint = 0; i < _exporter.graphicsData.length; i++) 
			{
				var gdo:IGraphicsData = _exporter.graphicsData[i];
				if(gdo is GraphicsPath) 
				{
					var gp:GraphicsPath = gdo as GraphicsPath;
					this.processGraphicsPath(gp);
				}
			}
			
			connectBodies();
		}
		
		public function destroy():void 
		{
			var j:b2Joint;
			
			for each( var conn:JointConnection in _jointConnections )
			{
				j = conn.joint;
				
				_world.DestroyJoint( j );
				
				j = null;
			}
			
			var b:b2Body; 		 
			for each( var vertex:VerticeBody in _verticesBodies )
			{
				b = vertex.body;
				
				_world.DestroyBody( b );
				
				b = null;
			}
		}
		
		private function processGraphicsPath(gp:GraphicsPath):void
		{
			var c:Vector.<int> 		= gp.commands;
			var d:Vector.<Number> 	= gp.data;
			var p:Point 			= new Point(0, 0);
			var bounds:Rectangle 	= getCharacterBounds(d);
			var scale:Number		= 1;
			
			
			
			var dx:Number 			= bounds.x - 20;
			var dy:Number 			= bounds.y - 20;
			
			for ( var a:int = 0 ; a < d.length ; a += 2)
			{
				// translate
				d[ a ] -= dx; 
				d[ a+1 ] -= dy;
				
				// scale
				d[ a ] *= scale;
				d[ a+1 ] *= scale;
			}
			
			
			var coords:Vector.<Number>;
			var index:int;
			var vb:VerticeBody;
			
			_outlinePoints					= new Vector.<Point>()
			_verticesBodies					= new Vector.<VerticeBody>();
			_commandToVerticeBodyMapper 	= [];
				
			
			for(var i:uint = 0; i < c.length; i++) 
			{
				coords = null;
				switch(c[i]) 
				{
					case GraphicsPathCommand.MOVE_TO:
						
						coords = d.splice(0, 2);
						
						var p0:Point = new Point(coords[0], coords[1]);
						
						index		 = pointExist( p0 );
						if ( index < 0 )
						{
							_outlinePoints.push( p0 );
							
							vb = new VerticeBody( p0, _world, _worldScale, b2Body.b2_dynamicBody );
							_verticesBodies.push( vb );
						}
						else
						{
							vb = findVerticeBodyForPoint( p0.x, p0.y );
						}
						
						var mapper:Object = { command: GraphicsPathCommand.MOVE_TO, vb0: vb };
						_commandToVerticeBodyMapper.push( mapper );
						
						break;
					case GraphicsPathCommand.LINE_TO:
						coords = d.splice(0, 2);
						if(coords[0] != p.x || coords[1] != p.y) 
						{
							p0 			= new Point(coords[0], coords[1]);
							
							index		= pointExist( p0 );
							if ( index < 0 )
							{
								_outlinePoints.push( p0 );
								
								vb = new VerticeBody( p0, _world, _worldScale, b2Body.b2_dynamicBody );
								_verticesBodies.push( vb );
							}
							else
							{
								vb = findVerticeBodyForPoint( p0.x, p0.y );
							}
							
							mapper = { command: GraphicsPathCommand.LINE_TO, vb0: vb };
							_commandToVerticeBodyMapper.push( mapper );
							
						}
						break;
					case GraphicsPathCommand.CURVE_TO:
						coords = d.splice(0, 4);
						if(coords[0] != p.x || coords[1] != p.y) 
						{
							p0 = new Point(coords[0], coords[1]);
							
							var index0:int = pointExist( p0 );
							var vb0:VerticeBody;
							if ( index < 0 )
							{
								_outlinePoints.push( p0 );
								
								vb0 = new VerticeBody( p0, _world, _worldScale, b2Body.b2_dynamicBody );
								_verticesBodies.push( vb0 );
							}
							else
							{
								vb0 = findVerticeBodyForPoint( p0.x, p0.y );
							}
							
							var p1:Point = new Point(coords[2], coords[3]);
							
							var index1:int = pointExist( p1 );
							var vb1:VerticeBody;
							if ( index < 0 )
							{
								_outlinePoints.push( p1 );
								
								vb1 = new VerticeBody( p1, _world, _worldScale, b2Body.b2_dynamicBody );
								_verticesBodies.push( vb1 );
							}
							else
							{
								vb1 = findVerticeBodyForPoint( p1.x, p1.y );;
							}
							
							mapper = { command: GraphicsPathCommand.CURVE_TO, vb0: vb0, vb1: vb1 };
							_commandToVerticeBodyMapper.push( mapper );
						}
						break;
				}
				if(coords) 
				{
					p.y = coords.pop();
					p.x = coords.pop();
				}
			}
		}		

		private function connectBodies():void
		{
			_delaunay	 = new Delaunay();
			_jointConnections = new Vector.<JointConnection>();
			
			var attachPoints:Vector.<Point> = new Vector.<Point>();
			for each (var o:Object in _commandToVerticeBodyMapper )
			{
				
				if (o.command == GraphicsPathCommand.CURVE_TO)
					attachPoints.push( o.vb0.pixelBasedPosition, o.vb1.pixelBasedPosition );
				else 
					attachPoints.push( o.vb0.pixelBasedPosition );
			}
			
			var indices:Vector.<int> = _delaunay.compute( attachPoints );
			
			var id0:uint, id1:uint, id2:uint;
			var vb0:VerticeBody, vb1:VerticeBody, vb2:VerticeBody;
			var jc0:JointConnection, jc1:JointConnection, jc2:JointConnection;
			var p0:Point, p1:Point, p2:Point; 
			
			for ( var i:int = 0; i < indices.length; i+=3 ) 
			{
				id0 = indices[ i ];
				id1 = indices[ i + 1 ];
				id2 = indices[ i + 2 ];
				
				p0 	= attachPoints[ id0 ];
				p1 	= attachPoints[ id1 ];
				p2 	= attachPoints[ id2 ];
				
				vb0 = findVerticeBodyForPoint( p0.x, p0.y );
				vb1 = findVerticeBodyForPoint( p1.x, p1.y )
				vb2 = findVerticeBodyForPoint( p2.x, p2.y );
				
				if ( vb0 && vb1 && vb2 )
				{
					if ( vb0 != vb1 )
						jc0	= new JointConnection( JointConnection.DISTANCE_JOINT, vb0.body, vb1.body, _world, _worldScale );
					
					if ( vb1 != vb2 )
						jc1 = new JointConnection( JointConnection.DISTANCE_JOINT, vb1.body, vb2.body, _world, _worldScale );
					
					if ( vb0 != vb2 )
						jc2 = new JointConnection( JointConnection.DISTANCE_JOINT, vb2.body, vb0.body, _world, _worldScale );
					
					_jointConnections.push( jc0, jc1, jc2 );
				}
			}
		}
		
		public function draw():void
		{
			// _fillRect = new Rectangle( 0, 0, _stage.stageWidth, _stage.stageHeight );
			// _drawing.fillRect( _fillRect, 0x00000000 )
			
			graphics.clear();
			graphics.beginFill(0xFFD702, .1);
			
			
			var coords:Point;	
			var coords2:Point;	
			for each (var o:Object in _commandToVerticeBodyMapper )
			{
				
				switch (o.command )
				{
					case GraphicsPathCommand.MOVE_TO:
						
						coords  = o.vb0.pixelCoordinates;
						
						graphics.moveTo(coords.x, coords.y);
						
						break;
					case GraphicsPathCommand.LINE_TO:
						
						coords  = o.vb0.pixelCoordinates;
						
						graphics.lineTo(coords.x, coords.y);

						
						break;
					case GraphicsPathCommand.CURVE_TO:
						
						coords  = o.vb0.pixelCoordinates;
						coords2  = o.vb1.pixelCoordinates;
						
						graphics.curveTo( coords.x, coords.y, coords2.x, coords2.y );
						
						break;
				}

			}
			
			graphics.endFill();
			
			// _drawing.draw( this );
		}

		public function applyImpulse():void
		{
			var rx:Number = 8 + Math.random() * 4;
			var impulse:b2Vec2 	= new b2Vec2( rx / _worldScale, 0 );
			var ln:int = int(_verticesBodies.length/3);	
			var vb:VerticeBody;
			var center:b2Vec2;
			
			
			for (var i:int = 0 ; i < ln ; i++)
			{
				vb 			= _verticesBodies[ i ];	
				center 		= vb.body.GetWorldCenter()
				
				vb.body.ApplyImpulse( impulse, center );
			}
		}
		
		/* Utility functions */
		private function drawDot(g:Graphics, px:Number, py:Number, type:uint = 0):void 
		{
			var col:uint;
			switch(type) {
				case 0: col = 0x00FFFF; break;
				case 1: col = 0x0000ff; break;
				case 2: col = 0xFF0000; break;
			}
			g.lineStyle(1, col);
			g.drawRect(px - 4, py - 4, 8, 8);
		}
		
		private function pointExist(newP:Point):int
		{
			var p:Point;
			for (var i:int = 0 ; i < _outlinePoints.length ; i++)
			{
				p = _outlinePoints[ i ];
				if ( p.x == newP.x && p.y == newP.y ) return i;
			}
			return -1;
		}
		
		protected function findVerticeBodyForPoint( px:Number, py:Number ):VerticeBody 
		{
			var pp:Point;
			var buffer:VerticeBody;
			for each( var vb:VerticeBody in _verticesBodies)
			{
				pp = vb.pixelBasedPosition;
				if ( pp.x == px && pp.y == py )
				{
					buffer = vb;
					return buffer;
				}
			}
			return null;
		}
		
		private function getCharacterBounds(points:Vector.<Number>):Rectangle 
		{
			var tl:Point = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
			var br:Point = new Point(-Number.MAX_VALUE, -Number.MAX_VALUE);
			var num:uint = points.length;
			for(var i:uint = 0; i < num; i += 2) {
				var px:Number = points[i];
				var py:Number = points[i + 1];
				if(tl.x > px) tl.x = px;
				if(tl.y > py) tl.y = py;
				if(br.x < px) br.x = px;
				if(br.y < py) br.y = py;
			}
			return new Rectangle(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
		}
		
	}
}