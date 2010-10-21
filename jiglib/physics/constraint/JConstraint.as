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

package jiglib.physics.constraint
{
	import jiglib.physics.PhysicsSystem;

	public class JConstraint
	{

		private var _satisfied:Boolean;
		private var _constraintEnabled:Boolean;

		public function JConstraint()
		{
			_constraintEnabled = false;
			enableConstraint();
		}

		public function set satisfied(s:Boolean):void
		{
			_satisfied = s;
		}

		public function get satisfied():Boolean
		{
			return _satisfied;
		}

		// prepare for applying constraints - the subsequent calls to
		// apply will all occur with a constant position i.e. precalculate
		// everything possible
		public function preApply(dt:Number):void
		{
			_satisfied = false;
		}

		// apply the constraint by adding impulses. Return value
		// indicates if any impulses were applied. If impulses were applied
		// the derived class should call SetConstraintsUnsatisfied() on each
		// body that is involved.
		public function apply(dt:Number):Boolean
		{
			return false;
		}

		// register with the physics system
		public function enableConstraint():void
		{
			if (_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = true;
			PhysicsSystem.getInstance().addConstraint(this);
		}

		// deregister from the physics system
		public function disableConstraint():void
		{
			if (!_constraintEnabled)
			{
				return;
			}
			_constraintEnabled = false;
			PhysicsSystem.getInstance().removeConstraint(this);
		}

		// are we registered with the physics system?
		public function get constraintEnabled():Boolean
		{
			return _constraintEnabled;
		}
	}

}
