package com.fury.components.card
{
	import flash.events.EventDispatcher;
	/**
	 * Card class
	 * @author Endel Dreyer
	 */
	public class Card extends EventDispatcher
	{
		private var _name;
		private var _pattern;
		private var _type;
		
		public function Card(name:String, pattern:String, type:String) 
		{
			this._name = name;
			this._pattern = pattern;
			this._type = type;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get type():String
		{
			return this._type;
		}
		
		public function get pattern():String
		{
			return _pattern;
		}
		
	}

}