package com.fury.components.card 
{
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class EffectCardResult
	{
		private var _canAttack:Boolean = true;
		
		public function set canAttack(c:Boolean)
		{
			_canAttack = c;
		}
		
		public function get canAttack() : Boolean
		{
			return _canAttack;
		}
		
	}

}