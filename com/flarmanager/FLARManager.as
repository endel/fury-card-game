package com.flarmanager {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import org.papervision3d.core.math.Matrix3D;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import com.flarmanager.events.FLAREvent;
	import com.fury.core.events.BattleEvent;
	
	import com.fury.core.Papervision3D;
	
	[Event(name="init",type="flash.events.Event")]
	[Event(name="init",type="flash.events.Event")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	[Event(name = "securityError", type = "flash.events.SecurityErrorEvent")]
	
	
	/**
	 * Custom FLARManager
	 * @author Endel Dreyer
	 */
	
	public class FLARManager extends Sprite {
		
		private static var _markerSegments:uint = 16;
		
		private static var _loader:URLLoader;
		private static var _cameraFile:String;
		private static var _cardList:Array;
		private static var _width:int;
		private static var _height:int;
		private static var _codeWidth:int;
		
		private static var _layer:FLARMultiMarkerLayerDetector;
		
		public static var camera_parameters:FLARParam;
		private static var _patterns:Array;
		private static var _patternWidths:Array;
		private static var _patternIds:Dictionary;
		private static var _patternLoaders:Array;
		
		private static var _listeners:Dictionary;
		
		private static var _raster:FLARRgbRaster_BitmapData;
		private static var _detector:FLARSingleMarkerDetector;
		
		private static var _webcam:Camera;
		private static var _video:Video;
		private static var _capture:Bitmap;
		
		private static var _onLoadedCallback:Function;
		
		public static function init(cameraFile:String, cardList:Array, onLoadedCallback = null, canvasWidth:int = 320, canvasHeight:int = 240, codeWidth:int = 80):void {
			_patterns = new Array();
			_patternWidths = new Array();
			_patternIds = new Dictionary(true);
			_patternLoaders = new Array();
			_cardList = cardList;
			_onLoadedCallback = onLoadedCallback;
			
			_listeners = new Dictionary(true);
			
			_cameraFile = cameraFile;
			_width = canvasWidth;
			_height = canvasHeight;
			_codeWidth = codeWidth;
			
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, _onLoadCameraFile);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_loader.load(new URLRequest(_cameraFile));
		}
		
		private static function onError(e:Event)
		{
			trace("error: " + e.toString());
		}
		
		public static function addEventListener(type:String, callback:Function)
		{
			_listeners[type] = callback;
		}
		
		private static function _onLoadCameraFile(e:Event):void {
			_loader.removeEventListener(Event.COMPLETE, _onLoadCameraFile);
			camera_parameters = new FLARParam();
			camera_parameters.loadARParam(_loader.data);
			camera_parameters.changeScreenSize(_width, _height);
			
			for (var i in _cardList)
			{
				var patternLoader:URLLoader = new URLLoader();
				_patternIds[patternLoader] = i;
				
				patternLoader.dataFormat = URLLoaderDataFormat.TEXT;
				patternLoader.addEventListener(Event.COMPLETE, _onLoadCode);
				patternLoader.load(new URLRequest(_cardList[i].pattern));
				_patternLoaders.push(patternLoader);
			}
		}
		
		private static function _onLoadCode(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			trace("Pattern id: " + _patternIds[loader]);
			
			var _code = new FLARCode(_markerSegments, _markerSegments);
			_code.loadARPatt(loader.data);
			_patterns[ _patternIds[loader] ] = _code;
			_patternWidths[ _patternIds[loader] ] = _codeWidth;
			
			loader = null;
			
			// if all patterns were loaded...
			if ( _patterns.length == _cardList.length )
				onInit();
		}
		
		private static function setupWebcam()
		{
			// setup webcam
			_webcam = Camera.getCamera();
			if (!_webcam) {
				throw new Error('No webcam connected.');
			}
			_webcam.setMode(_width, _height, 30);
			
			_video = new Video(_width, _height);
			_video.attachCamera(_webcam);
			
			_capture = new Bitmap(new BitmapData(_width, _height, false, 0), PixelSnapping.AUTO, false);
			_raster = new FLARRgbRaster_BitmapData(_capture.bitmapData);
			
			_layer = new FLARMultiMarkerLayerDetector(_raster, camera_parameters, _patterns, _patternWidths);
			_layer.addEventListener(FLAREvent.PATTERN_ADDED, onPatternAdded);
			_layer.addEventListener(FLAREvent.PATTERN_REMOVED, onPatternRemoved);
			
			_layer.scaleX = _capture.scaleX = 800 / _width;
			_layer.scaleY = _capture.scaleY = 600 / _height;
		}
		
		private static function onPatternAdded(e:FLAREvent)
		{
			if (_listeners[FLAREvent.PATTERN_ADDED]) {
				_listeners[FLAREvent.PATTERN_ADDED]( new BattleEvent(BattleEvent.CARD_ADDED, _cardList[e.patternId], FLARPVGeomUtils.convertFLARMatrixToPVMatrix(e.transformationMatrix) ));
			}
		}
		
		private static function onPatternRemoved(e:FLAREvent)
		{
			if (_listeners[FLAREvent.PATTERN_REMOVED])
				_listeners[FLAREvent.PATTERN_REMOVED](new BattleEvent(BattleEvent.CARD_REMOVED, _cardList[e.patternId]));
		}
		
		protected static function onInit():void {
			setupWebcam();
			if (_onLoadedCallback != null) 
				_onLoadedCallback(_capture, _layer);
		}
		
		public static function refresh()
		{
			_capture.bitmapData.draw(_video);
			_layer.update();
		}
	}
}