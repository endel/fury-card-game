package com.fury.core {
	
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * Out-game routines
	 * @author Endel Dreyer
	 */
    public class Fury extends Sprite
    {
		
		public static var battle:Battle;
		private var loadingAnimation:MovieClip;
		
		public function Fury()
        {
			this.addEventListener(Event.ADDED_TO_STAGE, loadGame);
		}
		
		private function loadGame(e:Event)
		{
			CardDefinition.prepareAllCards();
			this.loading.hide();
			startGame();
		}
		
		private function startGame()
		{
			battle = new Battle();
			addChild(battle);
		}
		
    }
}