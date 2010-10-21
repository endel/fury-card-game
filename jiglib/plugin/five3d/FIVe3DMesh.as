package jiglib.plugin.five3d {
	import flash.geom.Vector3D;
	import jiglib.plugin.ISkin3D;
	import flash.geom.Matrix3D;
	import net.badimon.five3D.display.Sprite3D;

	/**
	 * @author Devin Reimer (blog.almostlogical.com), based on class Pv3dMesh written by bartekd
	 * */
	public class FIVe3DMesh implements ISkin3D
	{	
		private var sprite3D:Sprite3D;
		private var rawData:Vector.<Number>; //temporary variable used for changing matrix
		
		public function FIVe3DMesh(sprite3D:Sprite3D) {
			this.sprite3D = sprite3D;
		}
		
		public function get transform():flash.geom.Matrix3D
		{
			rawData = sprite3D.matrix.rawData;
			//-180 X-Axis
			rawData[4] = -rawData[4];
			rawData[5] = -rawData[5];
			rawData[6] = -rawData[6];
			rawData[8] = -rawData[8];
			rawData[9] = -rawData[9];
			rawData[10] = - rawData[10];
			rawData[13] = -rawData[13];	 //-y
			return new Matrix3D(rawData);
		}
		
		public function set transform(m:flash.geom.Matrix3D):void 
		{
			rawData = m.rawData;
			//-180 X-Axis
			rawData[4] = -rawData[4];
			rawData[5] = -rawData[5];
			rawData[6] = -rawData[6];
			rawData[8] = -rawData[8];
			rawData[9] = -rawData[9];
			rawData[10] = - rawData[10];
			rawData[13] = -rawData[13];	 //-y
			sprite3D.matrix = new Matrix3D(rawData);
		}
		
		public function get mesh():Sprite3D {
			return sprite3D;
		}
		
	}
}
