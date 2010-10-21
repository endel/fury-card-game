package com.fury.components.monster
{
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class MonsterAnimation
	{
		
		public static const STAND:String = "stand";
		public static const RUN:String = "run"
		public static const ATTACK:String = "attack"
		public static const JUMP:String = "jump"
		
		private static const _DEATH:Array = ["death1", "death2", "death3"]
		private static const _PAIN:Array = ["pain1", "pain2", "pain3"]
		
		public static function get DEATH():String
		{
			return _DEATH[ Math.floor( Math.random() * _DEATH.length ) ];
		}
		
		public static function get PAIN():String
		{
			return _PAIN[ Math.floor( Math.random() * _PAIN.length ) ];
		}
		
	}

}