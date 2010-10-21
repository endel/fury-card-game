/*
   Copyright (c) 2007 Danny Chapman
   http://www.rowlhouse.co.uk

   This software is provided 'as-is', without any express or implied
   warranty. In no event will the authors be held liable for any damages
   arising from the use of this software.
   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:
   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
   3. This notice may not be removed or altered from any source
   distribution.
 */

/**
 * @author Muzer(muzerly@gmail.com)
 * @link http://code.google.com/p/jiglibflash
 */

package jiglib.collision
{


	import flash.geom.Vector3D;

	import jiglib.geometry.JSegment;
	import jiglib.math.*;
	import jiglib.physics.RigidBody;

	public class CollisionSystem
	{

		private var detectionFunctors:Array;
		private var collBody:Vector.<RigidBody>;

		public function CollisionSystem()
		{
			collBody = new Vector.<RigidBody>();
			detectionFunctors = [];
			detectionFunctors["BOX"] = [];
			detectionFunctors["BOX"]["BOX"] = new CollDetectBoxBox();
			detectionFunctors["BOX"]["SPHERE"] = new CollDetectSphereBox();
			detectionFunctors["BOX"]["CAPSULE"] = new CollDetectCapsuleBox();
			detectionFunctors["BOX"]["PLANE"] = new CollDetectBoxPlane();
			detectionFunctors["SPHERE"] = [];
			detectionFunctors["SPHERE"]["BOX"] = new CollDetectSphereBox();
			detectionFunctors["SPHERE"]["SPHERE"] = new CollDetectSphereSphere();
			detectionFunctors["SPHERE"]["CAPSULE"] = new CollDetectSphereCapsule();
			detectionFunctors["SPHERE"]["PLANE"] = new CollDetectSpherePlane();
			detectionFunctors["PLANE"] = [];
			detectionFunctors["PLANE"]["BOX"] = new CollDetectBoxPlane();
			detectionFunctors["PLANE"]["SPHERE"] = new CollDetectSpherePlane();
			detectionFunctors["PLANE"]["CAPSULE"] = new CollDetectCapsulePlane();
			detectionFunctors["CAPSULE"] = [];
			detectionFunctors["CAPSULE"]["CAPSULE"] = new CollDetectCapsuleCapsule();
			detectionFunctors["CAPSULE"]["BOX"] = new CollDetectCapsuleBox();
			detectionFunctors["CAPSULE"]["SPHERE"] = new CollDetectSphereCapsule();
			detectionFunctors["CAPSULE"]["PLANE"] = new CollDetectCapsulePlane();
		}

		public function addCollisionBody(body:RigidBody):void
		{
			if (!findBody(body))
			{
				collBody.push(body);
			}
		}

		public function removeCollisionBody(body:RigidBody):void
		{
			if (findBody(body))
			{
				collBody.splice(collBody.indexOf(body), 1);
			}
		}

		public function removeAllCollisionBodys():void
		{
			collBody = new Vector.<RigidBody>();
		}

		// Detects collisions between the body and all the registered collision bodies
		public function detectCollisions(body:RigidBody, collArr:Vector.<CollisionInfo>):void
		{
			if (!body.isActive)
			{
				return;
			}
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;

			for each (var _collBody:RigidBody in collBody)
			{
				if (body != _collBody && checkCollidables(body, _collBody) && detectionFunctors[body.type][_collBody.type] != undefined)
				{
					info = new CollDetectInfo();
					info.body0 = body;
					info.body1 = _collBody;
					fu = detectionFunctors[info.body0.type][info.body1.type];
					fu.collDetect(info, collArr);
				}
			}
		}

		// Detects collisions between the all bodies
		public function detectAllCollisions(bodies:Vector.<RigidBody>, collArr:Vector.<CollisionInfo>):void
		{
			var info:CollDetectInfo;
			var fu:CollDetectFunctor;
			var bodyID:int;
			var bodyType:String;
			
			for each (var _body:RigidBody in bodies)
			{
				bodyID = _body.id;
				bodyType = _body.type;
				for each (var _collBody:RigidBody in collBody)
				{
					if (_body == _collBody)
					{
						continue;
					}

					if (_collBody.isActive && bodyID > _collBody.id)
					{
						continue;
					}

					if (checkCollidables(_body, _collBody) && detectionFunctors[bodyType][_collBody.type] != undefined)
					{
						info = new CollDetectInfo();
						info.body0 = _body;
						info.body1 = _collBody;
						fu = detectionFunctors[info.body0.type][info.body1.type];
						fu.collDetect(info, collArr);
					}
				}
			}
		}

		public function segmentIntersect(out:Object, seg:JSegment, ownerBody:RigidBody):Boolean
		{
			out.fracOut = JNumber3D.NUM_HUGE;
			out.posOut = new Vector3D();
			out.normalOut = new Vector3D();

			var obj:Object = {};
			for each (var _collBody:RigidBody in collBody)
			{
				if (_collBody != ownerBody && segmentBounding(seg, _collBody))
				{
					if (_collBody.segmentIntersect(obj, seg, _collBody.currentState))
					{
						if (obj.fracOut < out.fracOut)
						{
							out.posOut = obj.posOut;
							out.normalOut = obj.normalOut;
							out.fracOut = obj.fracOut;
							out.bodyOut = _collBody;
						}
					}
				}
			}

			if (out.fracOut > 1)
			{
				return false;
			}
			if (out.fracOut < 0)
			{
				out.fracOut = 0;
			}
			else if (out.fracOut > 1)
			{
				out.fracOut = 1;
			}
			return true;
		}

		public function segmentBounding(seg:JSegment, obj:RigidBody):Boolean
		{
			var pos:Vector3D = seg.getPoint(0.5);
			var r:Number = seg.delta.length / 2;

			if (obj.type != "PLANE")
			{
				var num1:Number = pos.subtract(obj.currentState.position).length;
				var num2:Number = r + obj.boundingSphere;
				if (num1 <= num2)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return true;
			}
		}

		private function findBody(body:RigidBody):Boolean
		{
			for each (var _collBody:RigidBody in collBody)
			{
				if (body == _collBody)
				{
					return true;
				}
			}
			return false;
		}

		private function checkCollidables(body0:RigidBody, body1:RigidBody):Boolean
		{
			if (body0.nonCollidables.length == 0 && body1.nonCollidables.length == 0)
			{
				return true;
			}

			for each (var _body0:RigidBody in body0.nonCollidables)
			{
				if (body1 == _body0)
				{
					return false;
				}
			}
			for each (var _body1:RigidBody in body1.nonCollidables)
			{
				if (body0 == _body1)
				{
					return false;
				}
			}
			return true;
		}
	}

}
