package com.fury.components.card.definitions.monsters 
{
	import com.fury.components.monster.MonsterCard;
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class KnightCard extends MonsterCard
	{
		
		public function KnightCard() 
		{
			super("Knight", "resources/patterns/knight");
			path = "models/pknight/";
			
			hp = 16;
			strenght = 5;
			defense = 3;
			
			textures.setRandomList("ctf_b.jpg", "ctf_r.jpg", "knight.jpg");
			textures.setFury("evil.jpg");
			
			addWeapon("weapon.md2", "weapon.jpg");
			addWeapon("w_shotgun.md2", "w_shotgun.jpg");
			init();
		}
		
	}

}