package com.fury.components.card.definitions.effects 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class PotionCard extends EffectCard
	{
		
		public function PotionCard() 
		{
			super("Potion", "resources/patterns/potion");
		}
		
		public override function bench( r:EffectCardResult=null) : EffectCardResult
		{
			_currentPlayer.hp += 2;
			return super.bench(r);
		}
		
	}

}