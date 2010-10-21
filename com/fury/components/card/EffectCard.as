package com.fury.components.card
{
	import com.fury.components.card.*;
	import com.fury.components.monster.Monster;
	import com.fury.core.Battle;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class EffectCard extends Card
	{
		protected var _currentPlayer:Monster;
		protected var _otherPlayer:Monster;
		protected var _battle:Battle;
		
		protected var _result:EffectCardResult;
		
		public function EffectCard(name:String, pattern:String) 
		{
			super(name, pattern, CardType.TYPE_EFFECT);
		}
		
		public function prepare(currentPlayer:Monster, otherPlayer:Monster, battle:Battle)
		{
			_currentPlayer = currentPlayer;
			_otherPlayer = otherPlayer;
			_battle = battle;
		}
		
		public function bench(r:EffectCardResult = null) : EffectCardResult
		{
			if (!r)
			{
				r = new EffectCardResult();
				r.canAttack = true;
			}
			
			return r;
		}
		
		protected function attach(player:Monster)
		{
			player.attachEffectCard(this);
		}
		
		public function copy() : EffectCard
		{
			var className = getQualifiedClassName(this);
			var definition = getDefinitionByName(className) as Class;
			
			return new definition();
		}
		
	}

}