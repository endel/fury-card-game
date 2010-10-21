package com.fury.components.monster 
{
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class MonsterWeaponList
	{
		
		private var _weapons:Array;
		
		private var _path:String;
		
		public function MonsterWeaponList() 
		{
			_weapons = new Array();
		}
		
		public function addWeapon(model:String, texture:String)
		{
			_weapons.push( new MonsterWeapon(model, texture) );
		}
		
		public function getRandom() : MonsterWeapon
		{
			return _weapons[ Math.floor( Math.random() * _weapons.length ) ];
		}
		
		public function prepare() : void
		{
			for (var i in _weapons)
			{
				_weapons[i].loadMd2(_path);
			}
		}
		
		public function set path(p:String) : void
		{
			_path = p;
		}
		
		public function count() : Number
		{
			return _weapons.length;
		}
		
	}

}