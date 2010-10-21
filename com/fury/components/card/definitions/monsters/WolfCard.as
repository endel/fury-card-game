package com.fury.components.card.definitions.monsters
{
	import com.fury.components.monster.MonsterCard;
	
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class WolfCard extends MonsterCard
	{
		
		public function WolfCard() 
		{
			super("Wolf", "resources/patterns/wolf");
			addEventListener(MonsterCard.MODEL_LOADED, fixAnimationFrames);
			
			path = "models/awolf/";
			
			hp = 16;
			strenght = 8;
			defense = 6;
			
			textures.setRandomList("wolfskin.jpg", "wolfskin2.jpg");
			textures.setFury("fury.jpg");
			
			// load all models and definitions
			init();
		}
		
		private function fixAnimationFrames() : void
		{
			// add animations to _md2 var
			// _md2
		}
		
	}

}