package org.papervision3d.core.controller 
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import org.papervision3d.core.animation.IAnimatable;
	import org.papervision3d.core.animation.channel.Channel3D;
	import org.papervision3d.core.animation.clip.AnimationClip3D;
	import org.papervision3d.events.AnimationEvent;
	
	/**
	 * The AnimationController class controls an animation.
	 * 
	 * @author Tim Knip / floorplanner.com
	 */
	public class AnimationController extends EventDispatcher implements IObjectController, IAnimatable
	{
		/**
		 * Start time of animation in seconds. 
		 */
		public var startTime : Number;
		
		/**
		 * End time of animation in seconds. 
		 */
		public var endTime : Number;
		
		/**
		 * 
		 */
		private var _channels : Array;
		
		/**
		 * 
		 */
		private var _isPlaying : Boolean;
		
		/**
		 * 
		 */
		private var _isPaused : Boolean;
		
		/**
		 * 
		 */
		private var _currentTime : Number;
		
		/**
		 * 
		 */
		private var _currentTimeStamp : int;
		
		/**
		 * 
		 */
		private var _pauseTime : Number;
		
		/**
		 * 
		 */
		private var _loop : Boolean;
		
		/** */
		private var _clip : AnimationClip3D;
		
		/** */
		private var _clips : Array;
		
		/** */
		private var _clipByName : Object;
		
		/** */
		private var _dispatchEvents : Boolean;
		
		/** */
		private var _clipName : String;
		
		/**
		 * Constructor.
		 */
		public function AnimationController(dispatchEvents:Boolean=true) 
		{
			super();
			
			_dispatchEvents = dispatchEvents;
			
			init();			
		}

		/**
		 * 
		 */
		public function addChannel(channel : Channel3D) : Channel3D 
		{
			if(_channels.indexOf(channel) == -1)
			{
				_channels.push(channel);
				updateStartAndEndTime();
				return channel;
			}
			return null;
		}

		/**
		 * 
		 */
		public function addClip(clip : AnimationClip3D) : AnimationClip3D
		{
			if(_clips.indexOf(clip) == -1)
			{
				_clips.push(clip);
				_clipByName[clip.name] = clip;
				return clip;
			}
			return null;	
		}

		/**
		 * 
		 */
		public function clone() : AnimationController
		{
			var controller : AnimationController = new AnimationController();
			var channel : Channel3D;
			var cloned : Channel3D;
			var i : int;
			
			for(i = 0; i < _channels.length; i++)
			{
				channel = _channels[i];
				cloned = channel.clone();
				controller.addChannel(cloned);
			}
			return controller;
		}

		/**
		 * Initialize.
		 */
		protected function init() : void
		{
			_channels = new Array();
			_clips = new Array();
			_clipByName = new Object();
			_isPlaying = false;
			_isPaused = false;
			_currentTime = 0;
			_loop = false;
			updateStartAndEndTime();
		}
		
		/**
		 * Pause the animation.
		 */
		public function pause() : void
		{
			_pauseTime = _currentTime;
			_isPaused = true;
			_isPlaying = false;
			
			if (_dispatchEvents)
			{
				var clipName :String = _clip ? _clip.name : "all";

				dispatchEvent(new AnimationEvent(AnimationEvent.PAUSE, _pauseTime, clipName));
			}
		}
		/**
		 * Plays the animation.
		 * 
		 * @param 	clip	Clip to play. Default is "all"
		 * @param 	loop	Whether the animation should loop. Default is true.
		 */ 
		public function play(clip:String="all", loop:Boolean=true) : void 
		{
			if(clip && clip.length && _clipByName[clip] is AnimationClip3D) 
			{	
				_clip = _clipByName[clip];
			}
			else
			{
				_clip = null;
			}
			
			if(_channels.length)
			{
				_loop = loop;
				_currentTimeStamp = getTimer();
				if(_clip)
				{
					_currentTimeStamp -= (_clip.startTime * 1000);	
				}
				_isPlaying = true;
				_isPaused = false;
			}
			
			if (_dispatchEvents)
			{
				var clipName :String = _clip ? _clip.name : "all";
				var time :Number = _clip ? _clip.startTime : 0;
				
				dispatchEvent(new AnimationEvent(AnimationEvent.START, time, clipName));
			}
		}

		/**
		 * 
		 */
		public function removeAllChannels() : void
		{
			while(_channels.length)
			{
				_channels.pop();
			}
			updateStartAndEndTime();
		}
		
		/**
		 * 
		 */
		public function removeChannel(channel : Channel3D) : Channel3D
		{
			var pos : int = _channels.indexOf(channel);
			if(pos >= 0)
			{
				_channels.splice(pos, 1);
				updateStartAndEndTime();
				return channel;
			}
			return null;
		}
		
		/**
		 * Removes a clip.
		 * 
		 * @param clip
		 * 
		 * @return	The removed clip or null on failure.
		 */
		public function removeClip(clip : AnimationClip3D) : AnimationClip3D
		{
			var pos : int = _clips.indexOf(clip);
			if(pos >= 0)
			{
				_clips.splice(pos, 1);
				_clipByName[clip.name] = null;
				return clip;
			}
			return null;
		}
		
		/**
		 * Resumes the animation.
		 * 
		 *  @param loop	Whether the animation should loop. Defaults to true;
		 */
		public function resume(loop:Boolean=true) : void
		{
			if(_channels.length)
			{
				_loop = loop;
				_currentTimeStamp = getTimer();
				if(_isPaused)
				{
					_currentTimeStamp = getTimer() - _pauseTime * 1000;	
				}
				_isPlaying = true;
				_isPaused = false;
				
				if (_dispatchEvents)
				{
					var clipName :String = _clip ? _clip.name : "all";

					dispatchEvent(new AnimationEvent(AnimationEvent.RESUME, _pauseTime, clipName));
				}
			}
		}

		/**
		 * Stops the animation.
		 */
		public function stop() : void
		{	
			_isPlaying = false;
			
			if (_dispatchEvents)
			{
				var endTime :Number = _clip ? _clip.endTime : this.endTime;
				var clipName :String = _clip ? _clip.name : "all";
			
				dispatchEvent(new AnimationEvent(AnimationEvent.STOP, endTime, clipName));
			}
		}
		
		/**
		 * Update.
		 */
		public function update() : void 
		{
			if(!_isPlaying || _isPaused || !_channels.length)
			{
				return;
			}
			
			var t : int = getTimer();
			var elapsed : int = t - _currentTimeStamp;
			var channel : Channel3D;
			var et : Number = _clip ? _clip.endTime : endTime;
			clipName = _clip ? _clip.name : "all";
			
			_currentTime =  (elapsed * 0.001);

			if(_currentTime > et) 
			{
				
				if(!_loop)
				{
					if (_dispatchEvents)
					{
						dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE, et, clipName));
					}
					
					stop();
					return;
				}
				_currentTimeStamp = t;
				if(_clip)
				{
					_currentTimeStamp -= (_clip.startTime * 1000);
				}
				_currentTime = _clip ? _clip.startTime : startTime;
			}
			
			for each(channel in _channels)
			{
				channel.update(_currentTime);
			}
			
			if (_isPlaying && _dispatchEvents)
			{
				dispatchEvent(new AnimationEvent(AnimationEvent.NEXT_FRAME, _currentTime, clipName));
			}
		}

		/**
		 * Updates the startTime and endTime of this animation controller.
		 */
		protected function updateStartAndEndTime() : void
		{
			var channel : Channel3D;
			
			if(_channels.length == 0)
			{
				startTime = endTime = 0;
				return;
			}
			
			startTime = Number.MAX_VALUE;
			endTime = -startTime;
		
			for each(channel in _channels)
			{
				startTime = Math.min(startTime, channel.startTime);
				endTime = Math.max(endTime, channel.endTime);
			}
		}
		
		/**
		 * 
		 */
		override public function toString() : String
		{
			return "[AnimationController] #channels: " + _channels.length + " startTime: " + startTime + " endTime: " + endTime;
		}
		
		public function set channels(value : Array) : void
		{
			_channels = value;	
		}
		
		public function get channels() : Array
		{
			return _channels;
		}
		
		public function get currentTime():Number
		{
			return _currentTime;	
		}
		
		/**
		 * Gets all defined clip names. This property is read-only.
		 * 
		 * @return Array containing clip names.
		 */
		public function get clipNames() : Array
		{
			var names : Array = new Array();	
			var clip : AnimationClip3D;
			
			for each(clip in _clips)
			{
				names.push(clip.name);
			}
			return names;
		}
		
		/**
		 * Gets all defined clips. This property is read-only.
		 * 
		 * @return Array containing clips.
		 * 
		 * @see org.papervision3d.core.animation.clip.AnimationClip3D
		 */
		public function get clips() : Array
		{
			return _clips;
		}
		
		/**
		 * 
		 */
		public function get dispatchEvents():Boolean
		{
			return _dispatchEvents;
		} 
		
		/**
		 * 
		 */
		public function set dispatchEvents(value:Boolean):void
		{
			_dispatchEvents = value;	
		}
		
		/**
		 * Number of channels.
		 */
		public function get numChannels() : uint
		{
			return _channels.length;
		}
		
		/**
		 * Whether the animation is playing. This property is read-only.
		 */
		public function get playing() : Boolean
		{
			return _isPlaying;
		}
		
		public function set clipName(c:String)
		{
			_clipName = c;
		}
		
		public function get clipName():String
		{
			return _clipName;
		}
		
	}
}
