package com.fury.components.card.definitions.effects 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class FuuuCard extends  EffectCard
	{
		
		public function FuuuCard() 
		{
			super("Fuuuuuuuuuuuuu...", "resources/patterns/fuuu");
		}
		
		public override function bench( r:EffectCardResult=null) : EffectCardResult
		{
			_currentPlayer.hp -= Math.random() * _currentPlayer.hp / 2;
			_otherPlayer.hp -= Math.random() * _otherPlayer.hp / 2;
			return super.bench(r);
		}
		
	}

}