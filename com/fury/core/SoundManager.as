package com.fury.core 
{
	import flash.media.Sound;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class SoundManager
	{
		private static var _lib:Dictionary;
		
		public static function prepare() : void
		{
			_lib = new Dictionary(false);
			
			addSound("fury", new sndLionRoar());
		}
		
		private static function addSound(name:String, snd:Sound)
		{
			_lib[name] = snd;
		}
		
		public static function play(name:String)
		{
			if (!_lib) prepare();
			_lib[name].play();
		}
		
	}

}