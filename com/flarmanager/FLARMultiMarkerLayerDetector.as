﻿/* 
 * PROJECT: FLARToolKit
 * --------------------------------------------------------------------------------
 * This work is based on the NyARToolKit developed by
 *   R.Iizuka (nyatla)
 * http://nyatla.jp/nyatoolkit/
 *
 * The FLARToolKit is ActionScript 3.0 version ARToolkit class library.
 * Copyright (C)2008 Saqoosha
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this framework; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * For further information please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<saq(at)saqoosha.net>
 * 
 * For further information of this Class please contact.
 *	http://www.libspark.org/wiki/saqoosha/FLARToolKit
 *	<taro(at)tarotaro.org>
 *
 */
package com.flarmanager
{
	import com.flarmanager.events.FLAREvent;
	import flash.display.Graphics;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.IFLARRgbRaster;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetectorResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	
	import org.tarotaro.flash.ar.layers.FLARLayer;
	
	/**
	 * ...
	 * @author å¤ªéƒŽ(tarotaro.org)
	 */
	public class FLARMultiMarkerLayerDetector extends FLARLayer
	{
		protected var _detector:FLARMultiMarkerDetector;
		protected var _detectors:Array;
		protected var _confidence:Number;
		
		private var colors:Array = [
			0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0xFF00FF
		];
		public function FLARMultiMarkerLayerDetector(src:IFLARRgbRaster, 
														param:FLARParam, 
														codeList:Array, 
														markerWidthList:Array, 
														confidence:Number = 0.65,
														thresh:int = 100) 
		{
			super(src, thresh);
			this._detectors = new Array();
			for (var i in codeList)
			{
				this._detectors[i] = new FLARSingleMarkerDetector(param, codeList[i], markerWidthList[i]);
				this._detectors[i].setContinueMode(true);
			}
			
			/*this._detector = new FLARMultiMarkerDetector(param, codeList, markerWidthList, codeList.length);
			this._detector.sizeCheckEnabled = false;
			this._detector.setContinueMode(true);*/
			this._confidence = confidence;
			this._thresh = thresh;
		}
		
		/*public function getTransformationMatrix(patternId:uint)
		{
			if (this._resultMatList[patternId] == null) this._resultMatList[patternId] = new FLARTransMatResult();
			
			try {
				this._detector.getTransmationMatrix(patternId, this._resultMatList[patternId]);
			} catch (e:Error)
			{
				trace("OPA DEU PAU");
				this._resultMatList[patternId] = null;
			}
			return this._resultMatList[patternId];
		}*/
		
		override public function update():void 
		{
			var g:Graphics = this.graphics;
			g.clear();
			
			//var numDetected:int = this._detector.detectMarkerLite(this._source, this._thresh);
			//var r:FLARMultiMarkerDetectorResult = this._detector.detectMarkerLite(this._source, this._thresh);
			//if (r != null) {
			
			for (var i in this._detectors)
			{
				var detected:Boolean = false;
				try {
					detected = this._detectors[i].detectMarkerLite(this._source, this._thresh) && this._detectors[i].getConfidence() > this._confidence;
				} catch (e:Error) {}
				
				if (detected) {
					var _resultMat:FLARTransMatResult = new FLARTransMatResult();
					this._detectors[i].getTransformMatrix(_resultMat);
					dispatchEvent(new FLAREvent(FLAREvent.PATTERN_ADDED, i, _resultMat));
				}
			}
			
			/*if (numDetected > 0) {
				//trace(numDetected);
				for (var i:uint = 0; i < numDetected; i++) {
					var r:FLARMultiMarkerDetectorResult = this._detector.getResult(i);
					//trace(r.codeId,":",r.confidence);
					if (r.confidence <= this._confidence) {
						continue;
					}
					dispatchEvent(new FLAREvent(FLAREvent.PATTERN_ADDED, r.codeId, getTransformationMatrix(r.codeId)));
					var v:Array = r.square.sqvertex;
					g.lineStyle(2, colors[r.codeId]);
					g.moveTo(v[3].x, v[3].y);
					for (var vi:int = 0; vi < v.length; vi++) {
						g.lineTo(v[vi].x, v[vi].y);
					}
				}
			}*/
		}
		
	}
	
}