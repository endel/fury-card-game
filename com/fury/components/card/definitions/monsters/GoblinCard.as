package com.fury.components.card.definitions.monsters 
{
	import com.fury.components.monster.MonsterCard;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class GoblinCard extends MonsterCard
	{
		
		public function GoblinCard() 
		{
			super("Goblin", "resources/patterns/goblin");
			path = "models/goblin/";
			
			hp = 20;
			strenght = 3;
			defense = 5;
			
			textures.setRandomList("goblin.jpg", "warrior.jpg");
			textures.setFury("fury.jpg");
			
			addWeapon("weapon.md2", "weapon.jpg");
			init();
		}
		
	}

}