package com.fury.views
{
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import com.fury.core.CardDefinition;
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class LoadingView extends MovieClip
	{
		
		public function LoadingView() 
		{
			
		}
		
		public function hide() : void
		{
			TweenLite.to(this, 1, {
				alpha: 0,
				onComplete: function() {
					this.parent.removeChild(this);
				}
			})
		}
		
	}

}