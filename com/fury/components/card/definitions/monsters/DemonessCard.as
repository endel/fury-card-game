package com.fury.components.card.definitions.monsters 
{
	import com.fury.components.monster.MonsterCard;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class DemonessCard extends MonsterCard
	{
		
		public function DemonessCard() 
		{
			super("Demoness", "resources/patterns/demoness");
			path = "models/demoness/";
			
			hp = 20;
			strenght = 3;
			defense = 5;
			
			textures.setRandomList("blue.jpg", "red.jpg", "yellow.jpg", "ghost.jpg", "green.jpg", "ice.jpg", "necromancer.jpg", "siege-gold.jpg", "siege-silver.jpg");
			textures.setFury("succubus.jpg");
			
			addWeapon("firemace.md2", "firemace.jpg");
			addWeapon("icemace.md2", "icestaff.jpg");
			addWeapon("w_bfg.md2", "w_bfg.jpg");
			addWeapon("w_glauncher.md2", "w_glauncher.jpg");
			
			init();
		}
		
	}

}