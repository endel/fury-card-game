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
 * @author Muzer(muzerly@gmail.com), speedok(speedok@gmail.com)
 * @link http://code.google.com/p/jiglibflash
 */


package jiglib.physics
{
	import flash.geom.Vector3D;
	
	import jiglib.cof.JConfig;
	import jiglib.collision.CollPointInfo;
	import jiglib.collision.CollisionInfo;
	import jiglib.collision.CollisionSystem;
	import jiglib.data.ContactData;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.constraint.JConstraint;

	public class PhysicsSystem
	{
		private static var _currentPhysicsSystem:PhysicsSystem;

		private const _maxVelMag:Number = 0.5;
		private const _minVelForProcessing:Number = 0.001;

		private var _bodies:Vector.<RigidBody>;
		private var _activeBodies:Vector.<RigidBody>;
		private var _collisions:Vector.<CollisionInfo>;
		private var _constraints:Vector.<JConstraint>;
		private var _controllers:Vector.<PhysicsController>;

		private var _gravityAxis:int;
		private var _gravity:Vector3D;

		private var _doingIntegration:Boolean;

		private var preProcessCollisionFn:Function;
		private var preProcessContactFn:Function;
		private var processCollisionFn:Function;
		private var processContactFn:Function;

		private var _cachedContacts:Vector.<ContactData>;
		private var _collisionSystem:CollisionSystem;


		public static function getInstance():PhysicsSystem
		{
			if (!_currentPhysicsSystem)
			{
				trace("version: JigLibFlash fp10 v0.34 (2009-11-21)");
				_currentPhysicsSystem = new PhysicsSystem();
			}
			return _currentPhysicsSystem;
		}

		public function PhysicsSystem()
		{
			setSolverType(JConfig.solverType);
			_doingIntegration = false;
			_bodies = new Vector.<RigidBody>();
			_collisions = new Vector.<CollisionInfo>();
			_activeBodies = new Vector.<RigidBody>();
			_constraints = new Vector.<JConstraint>();
			_controllers = new Vector.<PhysicsController>();

			_cachedContacts = new Vector.<ContactData>();
			_collisionSystem = new CollisionSystem();

			setGravity(JNumber3D.getScaleVector(JNumber3D.UP, -10));
		}

		private function getAllExternalForces(dt:Number):void
		{
			for each (var _body:RigidBody in _bodies)
			{
				_body.addExternalForces(dt);
			}

			for each (var _controller:PhysicsController in _controllers)
			{
				_controller.updateController(dt);
			}
		}

		public function getCollisionSystem():CollisionSystem
		{
			return _collisionSystem;
		}

		public function setGravity(gravity:Vector3D):void
		{
			_gravity = gravity;
			if (_gravity.x == _gravity.y && _gravity.y == _gravity.z)
			{
				_gravityAxis = -1;
			}
			_gravityAxis = 0;
			if (Math.abs(_gravity.y) > Math.abs(_gravity.z))
			{
				_gravityAxis = 1;
			}
			if (Math.abs(_gravity.z) > Math.abs(JNumber3D.toArray(_gravity)[_gravityAxis]))
			{
				_gravityAxis = 2;
			}
		}

		// global gravity acceleration
		public function get gravity():Vector3D
		{
			return _gravity;
		}

		public function get gravityAxis():int
		{
			return _gravityAxis;
		}

		public function get bodys():Vector.<RigidBody>
		{
			return _bodies;
		}

		// Add a rigid body to the simulation
		public function addBody(body:RigidBody):void
		{
			if (!findBody(body))
			{
				_bodies.push(body);
				_collisionSystem.addCollisionBody(body);
			}
		}

		public function removeBody(body:RigidBody):void
		{
			if (findBody(body))
			{
				_bodies.splice(_bodies.indexOf(body), 1);
				_collisionSystem.removeCollisionBody(body);
			}
		}

		public function removeAllBodys():void
		{
			_bodies = new Vector.<RigidBody>();
			_collisionSystem.removeAllCollisionBodys();
		}

		// Add a constraint to the simulation
		public function addConstraint(constraint:JConstraint):void
		{
			if (!findConstraint(constraint))
			{
				_constraints.push(constraint);
			}
		}

		public function removeConstraint(constraint:JConstraint):void
		{
			if (findConstraint(constraint))
			{
				_constraints.splice(_constraints.indexOf(constraint), 1);
			}
		}

		public function removeAllConstraints():void
		{
			_constraints = new Vector.<JConstraint>();
		}

		// Add a physics controlled to the simulation
		public function addController(controller:PhysicsController):void
		{
			if (!findController(controller))
			{
				_controllers.push(controller);
			}
		}

		public function removeController(controller:PhysicsController):void
		{
			if (findController(controller))
			{
				_controllers.splice(_controllers.indexOf(controller), 1);
			}
		}

		public function removeAllControllers():void
		{
			_controllers = new Vector.<CollisionInfo>();
		}

		public function setSolverType(type:String):void
		{
			switch (type)
			{
				case "FAST":
					preProcessCollisionFn = preProcessCollisionFast;
					preProcessContactFn = preProcessCollisionFast;
					processCollisionFn = processCollision;
					processContactFn = processCollision;
					return;
				case "NORMAL":
					preProcessCollisionFn = preProcessCollisionNormal;
					preProcessContactFn = preProcessCollisionNormal;
					processCollisionFn = processCollision;
					processContactFn = processCollision;
					return;
				case "ACCUMULATED":
					preProcessCollisionFn = preProcessCollisionNormal;
					preProcessContactFn = preProcessCollisionAccumulated;
					processCollisionFn = processCollision;
					processContactFn = processCollisionAccumulated;
					return;
				default:
					preProcessCollisionFn = preProcessCollisionNormal;
					preProcessContactFn = preProcessCollisionNormal;
					processCollisionFn = processCollision;
					processContactFn = processCollision;
					return;
			}
		}

		private function findBody(body:RigidBody):Boolean
		{
			for each (var _body:RigidBody in _bodies)
			{
				if (body == _body)
				{
					return true;
				}
			}
			return false;
		}

		private function findConstraint(constraint:JConstraint):Boolean
		{
			for each (var _constraint:JConstraint in _constraints)
			{
				if (constraint == _constraint)
				{
					return true;
				}
			}
			return false;
		}

		private function findController(controller:PhysicsController):Boolean
		{
			for each (var _controller:PhysicsController in _controllers)
			{
				if (controller == _controller)
				{
					return true;
				}
			}
			return false;
		}

		// fast-but-inaccurate pre-processor
		private function preProcessCollisionFast(collision:CollisionInfo, dt:Number):void
		{
			collision.satisfied = false;

			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;

			var N:Vector3D = collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;
			var approachScale:Number = 0;
			var ptInfo:CollPointInfo;
			var tempV:Vector3D;
			var ptNum:int = collision.pointInfo.length;

			if (ptNum > 1)
			{
				var avR0:Vector3D = new Vector3D();
				var avR1:Vector3D = new Vector3D();
				var avDepth:Number = 0;

				for (var i:int = 0; i < ptNum; i++)
				{
					ptInfo = collision.pointInfo[i];
					avR0 = avR0.add(ptInfo.r0);
					avR1 = avR1.add(ptInfo.r1);
					avDepth += ptInfo.initialPenetration;
				}
				avR0 = JNumber3D.getDivideVector(avR0, Number(ptNum));
				avR1 = JNumber3D.getDivideVector(avR1, Number(ptNum));
				avDepth /= ptNum;

				collision.pointInfo = new Vector.<CollPointInfo>();
				collision.pointInfo[0] = new CollPointInfo();
				collision.pointInfo[0].r0 = avR0;
				collision.pointInfo[0].r1 = avR1;
				collision.pointInfo[0].initialPenetration = avDepth;
			}

			var len:int = collision.pointInfo.length;
			for (i = 0; i < len; i++)
			{
				ptInfo = collision.pointInfo[i];
				if (!body0.movable)
				{
					ptInfo.denominator = 0;
				}
				else
				{
					tempV = ptInfo.r0.crossProduct(N);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r0));
				}
				if (body1.movable)
				{
					tempV = ptInfo.r1.crossProduct(N);
					JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
					ptInfo.denominator += (body1.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r1)));
				}
				if (ptInfo.denominator < JNumber3D.NUM_TINY)
				{
					ptInfo.denominator = JNumber3D.NUM_TINY;
				}

				if (ptInfo.initialPenetration > JConfig.allowedPenetration)
				{
					ptInfo.minSeparationVel = (ptInfo.initialPenetration - JConfig.allowedPenetration) / timescale;
				}
				else
				{
					approachScale = -0.1 * (ptInfo.initialPenetration - JConfig.allowedPenetration) / JConfig.allowedPenetration;
					if (approachScale < JNumber3D.NUM_TINY)
					{
						approachScale = JNumber3D.NUM_TINY;
					}
					else if (approachScale > 1)
					{
						approachScale = 1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - JConfig.allowedPenetration) / Math.max(dt, JNumber3D.NUM_TINY);
				}
				if (ptInfo.minSeparationVel > _maxVelMag)
				{
					ptInfo.minSeparationVel = _maxVelMag;
				}
			}
		}

		// Special pre-processor for the normal solver
		private function preProcessCollisionNormal(collision:CollisionInfo, dt:Number):void
		{
			collision.satisfied = false;

			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;

			var N:Vector3D = collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;
			var approachScale:Number = 0;
			var ptInfo:CollPointInfo;
			var tempV:Vector3D;
			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++)
			{
				ptInfo = collision.pointInfo[i];
				if (!body0.movable)
				{
					ptInfo.denominator = 0;
				}
				else
				{
					tempV = ptInfo.r0.crossProduct(N);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r0));
				}

				if (body1.movable)
				{
					tempV = ptInfo.r1.crossProduct(N);
					JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
					ptInfo.denominator += (body1.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r1)));
				}
				if (ptInfo.denominator < JNumber3D.NUM_TINY)
				{
					ptInfo.denominator = JNumber3D.NUM_TINY;
				}
				if (ptInfo.initialPenetration > JConfig.allowedPenetration)
				{
					ptInfo.minSeparationVel = (ptInfo.initialPenetration - JConfig.allowedPenetration) / timescale;
				}
				else
				{
					approachScale = -0.1 * (ptInfo.initialPenetration - JConfig.allowedPenetration) / JConfig.allowedPenetration;
					if (approachScale < JNumber3D.NUM_TINY)
					{
						approachScale = JNumber3D.NUM_TINY;
					}
					else if (approachScale > 1)
					{
						approachScale = 1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - JConfig.allowedPenetration) / Math.max(dt, JNumber3D.NUM_TINY);
				}
				if (ptInfo.minSeparationVel > _maxVelMag)
				{
					ptInfo.minSeparationVel = _maxVelMag;
				}
			}

		}

		// Special pre-processor for the accumulated solver
		private function preProcessCollisionAccumulated(collision:CollisionInfo, dt:Number):void
		{
			collision.satisfied = false;
			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;

			var N:Vector3D = collision.dirToBody;
			var timescale:Number = JConfig.numPenetrationRelaxationTimesteps * dt;

			var tempV:Vector3D;
			var ptInfo:CollPointInfo;
			var approachScale:Number = 0;
			var numTiny:Number = JNumber3D.NUM_TINY;
			var allowedPenetration:Number = JConfig.allowedPenetration;
			

			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++)
			{
				ptInfo = collision.pointInfo[i];
				if (!body0.movable)
				{
					ptInfo.denominator = 0;
				}
				else
				{
					tempV = ptInfo.r0.crossProduct(N);
					JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
					ptInfo.denominator = body0.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r0));
				}

				if (body1.movable)
				{
					tempV = ptInfo.r1.crossProduct(N);
					JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
					ptInfo.denominator += (body1.invMass + N.dotProduct(tempV.crossProduct(ptInfo.r1)));
				}
				if (ptInfo.denominator < numTiny)
				{
					ptInfo.denominator = numTiny;
				}
				if (ptInfo.initialPenetration > allowedPenetration)
				{
					ptInfo.minSeparationVel = (ptInfo.initialPenetration -allowedPenetration) / timescale;
				}
				else
				{
					approachScale = -0.1 * (ptInfo.initialPenetration - allowedPenetration) / allowedPenetration;
					if (approachScale < numTiny)
					{
						approachScale = numTiny;
					}
					else if (approachScale > 1)
					{
						approachScale = 1;
					}
					ptInfo.minSeparationVel = approachScale * (ptInfo.initialPenetration - allowedPenetration) / Math.max(dt, numTiny);
				}

				ptInfo.accumulatedNormalImpulse = 0;
				ptInfo.accumulatedNormalImpulseAux = 0;
				ptInfo.accumulatedFrictionImpulse = new Vector3D();

				var bestDistSq:Number = 0.04;
				var bp:BodyPair = new BodyPair(body0, body1, new Vector3D(), new Vector3D());

				for each (var _cachedContact:ContactData in _cachedContacts)
				{
					if (!(bp.body0 == _cachedContact.pair.body0 && bp.body1 == _cachedContact.pair.body1))
					{
						continue;
					}
					var distSq:Number = (_cachedContact.pair.body0 == body0) ? _cachedContact.pair.r.subtract(ptInfo.r0).lengthSquared : _cachedContact.pair.r.subtract(ptInfo.r1).lengthSquared;

					if (distSq < bestDistSq)
					{
						bestDistSq = distSq;
						ptInfo.accumulatedNormalImpulse = _cachedContact.impulse.normalImpulse;
						ptInfo.accumulatedNormalImpulseAux = _cachedContact.impulse.normalImpulseAux;
						ptInfo.accumulatedFrictionImpulse = _cachedContact.impulse.frictionImpulse;
						if (_cachedContact.pair.body0 != body0)
						{
							ptInfo.accumulatedFrictionImpulse = JNumber3D.getScaleVector(ptInfo.accumulatedFrictionImpulse, -1);
						}
					}
				}

				if (ptInfo.accumulatedNormalImpulse != 0)
				{
					var impulse:Vector3D = JNumber3D.getScaleVector(N, ptInfo.accumulatedNormalImpulse);
					impulse = impulse.add(ptInfo.accumulatedFrictionImpulse);
					body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
					body1.applyBodyWorldImpulse(JNumber3D.getScaleVector(impulse, -1), ptInfo.r1);
				}
				if (ptInfo.accumulatedNormalImpulseAux != 0)
				{
					impulse = JNumber3D.getScaleVector(N, ptInfo.accumulatedNormalImpulseAux);
					body0.applyBodyWorldImpulseAux(impulse, ptInfo.r0);
					body1.applyBodyWorldImpulseAux(JNumber3D.getScaleVector(impulse, -1), ptInfo.r1);
				}
			}
		}

		/* Handle an individual collision by classifying it, calculating
		 impulse, applying impulse and updating the velocities of the
		 objects. Allows over-riding of the elasticity. Ret val indicates
		 if an impulse was applied
		*/
		private function processCollision(collision:CollisionInfo, dt:Number):Boolean
		{
			collision.satisfied = true;

			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;

			var gotOne:Boolean = false;
			var N:Vector3D = collision.dirToBody;

			var deltaVel:Number = 0;
			var normalVel:Number = 0;
			var finalNormalVel:Number = 0;
			var normalImpulse:Number = 0;
			var impulse:Vector3D;
			var Vr0:Vector3D;
			var Vr1:Vector3D;
			var ptInfo:CollPointInfo;

			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++)
			{
				ptInfo = collision.pointInfo[i];

				Vr0 = body0.getVelocity(ptInfo.r0);
				Vr1 = body1.getVelocity(ptInfo.r1);
				normalVel = Vr0.subtract(Vr1).dotProduct(N);
				if (normalVel > ptInfo.minSeparationVel)
				{
					continue;
				}
				finalNormalVel = -1 * collision.mat.restitution * normalVel;
				if (finalNormalVel < _minVelForProcessing)
				{
					finalNormalVel = ptInfo.minSeparationVel;
				}
				deltaVel = finalNormalVel - normalVel;
				if (deltaVel <= _minVelForProcessing)
				{
					continue;
				}
				normalImpulse = deltaVel / ptInfo.denominator;

				gotOne = true;
				impulse = JNumber3D.getScaleVector(N, normalImpulse);

				body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
				body1.applyBodyWorldImpulse(JNumber3D.getScaleVector(impulse, -1), ptInfo.r1);

				var tempV:Vector3D;
				var VR:Vector3D = Vr0.subtract(Vr1);
				var tangent_vel:Vector3D = VR.subtract(JNumber3D.getScaleVector(N, VR.dotProduct(N)));
				var tangent_speed:Number = tangent_vel.length;

				if (tangent_speed > _minVelForProcessing)
				{
					var T:Vector3D = JNumber3D.getScaleVector(JNumber3D.getDivideVector(tangent_vel, tangent_speed), -1);
					var denominator:Number = 0;

					if (body0.movable)
					{
						tempV = ptInfo.r0.crossProduct(T);
						JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
						denominator = body0.invMass + T.dotProduct(tempV.crossProduct(ptInfo.r0));
					}

					if (body1.movable)
					{
						tempV = ptInfo.r1.crossProduct(T);
						JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
						denominator += (body1.invMass + T.dotProduct(tempV.crossProduct(ptInfo.r1)));
					}

					if (denominator > JNumber3D.NUM_TINY)
					{
						var impulseToReverse:Number = Math.pow(collision.mat.friction, 3) * tangent_speed / denominator;

						T = JNumber3D.getScaleVector(T, impulseToReverse);
						body0.applyBodyWorldImpulse(T, ptInfo.r0);
						body1.applyBodyWorldImpulse(JNumber3D.getScaleVector(T, -1), ptInfo.r1);
					}
				}
			}

			if (gotOne)
			{
				body0.setConstraintsAndCollisionsUnsatisfied();
				body1.setConstraintsAndCollisionsUnsatisfied();
			}
			return gotOne;
		}

		// Accumulated and clamp impulses
		private function processCollisionAccumulated(collision:CollisionInfo, dt:Number):Boolean
		{
			collision.satisfied = true;
			var gotOne:Boolean = false;
			var N:Vector3D = collision.dirToBody;
			var body0:RigidBody = collision.objInfo.body0;
			var body1:RigidBody = collision.objInfo.body1;

			var deltaVel:Number = 0;
			var normalVel:Number = 0;
			var normalImpulse:Number = 0;
			var impulse:Vector3D;
			var Vr0:Vector3D;
			var Vr1:Vector3D;
			var ptInfo:CollPointInfo;

			var len:int = collision.pointInfo.length;
			for (var i:int = 0; i < len; i++)
			{
				ptInfo = collision.pointInfo[i];

				Vr0 = body0.getVelocity(ptInfo.r0);
				Vr1 = body1.getVelocity(ptInfo.r1);
				normalVel = Vr0.subtract(Vr1).dotProduct(N);

				deltaVel = -normalVel;
				if (ptInfo.minSeparationVel < 0)
				{
					deltaVel += ptInfo.minSeparationVel;
				}

				if (Math.abs(deltaVel) > _minVelForProcessing)
				{
					normalImpulse = deltaVel / ptInfo.denominator;
					var origAccumulatedNormalImpulse:Number = ptInfo.accumulatedNormalImpulse;
					ptInfo.accumulatedNormalImpulse = Math.max(ptInfo.accumulatedNormalImpulse + normalImpulse, 0);
					var actualImpulse:Number = ptInfo.accumulatedNormalImpulse - origAccumulatedNormalImpulse;

					impulse = JNumber3D.getScaleVector(N, actualImpulse);
					body0.applyBodyWorldImpulse(impulse, ptInfo.r0);
					body1.applyBodyWorldImpulse(JNumber3D.getScaleVector(impulse, -1), ptInfo.r1);

					gotOne = true;
				}

				Vr0 = body0.getVelocityAux(ptInfo.r0);
				Vr1 = body1.getVelocityAux(ptInfo.r1);
				normalVel = Vr0.subtract(Vr1).dotProduct(N);

				deltaVel = -normalVel;
				if (ptInfo.minSeparationVel > 0)
				{
					deltaVel += ptInfo.minSeparationVel;
				}
				if (Math.abs(deltaVel) > _minVelForProcessing)
				{
					normalImpulse = deltaVel / ptInfo.denominator;
					origAccumulatedNormalImpulse = ptInfo.accumulatedNormalImpulseAux;
					ptInfo.accumulatedNormalImpulseAux = Math.max(ptInfo.accumulatedNormalImpulseAux + normalImpulse, 0);
					actualImpulse = ptInfo.accumulatedNormalImpulseAux - origAccumulatedNormalImpulse;

					impulse = JNumber3D.getScaleVector(N, actualImpulse);
					body0.applyBodyWorldImpulseAux(impulse, ptInfo.r0);
					body1.applyBodyWorldImpulseAux(JNumber3D.getScaleVector(impulse, -1), ptInfo.r1);

					gotOne = true;
				}


				if (ptInfo.accumulatedNormalImpulse > 0)
				{
					Vr0 = body0.getVelocity(ptInfo.r0);
					Vr1 = body1.getVelocity(ptInfo.r1);
					var tempV:Vector3D;
					var VR:Vector3D = Vr0.subtract(Vr1);
					var tangent_vel:Vector3D = VR.subtract(JNumber3D.getScaleVector(N, VR.dotProduct(N)));
					var tangent_speed:Number = tangent_vel.length;
					if (tangent_speed > _minVelForProcessing)
					{

						var T:Vector3D = JNumber3D.getScaleVector(JNumber3D.getDivideVector(tangent_vel, tangent_speed), -1);
						var denominator:Number = 0;
						if (body0.movable)
						{
							tempV = ptInfo.r0.crossProduct(T);
							JMatrix3D.multiplyVector(body0.worldInvInertia, tempV);
							denominator = body0.invMass + T.dotProduct(tempV.crossProduct(ptInfo.r0));
						}
						if (body1.movable)
						{
							tempV = ptInfo.r1.crossProduct(T);
							JMatrix3D.multiplyVector(body1.worldInvInertia, tempV);
							denominator += (body1.invMass + T.dotProduct(tempV.crossProduct(ptInfo.r1)));
						}
						if (denominator > JNumber3D.NUM_TINY)
						{
							var impulseToReverse:Number = tangent_speed / denominator;
							var frictionImpulseVec:Vector3D = JNumber3D.getScaleVector(T, impulseToReverse);

							var origAccumulatedFrictionImpulse:Vector3D = ptInfo.accumulatedFrictionImpulse.clone();
							ptInfo.accumulatedFrictionImpulse = ptInfo.accumulatedFrictionImpulse.add(frictionImpulseVec);

							var AFIMag:Number = ptInfo.accumulatedFrictionImpulse.length;
							var maxAllowedAFIMag:Number = collision.mat.friction * ptInfo.accumulatedNormalImpulse;

							if (AFIMag > JNumber3D.NUM_TINY && AFIMag > maxAllowedAFIMag)
							{
								ptInfo.accumulatedFrictionImpulse = JNumber3D.getScaleVector(ptInfo.accumulatedFrictionImpulse, maxAllowedAFIMag / AFIMag);
							}

							var actualFrictionImpulse:Vector3D = ptInfo.accumulatedFrictionImpulse.subtract(origAccumulatedFrictionImpulse);

							body0.applyBodyWorldImpulse(actualFrictionImpulse, ptInfo.r0);
							body1.applyBodyWorldImpulse(JNumber3D.getScaleVector(actualFrictionImpulse, -1), ptInfo.r1);
						}
					}
				}
			}
			if (gotOne)
			{
				body0.setConstraintsAndCollisionsUnsatisfied();
				body1.setConstraintsAndCollisionsUnsatisfied();
			}
			return gotOne;
		}

		private function updateContactCache():void
		{
			_cachedContacts = new Vector.<ContactData>();
			var ptInfo:CollPointInfo;
			var fricImpulse:Vector3D;
			var contact:Object;
			for each (var collInfo:CollisionInfo in _collisions)
			{
				for (var j:String in collInfo.pointInfo)
				{
					ptInfo = collInfo.pointInfo[j];
					fricImpulse = (collInfo.objInfo.body0.id > collInfo.objInfo.body1.id) ? ptInfo.accumulatedFrictionImpulse : JNumber3D.getScaleVector(ptInfo.accumulatedFrictionImpulse, -1);

					contact = new ContactData();
					contact.pair = new BodyPair(collInfo.objInfo.body0, collInfo.objInfo.body1, ptInfo.r0, ptInfo.r1);
					contact.impulse = new CachedImpulse(ptInfo.accumulatedNormalImpulse, ptInfo.accumulatedNormalImpulseAux, ptInfo.accumulatedFrictionImpulse);

					_cachedContacts.push(contact);
				}
			}
		}

		private function handleAllConstraints(dt:Number, iter:int, forceInelastic:Boolean):void
		{
			var origNumCollisions:int = _collisions.length;
			var collInfo:CollisionInfo;
			var _constraint:JConstraint;

			for each (_constraint in _constraints)
			{
				_constraint.preApply(dt);
			}

			if (forceInelastic)
			{
				for each (collInfo in _collisions)
				{
					preProcessContactFn(collInfo, dt);
					collInfo.mat.restitution = 0;
					collInfo.satisfied = false;
				}
			}
			else
			{
				for each (collInfo in _collisions)
				{
					preProcessCollisionFn(collInfo, dt);
				}
			}

			var flag:Boolean;
			var gotOne:Boolean;
			var len:int;
			for (var step:uint = 0; step < iter; step++)
			{
				gotOne = false;
				for each (collInfo in _collisions)
				{
					if (!collInfo.satisfied)
					{
						if (forceInelastic)
						{
							flag = processContactFn(collInfo, dt);
							gotOne = gotOne || flag;
						}
						else
						{
							flag = processCollisionFn(collInfo, dt);
							gotOne = gotOne || flag;
						}
					}
				}
				for each (_constraint in _constraints)
				{
					if (!_constraint.satisfied)
					{
						flag = _constraint.apply(dt);
						gotOne = gotOne || flag;
					}
				}
				tryToActivateAllFrozenObjects();

				if (forceInelastic)
				{
					len = _collisions.length;
					for (var j:int = origNumCollisions; j < len; j++)
					{
						_collisions[j].mat.restitution = 0;
						_collisions[j].satisfied = false;
						preProcessContactFn(_collisions[j], dt);
					}
				}
				else
				{
					len = _collisions.length;
					for (j = origNumCollisions; j < len; j++)
					{
						preProcessCollisionFn(_collisions[j], dt);
					}
				}
				origNumCollisions = _collisions.length;
				if (!gotOne)
				{
					break;
				}
			}
		}

		public function activateObject(body:RigidBody):void
		{
			if (!body.movable || body.isActive)
			{
				return;
			}
			body.setActive();
			_activeBodies.push(body);
			var orig_num:int = _collisions.length;
			_collisionSystem.detectCollisions(body, _collisions);
			var other_body:RigidBody;
			var thisBody_normal:Vector3D;
			var len:int = _collisions.length;
			for (var i:int = orig_num; i < len; i++)
			{
				other_body = _collisions[i].objInfo.body0;
				thisBody_normal = _collisions[i].dirToBody;
				if (other_body == body)
				{
					other_body = _collisions[i].objInfo.body1;
					thisBody_normal = JNumber3D.getScaleVector(_collisions[i].dirToBody, -1);
				}
				if (!other_body.isActive && other_body.force.dotProduct(thisBody_normal) < -JNumber3D.NUM_TINY)
				{
					activateObject(other_body);
				}
			}
		}

		private function dampAllActiveBodies():void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
			{
				_activeBody.dampForDeactivation();
			}
		}

		private function tryToActivateAllFrozenObjects():void
		{
			for each (var _body:RigidBody in _bodies)
			{
				if (!_body.isActive)
				{
					if (_body.getShouldBeActive())
					{
						activateObject(_body);
					}
					else
					{
						if (_body.getVelChanged())
						{
							_body.setVelocity(new Vector3D());
							_body.setAngVel(new Vector3D());
							_body.clearVelChanged();
						}
					}
				}
			}
		}

		private function activateAllFrozenObjectsLeftHanging():void
		{
			var other_body:RigidBody;
			for each (var _body:RigidBody in _bodies)
			{
				if (_body.isActive)
				{
					_body.doMovementActivations();
					if (_body.collisions.length > 0)
					{
						for (var j:String in _body.collisions)
						{
							other_body = _body.collisions[j].objInfo.body0;
							if (other_body == _body)
							{
								other_body = _body.collisions[j].objInfo.body1;
							}

							if (!other_body.isActive)
							{
								_body.addMovementActivation(_body.currentState.position, other_body);
							}
						}
					}
				}
			}
		}

		private function updateAllVelocities(dt:Number):void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
			{
				_activeBody.updateVelocity(dt);
			}
		}

		private function updateAllPositions(dt:Number):void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
			{
				_activeBody.updatePositionWithAux(dt);
			}
		}

		private function notifyAllPostPhysics(dt:Number):void
		{
			for each (var _body:RigidBody in _bodies)
			{
				_body.postPhysics(dt);
			}
		}

		private function updateAllObject3D():void
		{
			for each (var _body:RigidBody in _bodies)
			{
				_body.updateObject3D();
			}
		}

		private function limitAllVelocities():void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
			{
				_activeBody.limitVel();
				_activeBody.limitAngVel();
			}
		}

		private function tryToFreezeAllObjects(dt:Number):void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
			{
				_activeBody.tryToFreeze(dt);
			}
		}

		private function detectAllCollisions(dt:Number):void
		{
			for each (var _activeBody:RigidBody in _activeBodies)
				_activeBody.storeState();

			updateAllVelocities(dt);
			updateAllPositions(dt);

			for each (var _body:RigidBody in _bodies)
				_body.collisions = new Vector.<CollisionInfo>();

			_collisions = new Vector.<CollisionInfo>();
			_collisionSystem.detectAllCollisions(_activeBodies, _collisions);

			for each (_activeBody in _activeBodies)
				_activeBody.restoreState();
		}

		private function copyAllCurrentStatesToOld():void
		{
			for each (var _body:RigidBody in _bodies)
			{
				if (_body.isActive || _body.getVelChanged())
				{
					_body.copyCurrentStateToOld();
				}
			}
		}

		private function findAllActiveBodies():void
		{
			_activeBodies = new Vector.<RigidBody>();
		
			for each (var _body:RigidBody in _bodies)
			{
				if (_body.isActive)
				{
					_activeBodies.push(_body);
				}
			}
		}

		// Integrates the system forwards by dt - the caller is
		// responsible for making sure that repeated calls to this use
		// the same dt (if desired)
		public function integrate(dt:Number):void
		{
			_doingIntegration = true;

			findAllActiveBodies();
			copyAllCurrentStatesToOld();

			getAllExternalForces(dt);
			detectAllCollisions(dt);
			handleAllConstraints(dt, JConfig.numCollisionIterations, false);
			updateAllVelocities(dt);
			handleAllConstraints(dt, JConfig.numContactIterations, true);

			dampAllActiveBodies();
			tryToFreezeAllObjects(dt);
			activateAllFrozenObjectsLeftHanging();

			limitAllVelocities();

			updateAllPositions(dt);
			notifyAllPostPhysics(dt);

			updateAllObject3D();
			if (JConfig.solverType == "ACCUMULATED")
			{
				updateContactCache();
			}
			for each (var _body:RigidBody in _bodies)
			{
				_body.clearForces();
			}

			_doingIntegration = false;
		}
	}
}
