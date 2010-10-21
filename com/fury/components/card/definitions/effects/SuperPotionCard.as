package com.fury.components.card.definitions.effects 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class SuperPotionCard extends EffectCard
	{
		
		public function SuperPotionCard() 
		{
			super("Super Potion", "resources/patterns/super-potion");
		}
		
		public override function bench( r:EffectCardResult=null) : EffectCardResult
		{
			_currentPlayer.hp += 4;
			return super.bench(r);
		}
		
	}

}