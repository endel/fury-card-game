package com.fury.components.monster
{
	import com.fury.components.card.*;
	import flash.events.Event;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.parsers.MD2;
	
	/**
	 * ...
	 * @author Endel Dreyer
	 */
	public class MonsterCard extends Card
	{
		public static const MODEL_LOADED:String = "onModelLoaded";
		
		protected var _modelFilename:String = "tris.md2";
		private var _path:String;
		
		private var _hp:Number;
		private var _strenght:Number;
		private var _defense:Number;
		
		// private var _animations;
		
		private var _textures:MonsterTextureList;
		private var _weapons:MonsterWeaponList;
		
		protected var _md2:MD2;
		
		public function MonsterCard(name:String, pattern:String) 
		{
			super(name, pattern, CardType.TYPE_MONSTER);
			_weapons = new MonsterWeaponList();
			_textures = new MonsterTextureList();
		}
		
		protected function init() : void
		{
			_textures.prepare();
			_weapons.prepare();
			
			_md2 = new MD2(false);
			loadMD2( _md2, _path, _modelFilename, _textures.getRandomMaterial() );
			dispatchEvent(new Event(MODEL_LOADED));
		}
		
		public static function loadMD2(md2Obj:MD2, basePath:String, modelFilename:String, material:BitmapFileMaterial) : void
		{
			md2Obj.load(basePath + modelFilename, material);
		}
		
		public function bench() {}
		public function onModelLoaded() { }
		
		public function set path(p:String)
		{
			_path = p;
			_textures.path = p;
			_weapons.path = p;
		}
		
		public function get textures() : MonsterTextureList
		{
			return _textures;
		}
		
		protected function addWeapon(model:String, texture:String)
		{
			_weapons.addWeapon(model, texture);
		}
		
		public function getModel() : MD2
		{
			return _md2;
		}
		
		public function getRandomWeapon() : MD2
		{
			return _weapons.getRandom().md2;
		}
		
		public function getFuryMaterial() : BitmapFileMaterial
		{
			return _textures.getMaterial("fury");
		}
		
		public function hasWeapons() : Boolean
		{
			return _weapons.count() > 0;
		}
		
		public function set hp(v:Number)
		{
			_hp = v;
		}
		
		public function get hp():Number
		{
			return _hp ;
		}
		
		public function set strenght(v:Number)
		{
			_strenght = v;
		}
		
		public function get strenght():Number
		{
			return _strenght;
		}
		
		public function set defense(v:Number)
		{
			_defense = v;
		}
		
		public function get defense():Number
		{
			return _defense;
		}
		
		public function get path() : String
		{
			return _path;
		}
		
	}

}