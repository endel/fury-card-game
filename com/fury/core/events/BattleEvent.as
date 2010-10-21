package com.fury.core.events 
{
	import com.fury.components.card.*;
	import flash.events.Event;
	import org.papervision3d.core.math.Matrix3D;
	
	/**
	 * BattleEvent
	 * @author Endel Dreyer
	 */
	public class BattleEvent extends Event 
	{
		public static const CARD_ADDED:String = "onCardAdded";
		public static const CARD_UPDATED:String = "onCardUpdated";
		public static const CARD_REMOVED:String = "onCardRemoved";
		
		public static const TURN_ENDED:String = "onTurnEnded";
		
		public var card:Card;
		public var transformationMatrix:Matrix3D;
		
		public function BattleEvent(type:String, card:Card, transformationMatrix:Matrix3D = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.card = card;
			this.transformationMatrix = transformationMatrix;
		} 
		
		public override function clone():Event 
		{
			return new BattleEvent(type, this.card, this.transformationMatrix, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("BattleEvent", "card", "transformationMatrix", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}