package
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.exporters.AS3GraphicsDataShapeExporter;
	import com.codeazur.as3swf.tags.TagDefineFont3;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import org.poly2tri.Point;
	import org.poly2tri.Sweep;
	import org.poly2tri.SweepContext;
	import org.poly2tri.Triangle;
	
	import utils.GeometryUtils;
	
	[SWF(backgroundColor="0xffffff", frameRate="60", widthPercent="100", heightPercent="100")]
	public class Application extends Sprite
	{
		
		[Embed(source="/Library/Fonts/Arial.ttf", fontName="rune", mimeType="application/x-font-truetype", 
		advancedAntiAliasing="false", embedAsCFF="false", unicodeRange="U+0020-007E")]
		private var Font:Class;
		
		private var _polylineVector:Vector.<Number>; 
		
		
		public function Application()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.init();
		}
		
		private function init():void
		{
			var swf:SWF = new SWF(loaderInfo.bytes);
			var font:TagDefineFont3 = swf.getCharacter(1) as TagDefineFont3;
			
			var exporter:AS3GraphicsDataShapeExporter = new AS3GraphicsDataShapeExporter(swf);			
			font.export(exporter, 18); // 34 -> B, 37 -> E
			
			var ln:int = exporter.graphicsData.length;
			for(var i:uint = 0; i < ln ; i++) 
			{
				var gdo:IGraphicsData = exporter.graphicsData[i];
				if(gdo is GraphicsPath) 
				{
					var gp:GraphicsPath = gdo as GraphicsPath;
					this.processGraphicsPath(gp);
				}
			}
			
			triangulate();
		}		
		
		private function processGraphicsPath(gp:GraphicsPath):void
		{
			var c:Vector.<int> = gp.commands;
			var d:Vector.<Number> = gp.data;
			var coords:Vector.<Number>;
			var p:Point	= new Point();
			var bounds:Rectangle = GeometryUtils.GetCharacterBounds(d);
			var dx:Number = 0;
			var dy:Number = bounds.y - 20;
			_polylineVector = new Vector.<Number>();
			
			
			
			for(var i:uint = 0; i < c.length; i++) 
			{
				coords = null;
				switch(c[i]) 
				{
					case GraphicsPathCommand.MOVE_TO:
						
						coords = d.splice(0, 2);
						
						drawDot(graphics, coords[0] - dx, coords[1] - dy, 0);
						
						GeometryUtils.AddPoint( _polylineVector, coords[0] - dx, coords[1] - dy ); 
						
						
						break;
					
					case GraphicsPathCommand.LINE_TO:
						coords = d.splice(0, 2);
			
						if(coords[0] != p.x || coords[1] != p.y) 
						{
							drawDot(graphics, coords[0] - dx, coords[1] - dy, 1);
							
							GeometryUtils.AddPoint( _polylineVector, coords[0] - dx, coords[1] - dy );
							
						}
						
						break;
					
					case GraphicsPathCommand.CURVE_TO:
						coords = d.splice(0, 4);
						
						if(coords[0] != p.x || coords[1] != p.y)
						{
							drawDot(graphics, coords[0] - dx, coords[1] - dy, 2);
							drawDot(graphics, coords[2] - dx, coords[3] - dy, 2);
							
							GeometryUtils.AddPoint( _polylineVector, coords[0] - dx, coords[1] - dy );
							GeometryUtils.AddPoint( _polylineVector, coords[2] - dx, coords[3] - dy );
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
		
		private function triangulate():void
		{
			var polystring:String = "";
			var coords:Vector.<Number>;
			var dx:Number = 0, dy:Number = 0;
			
			while (_polylineVector.length > 0 )
			{
				coords = _polylineVector.splice(0, 2);

				polystring += coords[0] + " " + coords[1];
				polystring += ",";
			}
			
			polystring = polystring.substr(0, polystring.length - 1);
			
			
			var sweepContext:SweepContext 	= new SweepContext();
			var sweep:Sweep 				= new Sweep(sweepContext);
			
			var points:Vector.<Point> = new Vector.<Point>();
			for each (var xy_str:String in polystring.split(',')) 
			{
				var xyl:Array = xy_str.replace(/^\s+/, '').replace(/\s+$/, '').split(' ');
				points.push(new Point(parseFloat(xyl[0]) + dx, parseFloat(xyl[1]) + dy));
			}
			
			sweepContext.addPolyline(points);
			sweep.triangulate();
			
			
			var t:Triangle
			var pl:Vector.<Point>;
			
			graphics.lineStyle(1, 0x999999, 1);
			graphics.beginFill(0xffffff, 1);
			var ln:int = sweepContext.triangles.length;

			var pt0:Point, pt1:Point, pt2:Point;
			var interpolated0:Vector.<Number>, interpolated1:Vector.<Number>, interpolated2:Vector.<Number>;;
			for each (t in sweepContext.triangles) 
			{
				pl 	= t.points;
				
				pt0 = pl[0];
				pt1 = pl[1];
				pt2 = pl[2];
			
				graphics.lineStyle(1, 0x999999, .3);
				
				graphics.moveTo(pt0.x, pt0.y);
				graphics.lineTo(pt1.x, pt1.y);
				graphics.lineTo(pt2.x, pt2.y);
				graphics.lineTo(pt0.x, pt0.y);
				
				graphics.lineStyle(1, 0xff0000, .3);
				
				interpolated0 = GeometryUtils.Interpolate(pt0.x, pt0.y, pt1.x, pt1.y, 0.5);
				interpolated1 = GeometryUtils.Interpolate(pt1.x, pt1.y, pt2.x, pt2.y, 0.5);
				interpolated2 = GeometryUtils.Interpolate(pt0.x, pt0.y, pt2.x, pt2.y, 0.5);
				
				graphics.moveTo( interpolated0[0], interpolated0[1] );
				graphics.lineTo( interpolated1[0], interpolated1[1] );
				graphics.lineTo( interpolated2[0], interpolated2[1] );
				graphics.lineTo( interpolated0[0], interpolated0[1] );
			}
		}
		
		
		private function drawDot(g:Graphics, px:Number, py:Number, type:uint = 0):void 
		{
			var col:uint, fill:uint = 0xffffff, w:uint, h:uint;
			switch(type) 
			{
				case 0: 
					col = 0xFF0000; 
					w = 10, h = 10;
					break;
				case 1: 
					col = 0x00FF00;
					fill = 0x00FF00;
					w = 6, h = 6;
					break;
				case 2: 
					col = 0x0000FF; 
					fill = 0x0000FF;
					w = 4, h = 4;
					break;
				case 3: 
					col = 0x000000; 
					fill = 0x000000;
					w = 5, h = 5;
					break;
			}
			
			g.lineStyle(1, col);
			if( fill != 0xFFFFFF )
				g.beginFill(fill);	
			g.drawRect(px - w/2, py - w/2, w, h);
		}
		
		
		
		
		
	}
}