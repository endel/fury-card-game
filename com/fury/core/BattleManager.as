package com.fury.core 
{
	
	import com.fury.components.card.Card;
	import com.fury.components.card.CardType;
	
	import com.flarmanager.FLARManager;
	import com.flarmanager.events.FLAREvent;
	import com.greensock.TimelineLite;
	import com.transmote.utils.time.FramerateDisplay;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import com.fury.core.events.BattleEvent;
	import com.fury.core.CardDefinition;
	
	
	/**
	 * In-game battle
	 * @author Endel Dreyer
	 */
	public class BattleManager extends Sprite
	{
		
		private var flarManager:FLARManager;
		
		private var benchCards:Array;
		private var container:*;
		private var unsetCardTimer:Timer;
		
		private var renderingCallback:Function;
		
		public function BattleManager(container, renderingCallback:Function) 
		{
			this.container = container;
			this.renderingCallback = renderingCallback;
			this.unsetCardTimer = new Timer(5000, 1);
			this.unsetCardTimer.addEventListener(TimerEvent.TIMER, unsetEffectCards);
			
			FLARManager.init("resources/camera_para.dat", CardDefinition.getList(), onFLARLoaded);
			FLARManager.addEventListener(FLAREvent.PATTERN_ADDED, handleSuposeCardAdded);
			FLARManager.addEventListener(FLAREvent.PATTERN_REMOVED, handleSuposeCardRemoved);
			benchCards = new Array();;
			
		}
		
		private function onFLARLoaded(webcamCapture, flarLayer)
		{
			this.container.addChild(webcamCapture);
			this.container.addChild(flarLayer);
			this.container.swapChildren( webcamCapture, this.container.getChildAt(0) );
			this.container.swapChildren( flarLayer, this.container.getChildAt(1) );
			Papervision3D.init(FLARManager.camera_parameters, this.container, this.renderingCallback);
		}
		
		
		private function handleSuposeCardAdded(e:BattleEvent)
		{
			if (benchCards[e.card.name]) {
				if (e.card.type == CardType.TYPE_MONSTER)
					dispatchEvent( new BattleEvent(BattleEvent.CARD_UPDATED, e.card, e.transformationMatrix) );
			} else {
				dispatchEvent( new BattleEvent(BattleEvent.CARD_ADDED, e.card, e.transformationMatrix) );
				benchCards[e.card.name] = e.card as Card;
				
				if (e.card.type == CardType.TYPE_EFFECT) {
					trace("'" + e.card.name + "' benched!");
					this.unsetCardTimer.start();
				}
			}
		}
		
		private function handleSuposeCardRemoved(e:BattleEvent)
		{
			if (e.card.type != CardType.TYPE_MONSTER)
			{
				benchCards[e.card.name] = null;
				dispatchEvent( new BattleEvent(BattleEvent.CARD_REMOVED, e.card, e.transformationMatrix) );
			}
		}
		
		private function unsetEffectCards(e:TimerEvent)
		{
			//trace("Tentando limpar cards de efeito...");
			for (var i in benchCards)
			{
				if (!benchCards[i]) continue;
				
				if (benchCards[i].type == CardType.TYPE_EFFECT) 
				{
					trace("[unsetEffectCards] '" + benchCards[i].name + "' removed.");
					benchCards[i] = null;
				}
			}
		}
		
	}

}