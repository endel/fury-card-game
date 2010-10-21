package com.flarmanager.events 
{
	import flash.events.Event;
	import org.libspark.flartoolkit.core.types.matrix.FLARDoubleMatrix34;
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class FLAREvent extends Event 
	{
		public static var PATTERN_ADDED:String = "onPatternAdded";
		public static var PATTERN_REMOVED:String = "onPatternRemoved";
		public var patternId:uint;
		public var transformationMatrix:FLARDoubleMatrix34;
		
		public function FLAREvent(type:String, patternId:uint, transformationMatrix:FLARDoubleMatrix34, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.patternId = patternId;
			this.transformationMatrix = transformationMatrix;
		} 
		
		public override function clone():Event 
		{ 
			return new FLAREvent(type, patternId, transformationMatrix, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FLAREvent", "type", "patternId", "transformationMatrix", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}