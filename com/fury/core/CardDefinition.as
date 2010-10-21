package com.fury.core 
{
	import com.fury.components.card.*;
	import com.fury.components.monster.*;
	import com.fury.components.card.definitions.monsters.*;
	import com.fury.components.card.definitions.effects.*;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.parsers.MD2;
	
	import flash.utils.Dictionary;
	
	/**
	 * Card static definitions
	 * @author Endel Dreyer
	 */
	public class CardDefinition
	{
		private static var cardList:Array;
		private static var modelList:Dictionary;
		
		public static function getByPatternId(patId:uint)
		{
			return cardList[patId];
		}
		
		public static function prepareAllCards() : void
		{
			if (cardList) return;
			
			cardList = new Array();
			cardList.push(
				// Monsters
				new WolfCard(),
				new GoblinCard(),
				new KnightCard(),
				new DemonessCard(),
				new SkeletonCard(),
				
				// Effects
				new AttackCard(),
				new CurseCard(),
				new DefendCard(),
				new FuryCard(),
				new FuuuCard(),
				new PoisonCard(),
				new PotionCard(),
				new SuperPotionCard(),
				new WeaponCard()
				
			);
		}
		
		public static function getList()
		{
			return cardList;
		}
		
	}

}