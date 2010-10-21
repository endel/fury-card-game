package jiglib.plugin.away3dlite
{
	import away3dlite.core.base.Object3D;
	
	import flash.geom.Matrix3D;
	
	import jiglib.plugin.ISkin3D;

	/**
	 * @author katopz
	 */
	public class Away3DLiteMesh implements ISkin3D
	{
		private var object3D:Object3D;
		public var mesh:Object3D;

		public function Away3DLiteMesh(object3D:Object3D)
		{
			mesh = this.object3D = object3D;
		}

		public function get transform():Matrix3D
		{
			return object3D.transform.matrix3D
			/*
			var _rawData:Vector.<Number> = object3D.transform.matrix3D.rawData;
			return new JMatrix3D(Vector.<Number>([
				_rawData[0], _rawData[4], _rawData[8], _rawData[12],
				_rawData[1], _rawData[5], _rawData[9], _rawData[13],
				_rawData[2], _rawData[6], _rawData[10], _rawData[14],
				_rawData[3], _rawData[7], _rawData[11], _rawData[15]
			]));
			*/
		}
		
		public function set transform(m:Matrix3D):void
		{
			// this can be easy if jiglib team swap yUp to native here...no?
			//object3D.transform.matrix3D = m.clone();
			
			// nvm, just use this instead
			var _rawData:Vector.<Number> = m.rawData;
			object3D.transform.matrix3D = new Matrix3D(Vector.<Number>([
				_rawData[0], -_rawData[1], _rawData[2], _rawData[3],
				-_rawData[4], _rawData[5], -_rawData[6], _rawData[7],
				_rawData[8], -_rawData[9], _rawData[10], _rawData[11],
				_rawData[12], -_rawData[13], _rawData[14], _rawData[15]
			]));
		}
	}
}