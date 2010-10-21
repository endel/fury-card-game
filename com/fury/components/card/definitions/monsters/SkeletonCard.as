package com.fury.components.card.definitions.monsters 
{
	import com.fury.components.monster.MonsterCard;
	
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class SkeletonCard extends MonsterCard
	{
		
		public function SkeletonCard() 
		{
			super("Skeleton", "resources/patterns/skeleton");
			path = "models/hueteotl/";
			
			hp = 20;
			strenght = 3;
			defense = 5;
			
			textures.setRandomList("blue.jpg", "red.jpg", "Hueteotl.jpg");
			textures.setFury("dark.jpg");
			
			addWeapon("WEAPON.MD2", "weapon.jpg");
			
			init();
		}
		
	}

}