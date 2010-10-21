package com.fury.components.monster
{
	
	import com.fury.components.card.EffectCard;
	import com.fury.core.events.BattleEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.controller.AnimationController;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.parsers.MD2;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.events.AnimationEvent;
	
	import com.fury.components.monster.*;
	
	import com.greensock.easing.Strong;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	
	import com.fury.core.SoundManager;
	
	/**
	 * Monster class
	 * @author Endel Dreyer
	 */
	public class Monster extends EventDispatcher
	{
		private var _name:String;
		
		private var _hp:Number;
		private var _maxhp:Number;
		
		private var _strenght:Number;
		private var _defense:Number;
		private var _fury:uint = 0;
		
		private var _modelList:Array;
		private var monsterModel:MD2;
		
		private var _id;
		private var _player:uint;
		
		private var _lifebar:MovieClip;
		private var _container:DisplayObject3D
		
		private var _enemy:Monster;
		private var _card:MonsterCard;
		
		private var _animations:AnimationController;
		private var _animationEndCallbacks:Array;
		
		private var _cardsAttached:Array;
		
		public function Monster(card:MonsterCard) 
		{
			this.setCard(card);
			
			this._container = new DisplayObject3D(this._id);
			
			this.monsterModel = _card.getModel();
			
			this._modelList = new Array();
			this.attachModel(this.monsterModel);
			
			this.setAnimation(MonsterAnimation.STAND);
			
			this._animationEndCallbacks = new Array();
			
			this._animations = monsterModel.animation;
			this._animations.addEventListener(AnimationEvent.COMPLETE, checkAnimationState);
		}
		
		private function setCard(c:MonsterCard)
		{
			this._card = c;
			this._name = c.name;
			this._maxhp =  c.hp;
			this._strenght = c.strenght;
			this._defense = c.defense;
			this._id = this._name + this._hp + this._strenght + this._defense + Math.random() * 1000;
		}
		
		private function attachModel(model:*)
		{
			if (_modelList[0])
			{
				// assign the initial tranform, if one model already exists
				model.transform = _modelList[0].transform;
				model.play( _modelList[0].animation.clipName );
			}
			
			_modelList.push( model );
			this._container.addChild( model );
		}
		
		private function checkAnimationState(e:AnimationEvent)
		{
			trace( "[checkAnimationState] Animation complete => '" + e.clip + "'");
			
			if (_animationEndCallbacks.length > 0) {
				
				// do custom things on animation complete
				var callback:Function = _animationEndCallbacks.pop();
				callback();
				
			} else {
				
				// do default things on animation complete
				
				switch (e.clip)
				{
					case MonsterAnimation.DEATH:
						
						// stops all model animations
						for (var i in _modelList)
						{
							_modelList[i].stop();
						}
						
					break;
					default:
						setAnimation(MonsterAnimation.STAND);
					break;
				}
			}
		}
		
		private function addOnAnimationCompleteCallback(c:Function)
		{
			_animationEndCallbacks.push( c );
		}
		
		public function onTurnBegin()
		{
			if (_enemy) 
			{
				for (var i in _modelList)
				{
					_modelList[i].lookAt( _enemy.model );
					_modelList[i].roll(90);
					_modelList[i].yaw(90);
				}
			}
		}
		
		public function onTurnEnd()
		{
			
		}
		
		public function equipWeapon()
		{
			if (_card.hasWeapons()) {
				this.attachModel(_card.getRandomWeapon());
			} else {
				trace("Oops, no weapon to equip on this monster.")
			}
		}
		
		public function updateMatrix(transformMatrix:Matrix3D) {
			// sometimes transformation matrix comes null, so... nothing to do
			if (transformMatrix == null) return;
			
			for (var i in _modelList)
			{
				_modelList[i].transform = transformMatrix;
				if (_enemy) {
					_modelList[i].lookAt( _enemy.model );
					_modelList[i].roll(90);
					_modelList[i].yaw(90);
				}
			}
		}
		
		public function setAnimation(name:String, loop:Boolean = true, onCompleteCallback:Function = null) {
			if (onCompleteCallback)
				addOnAnimationCompleteCallback(onCompleteCallback);
				
			trace("[setAnimation] " + this.name + " => '" + name + "' ");
			for (var i in _modelList)
			{
				_modelList[i].play(name, loop);
			}
		}
		
		public function attack(enemy:Monster, currentTurn)
		{
			setAnimation(MonsterAnimation.RUN);
			
			TweenLite.to( container, 2, {
				x: (currentTurn) ? "-100" : "+100",
				ease: Linear.easeNone,
				onComplete: function() {
					
					// attack animation
					setAnimation(MonsterAnimation.ATTACK, false, function() {
						
						setAnimation(MonsterAnimation.RUN);
						
						enemy.setAnimation(MonsterAnimation.PAIN, false);
						enemy.hp -= strenght;
						
						// return to initial position
						TweenLite.to(container, 1, {
							x: (!currentTurn) ? "-100" : "+100",
							ease: Strong.easeOut,
							onComplete: function() {
								
								// return to stand animations
								setAnimation(MonsterAnimation.STAND);
								
								// dispatch turn ended
								dispatchEvent( new BattleEvent(BattleEvent.TURN_ENDED, _card) );
							}
						})
					});
					
				}
			} );
		}
		
		public function setEnemy( enemy:Monster )
		{
			this._enemy = enemy;
		}
		
		public function attachEffectCard(c:EffectCard)
		{
			// TODO: attached card manager
			// dispatching events each turn passed and during other monster handlers
			_cardsAttached.push(c);
		}
		
		public function get model() : MD2
		{
			return monsterModel;
		}
		
		public function get container() : DisplayObject3D
		{
			return _container;
		}
		
		public function set lifebar(mc:MovieClip)
		{
			_lifebar = mc;
			hp = _maxhp;
		}
		public function get lifebar():MovieClip
		{
			return _lifebar;
		}
		
		public function set name(n:String)
		{
			_name = n;
		}
		
		public function get name(): String
		{
			return _name;
		}
		
		public function set hp(v:Number)
		{
			if (v > _maxhp) v = _maxhp;
			
			if (v <= 0) {
				v = 0;
				dispatchEvent(new MonsterEvent(MonsterEvent.MONSTER_DIED));
				this.setAnimation(MonsterAnimation.DEATH);
			}
			
			_hp = v;
			if (_lifebar) {
				_lifebar.hp.text = _hp;
				TweenLite.to(_lifebar.bar, 1, {
					y: (-_lifebar.bar.height) * (_hp / _maxhp),
					ease: Strong.easeOut
				} );
			}
		}
		
		public function get hp() : Number
		{
			return _hp;
		}
		
		public function set strenght(v:Number) 
		{
			_strenght = v;
		}
		
		public function get strenght() : Number
		{
			return _strenght;
		}
		
		public function set defense(v: Number)
		{
			_defense = v;
		}
		
		public function get defense(): Number
		{
			return _defense;
		}
		
		public function set player(p:uint)
		{
			_player = p;
		}
		
		public function get player() : uint
		{
			return _player;
		}
		
		public function set fury(f:uint)
		{
			if (f >= 3) {
				monsterModel.material = _card.getFuryMaterial();
				
				SoundManager.play("fury");
				
				f = 0;
				strenght += 2;
				defense += 1;
				hp = _maxhp;
			}
			_fury = f;
		}
		
		public function get fury() : uint
		{
			return _fury;
		}
		
		public function get id() {
			return _id;
		}
		
	}

}