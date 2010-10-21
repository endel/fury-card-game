package com.fury.components.card.definitions.effects 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class FuryCard extends EffectCard
	{
		
		public function FuryCard() 
		{
			super("Fury", "resources/patterns/fury");
		}
		
		public override function bench( r:EffectCardResult=null) : EffectCardResult
		{
			_currentPlayer.fury += 3;
			return super.bench(r);
		}
		
	}

}