package jiglib.plugin.away3d
{
	import away3d.core.base.Mesh;
	import away3d.core.math.MatrixAway3D;
	
	import flash.geom.Matrix3D;
	
	import jiglib.plugin.ISkin3D;

	/**
	 * @author katopz
	 */
	public class Away3dMesh implements ISkin3D
	{

		public function Away3dMesh(do3d:Mesh)
		{
			this._mesh = do3d;
		}

		private var _mesh:Mesh;

		public function get mesh():Mesh
		{
			return _mesh;
		}

		public function get transform():Matrix3D
		{
			var _transform:MatrixAway3D = _mesh.transform;
			return new Matrix3D(Vector.<Number>([
				_transform.sxx, _transform.syx, _transform.szx, _transform.swx,
				_transform.sxy, _transform.syy, _transform.szy, _transform.swy,
				_transform.sxz, _transform.syz, _transform.szz, _transform.swz,
				_transform.tx,  _transform.ty,  _transform.tz,  _transform.tw
			]));
		}

		public function set transform(m:Matrix3D):void
		{
			var _rawData:Vector.<Number> = m.rawData;

			var tr:MatrixAway3D = new MatrixAway3D();
			tr.sxx = _rawData[0];
			tr.sxy = _rawData[4];
			tr.sxz = _rawData[8];
			tr.tx = _rawData[12];
			tr.syx = _rawData[1];
			tr.syy = _rawData[5];
			tr.syz = _rawData[9];
			tr.ty = _rawData[13];
			tr.szx = _rawData[2];
			tr.szy = _rawData[6];
			tr.szz = _rawData[10];
			tr.tz = _rawData[14];
			tr.swx = _rawData[3];
			tr.swy = _rawData[7];
			tr.swz = _rawData[11];
			tr.tw = _rawData[15];
			
			var scale:MatrixAway3D = new MatrixAway3D();
			scale.scaleMatrix(_mesh.scaleX, _mesh.scaleY, _mesh.scaleZ);
			tr.multiply(tr, scale);
			
			_mesh.transform = tr;
		}
	}
}
