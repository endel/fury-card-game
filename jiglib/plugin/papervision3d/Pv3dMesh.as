package jiglib.plugin.papervision3d {
	import flash.geom.Matrix3D;
	
	import jiglib.plugin.ISkin3D;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	 * @author muzer
	 */
	public class Pv3dMesh implements ISkin3D{
		
		private var do3d:DisplayObject3D;

		public function Pv3dMesh(do3d:DisplayObject3D) {
			this.do3d = do3d;
		}

		public function get transform():flash.geom.Matrix3D {
			var tr:flash.geom.Matrix3D = new flash.geom.Matrix3D();
			tr.rawData[0] = do3d.transform.n11; 
			tr.rawData[4] = do3d.transform.n12; 
			tr.rawData[8] = do3d.transform.n13; 
			tr.rawData[12] = do3d.transform.n14;
			tr.rawData[1] = do3d.transform.n21; 
			tr.rawData[5] = do3d.transform.n22; 
			tr.rawData[9] = do3d.transform.n23; 
			tr.rawData[13] = do3d.transform.n24;
			tr.rawData[2] = do3d.transform.n31; 
			tr.rawData[6] = do3d.transform.n32; 
			tr.rawData[10] = do3d.transform.n33; 
			tr.rawData[14] = do3d.transform.n34;
			tr.rawData[3] = do3d.transform.n41; 
			tr.rawData[7] = do3d.transform.n42; 
			tr.rawData[11] = do3d.transform.n43; 
			tr.rawData[15] = do3d.transform.n44;
			 
			return tr;
		}
		
		public function set transform(m:flash.geom.Matrix3D):void {
			var tr:org.papervision3d.core.math.Matrix3D = new org.papervision3d.core.math.Matrix3D();
			tr.n11 = m.rawData[0]; 
			tr.n12 = m.rawData[4]; 
			tr.n13 = m.rawData[8]; 
			tr.n14 = m.rawData[12];
			tr.n21 = m.rawData[1]; 
			tr.n22 = m.rawData[5]; 
			tr.n23 = m.rawData[9]; 
			tr.n24 = m.rawData[13];
			tr.n31 = m.rawData[2]; 
			tr.n32 = m.rawData[6]; 
			tr.n33 = m.rawData[10]; 
			tr.n34 = m.rawData[14];
			tr.n41 = m.rawData[3]; 
			tr.n42 = m.rawData[7]; 
			tr.n43 = m.rawData[11]; 
			tr.n44 = m.rawData[15];
			
			var scale:org.papervision3d.core.math.Matrix3D = org.papervision3d.core.math.Matrix3D.scaleMatrix(do3d.scaleX, do3d.scaleY, do3d.scaleZ);
			tr = org.papervision3d.core.math.Matrix3D.multiply(tr, scale);
			do3d.transform = tr;
		}
		
		public function get mesh():DisplayObject3D {
			return do3d;
		}
	}
}
