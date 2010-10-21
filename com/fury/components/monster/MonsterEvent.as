package com.fury.components.monster
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class MonsterEvent extends Event 
	{
		public static const MONSTER_DIED:String = "died";
		
		public function MonsterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new MonsterEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MonsterEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}