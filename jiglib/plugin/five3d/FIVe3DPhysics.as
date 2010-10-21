package jiglib.plugin.five3d {
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.math.JMatrix3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;
	import jiglib.plugin.ISkin3D;

	//import five3D.display.Sprite3D;
	//import five3D.display.Scene3D;
	import net.badimon.five3D.display.Sprite3D;
	import net.badimon.five3D.display.Scene3D;

	import almostlogical.five3d.primitives.Cube;

	/**
	 * @author Devin Reimer (blog.almostlogical.com), based on class Papervision3DPhysics written by bartekd
	 * 
	 * Important Note: You must have the AlmostLogical FIVe3D Additional Files Package (contains a modified version of Sprite3D (fully backwards compatible) and FIVe3D primitives(ex:Cube)) to use this plugin, 
	 *   you can download this package directly from http://blog.almostlogical.com/resources/AlmostLogical_FIVe3D_Additional_Files_PackageFP10.zip (these classes are also released under the MIT License)
	 * */
	public class FIVe3DPhysics extends AbstractPhysics {

		private var baseScene:Sprite3D;

		public function FIVe3DPhysics(baseScene:Sprite3D, speed:Number = 1) {
			super(speed);
			this.baseScene = baseScene;
			baseScene.childrenSorted = true;
			
			//a tester to determine if you have the modified Sprite3D class that is needed for JigLibFlash support
			//new Sprite3D().onlyAllowMatrixModifications();//if you are getting an ERROR on this line follow the following instructions:
			/**
			 * 1) Modify your FIVe3D library to support Flash Player 10 or download my modified version http://blog.almostlogical.com/resources/FIVe3D_package_v2.1.2F10.zip
			 * 2) Download the FIVe3D support files (modified version of Sprite3D and FIVe3D primitives(ex:Cube)
			 * 		you can download them directly from http://blog.almostlogical.com/resources/AlmostLogical_FIVe3D_Additional_Files_PackageFP10.zip (these classes are also released under the MIT License)
			 * 3) Add these files including their appropriate folder structure to your project. ex: five3D/display/Sprite3D.as, almostlogical/five3d/primitives/Cube.as
			 * 
			 * You will have do these steps for 3 reasons, first FIVe3D does not by default support direct transformation matrix manipulation,
			 * 	and secondly it does not currently include 3D primitives like a cube, thirdly FIVe3D does not currently support Flash Player 10.
			 */	
		}
		
		public function getMesh(body:RigidBody):Sprite3D {
			return FIVe3DMesh(body.skin).mesh;
		}
		
		public function createCubeUsingExistingCube(cube:Cube):RigidBody
		{
			var jbox:JBox;		
		//	cube.onlyAllowMatrixModifications(); //this setups up the modified Sprite3D to support JigLibFlash matrix only modifications
			jbox = new JBox(new FIVe3DMesh(cube) as ISkin3D, cube.width, cube.depth, cube.height);		
			addBody(jbox);
			baseScene.addChild(cube);
			return jbox;
		}
		
		public function createCube(width:Number=500, depth:Number=500, height:Number=500,colors:Array=null,borderColor:uint=0x000000):RigidBody
		{
			var cube:Cube = new Cube(width,depth,height, colors,borderColor);
			return createCubeUsingExistingCube(cube);
		}
		
		public function createGround(width:Number,depth:Number, level:Number,color:uint,borderColor:uint=0xFF000000):RigidBody 
		{
			var jGround:JPlane;
			var ground:Sprite3D = new Sprite3D();
			//ground.singleSided = true;
			if (borderColor >>> 24 != 0xFF) { ground.graphics3D.lineStyle(1,borderColor);  }
			
			ground.graphics3D.beginFill(color);
			ground.graphics3D.drawRect(0, 0,width,depth);
			ground.graphics3D.endFill();
			ground.singleSided = true;
			//ground.onlyAllowMatrixModifications(); //this sets up the modified Sprite3D to support JigLibFlash matrix only modifications
			baseScene.addChild(ground);
			
			jGround = new JPlane(new FIVe3DMesh(ground) as ISkin3D);
			jGround.movable = false;
			
			//jGround.setOrientation(JMatrix3D.getRotationMatrixAxis(90));
			//		
			jGround.y = level;
			jGround.x = -width / 2;
			jGround.z = depth / 2;
		//	jGround.rotationY = 190;
	//		jGround.rotationZ = 270;
		jGround.rotationX = 90;
		//	jGround.rotationX = -90;
			//jGround.rotationX = 270;
			//ground.rotationX = ;
			
			addBody(jGround);

			return jGround;
		}
	}
}
