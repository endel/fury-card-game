package com.fury.components.monster 
{
	import org.papervision3d.materials.BitmapFileMaterial;
	
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class MonsterTextureList
	{
		
		private var _list:Array;
		private var _fury:String;
		
		private var _path:String;
		
		private var _materials:Array;
		
		public function MonsterTextureList() 
		{
			
		}
		
		public function setRandomList(...list)
		{
			this._list = list;
		}
		
		public function setFury(fury)
		{
			this._fury = fury;
		}
		
		public function prepare() : void
		{
			_materials = new Array();
			for (var i in this._list)
			{
				_materials[i] = new BitmapFileMaterial(_path + this._list[i]);
			}
			_materials['fury'] = new BitmapFileMaterial(_path + _fury);
		}
		
		public function set path(p:String) : void
		{
			_path = p;
		}
		
		public function get random() : Number
		{
			return Math.floor( Math.random() * _list.length );
		}
		
		public function fury() : String
		{
			return _fury;
		}
		
		public function getMaterial(idx:*) : BitmapFileMaterial
		{
			return _materials[idx];
		}
		
		public function getRandomMaterial() : BitmapFileMaterial
		{
			return _materials[this.random];
		}
		
	}

}