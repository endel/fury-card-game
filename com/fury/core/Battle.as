package com.fury.core 
{
	import com.fury.components.card.EffectCard;
	import com.fury.components.card.EffectCardResult;
	import com.fury.components.card.CardType;
	
	import com.fury.components.monster.Monster;
	import com.fury.components.monster.MonsterCard;
	import com.fury.components.monster.MonsterAnimation;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import com.fury.core.events.BattleEvent;
	import flash.events.Event;
	
	import com.flarmanager.FLARManager;
	
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	
	/**
	 * Main battle routines
	 * @author Endel Dreyer
	 */
	public class Battle extends Sprite
	{
		private var numPlayers:uint = 0;
		
		private var monsters:Array;
		
		private var manager:BattleManager;
		private var currentTurn:Boolean = false;
		
		// layout movieclips
		private var _logo:MovieClip;
		private var _topOutline:MovieClip;
		
		public function Battle() 
		{
			monsters = new Array();
			
			manager = new BattleManager(this, render);
			manager.addEventListener(BattleEvent.CARD_ADDED, onCardAdded);
			manager.addEventListener(BattleEvent.CARD_UPDATED, onCardUpdated);
			manager.addEventListener(BattleEvent.CARD_REMOVED, onCardRemoved);
			
			this.addEventListener(Event.ADDED_TO_STAGE, setupLayout);
		}
		
		private function setupLayout(e:Event)
		{
			_topOutline = new BattleTopOutline();
			_topOutline.x = (stage.stageWidth / 2) - _topOutline.width / 2;
			addChild(_topOutline);
			
			_logo = new Logo();
			_logo.y = -_logo.height;
			_logo.x = (stage.stageWidth / 2) - (_logo.width / 2)
			TweenLite.to(_logo, 1, {y: -50, ease: Strong.easeOut} );
			addChild(_logo);
		}
		
		private function addMonster(e:BattleEvent)
		{
			monsters[e.card.name] = new Monster( e.card as MonsterCard );
			monsters[e.card.name].player = currentPlayer;
			monsters[e.card.name].updateMatrix( e.transformationMatrix );
			Papervision3D.addChild( monsters[e.card.name] );
			
			monsters[e.card.name].lifebar = (numPlayers == 0) ? new LifebarLeft() : new LifebarRight();
			monsters[e.card.name].lifebar.y = 120;
			monsters[e.card.name].lifebar.x = (numPlayers == 0) ? -monsters[e.card.name].lifebar.width : stage.stageWidth;
			this.addChild(monsters[e.card.name].lifebar);
			
			TweenLite.to(monsters[e.card.name].lifebar, 1, { 
				x: (numPlayers == 0) ? -5 : stage.stageWidth - monsters[e.card.name].lifebar.width + 5,
				ease: Strong.easeOut
			} );
			
			// monster listeners
			monsters[e.card.name].addEventListener(BattleEvent.TURN_ENDED, onEndMonsterTurnHandler);
			
			// set monster references to each other
			var m1:Monster = getMonster(currentPlayer);
			var m2:Monster = getMonster(otherPlayer);
			if (m1 && m2)
			{
				m1.setEnemy(m2);
				m2.setEnemy(m1);
			}
			
			// add player
			numPlayers++;
		}
		
		private function onCardAdded(e:BattleEvent)
		{
			
			if (e.card.type == CardType.TYPE_MONSTER)
			{
				addMonster(e);
				switchTurn();
			} else 
			{
				var effectCard:EffectCard = (e.card as EffectCard).copy();
				effectCard.prepare(getMonster(currentPlayer), getMonster(otherPlayer), this);
				
				var effectResult:EffectCardResult = effectCard.bench();
				
				// check if effect card allow attack and switch turn
				switchTurn(effectResult);
			}
		}
		
		private function onCardUpdated(e:BattleEvent)
		{
			if (monsters[e.card.name]) monsters[e.card.name].updateMatrix( e.transformationMatrix );
		}
		
		private function onCardRemoved(e:BattleEvent)
		{
			
		}
		
		private function onTurnBegin()
		{
			getMonster(currentPlayer).onTurnBegin();
		}
		
		private function onTurnEnd()
		{
			getMonster(currentPlayer).onTurnEnd();
		}
		
		private function switchTurn(attack:Boolean = false )
		{
			if (!attack) return _switchTurn();
			
			var monster1:Monster = getMonster(currentPlayer);
			var monster2:Monster = getMonster(otherPlayer);
			
			if (!(monster1 && monster2)) 
			{
				switchTurn();
				return;
			}
			
			monster1.attack(monster2, currentTurn);
		}
		
		private function _switchTurn() {
			// attack, animations and switch user turn
			onTurnEnd();
			currentTurn = !currentTurn;
			onTurnBegin();
		}
		
		private function onEndMonsterTurnHandler(e:BattleEvent)
		{
			_switchTurn();
		}
		
		private function get currentPlayer():uint {
			return uint(currentTurn);
		}
		
		private function get otherPlayer():uint {
			return uint(!currentTurn);
		}
		
		private function getMonster(player:uint) : Monster
		{
			var playerMonster:Monster = null;
			for (var name in monsters)
			{
				if (monsters[name].player == player)
				{
					playerMonster = monsters[name];
					break;
				}
			}
			return playerMonster;
		}
		
		private function render(e:Event)
		{
			FLARManager.refresh();
			Papervision3D.render();
		}
	}

}