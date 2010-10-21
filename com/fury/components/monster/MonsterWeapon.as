package com.fury.components.monster 
{
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.parsers.MD2;
	/**
	 * ...
	 * @author Legolas the Elf
	 */
	public class MonsterWeapon
	{
		
		private var _model:String;
		private var _texture:String;
		
		private var _md2:MD2;
		
		public function MonsterWeapon(model:String, texture:String) 
		{
			this._model = model;
			this._texture = texture;
		}
		
		public function loadMd2(path:String) : void
		{
			_md2 = new MD2(false);
			MonsterCard.loadMD2(_md2, path, _model, new BitmapFileMaterial(path + _texture) );
		}
		
		public function get model() : String
		{
			return _model;
		}
		
		public function get md2() : MD2
		{
			return _md2;
		}
		
		public function get texture() : String
		{
			return _texture;
		}
		
	}

}