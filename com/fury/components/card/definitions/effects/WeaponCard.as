package com.fury.components.card.definitions.effects 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	import com.fury.components.monster.Monster;
	import com.fury.core.Battle;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class WeaponCard extends EffectCard
	{
		
		public function WeaponCard() 
		{
			super("Weapon", "resources/patterns/weapon");
		}
		
		public override function bench( r:EffectCardResult=null) : EffectCardResult
		{
			_currentPlayer.equipWeapon();
			return super.bench(r);
		}
		
	}

}