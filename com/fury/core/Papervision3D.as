package com.fury.core 
{
	import flash.events.Event;
	
	// import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	
	import flash.utils.Dictionary;
	
	/**
	 * Bridge to 3d rendering engine
	 * @author Endel Dreyer
	 */
	public class Papervision3D
	{
		private static var container:*;
		
		private static var viewport3D:Viewport3D;
		private static var camera3D:FLARCamera3D;
		private static var scene3D:Scene3D;
		private static var renderEngine:LazyRenderEngine;
		
		private static var childs:Dictionary;
		
		
		public static function init(cameraParams, drawTo, updateFunction:Function = null)
		{
			container = drawTo;
			childs = new Dictionary(true);
			
			scene3D = new Scene3D();
			camera3D = new FLARCamera3D();
			camera3D.setParam(cameraParams);
			
			viewport3D = new Viewport3D();
			viewport3D.autoScaleToStage = true;
			container.addChild(viewport3D);
			
			renderEngine = new LazyRenderEngine(scene3D, camera3D, viewport3D);
			
			if (updateFunction) {
				container.addEventListener(Event.ENTER_FRAME, updateFunction);
			}
		}
		
		public static function onUpdate(updateFunction:Function = null)
		{
			if (container) {
				container.addEventListener(Event.ENTER_FRAME, updateFunction);
			} else {
				trace("Papervision3D error: You must init() passing \"container\" as parameter.");
			}
		}
		
		public static function getScene()
		{
			return scene3D;
		}
		
		public static function addChild(model:*) {
			// refuse to add twice
			if (!childs[model.id]) {
				childs[model.id] = model;
				scene3D.addChild(childs[model.id].container);
			}
		}
		
		public static function getChild(model) {
			return childs[model.id];
		}
		
		public static function render()
		{	
			renderEngine.render();
		}
		
	}

}