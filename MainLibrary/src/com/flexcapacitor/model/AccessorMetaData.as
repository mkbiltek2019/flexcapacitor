package com.flexcapacitor.model {
	
	
	/**
	 * Contains information on style metadata
	 * */
	public class AccessorMetaData extends MetaData {
		
		
		public function AccessorMetaData(item:XML = null, target:* = null) {
			if (item) unmarshall(item, target);
		}
		
		/**
		 * Access type. Readonly, readwrite, writeonly. 
		 * */
		public var access:String;
		
		/**
		 * Is property inspectable
		 * */
		public var inspectable:Boolean;
		
		
		/**
		 * Import metadata XML property node into this instance
		 * We may need to update the skin values
		 * */
		override public function unmarshall(item:XML, target:* = null, getValue:Boolean = true):void {
			access = item.@access;
			
			super.unmarshall(item, target, getValue);
			
			if (item==null) return;
			
			var metadata:XMLList = item.metadata;
			var args:XMLList;
			var keyName:String;
			var keyValue:String;
			var propertyValue:*;
			var dataname:String;
			
			// loop through metadata objects
			outerloop:
			for each (var data:XML in metadata) {
				dataname = data.@name;
				args = data.arg;
				
				
				// loop through arguments in each metadata
				innerloop:
				for each (var arg:XML in args) {
					keyName = arg.@key;
					keyValue = String(arg.@value);
					
					// get inspectable meta data
					if (dataname=="Inspectable") {
						inspectable = true;
						
						if (keyName=="arrayType") {
							arrayType = keyValue;
							continue innerloop;
						}
						
						else if (keyName=="category") {
							category = keyValue;
							continue innerloop;
						}
						
						else if (keyName=="defaultValue") {
							defaultValue = keyValue;
							continue innerloop;
						}
						
						else if (keyName=="enumeration") {
							enumeration = keyValue.split(",");
							continue innerloop;
						}
						
						else if (keyName=="environment") {
							environment = keyValue;
							continue innerloop;
						}
						
						else if (keyName=="format") {
							format = keyValue;
							
							if (keyValue is String && keyValue.toLowerCase()=="color") {
								isColor = true;
							}
							
							continue innerloop;
						}
						
						else if (keyName=="minValue") {
							minValue = int(keyValue);
							continue innerloop;
						}
						
						else if (keyName=="maxValue") {
							maxValue = int(keyValue);
							continue innerloop;
						}
			
						else if (keyName=="theme") {
							theme = keyValue;
							continue innerloop;
						}
						
						else if (keyName=="type") {
							type = keyValue;
							continue innerloop;
						}
				
						else if (keyName=="verbose") {
							verbose = keyValue=="1";
							continue innerloop;
						}
						
					}
					
					else if (dataname=="__go_to_definition_help") {
						if (keyName=="pos") {
							if (helpPositions==null) helpPositions = [];
							helpPositions.push(keyValue);
						}
					}
					
					else if (dataname=="ArrayElementType") {
						if (keyName=="") {
							arrayElementType = keyValue;
						}
					}
					
					else if (dataname=="Bindable") {
						if (keyName=="") {
							if (bindable==null) bindable = [];
							bindable.push(keyValue);
						}
					}
					
					else if (dataname=="PercentProxy") {
						if (keyName=="") {
							if (percentProxy==null) percentProxy = [];
							percentProxy.push(keyValue);
						}
					}
					else if (dataname=="SkinPart") {
						if (keyName=="") {
							if (skinPart==null) skinPart = [];
							skinPart.push(keyValue);
						}
					}
					
				}
			
			}
			
			
			if (access!="writeonly") {
				updateValues(target, getValue);
			}
			
			raw = item.toXMLString();
			
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function updateValues(target:Object, getValue:Boolean = true):void {
			
			if (getValue) {
				if (access!="writeonly") {
					value = target && name in target ? target[name] : undefined;
					
					textValue = value===undefined || value==null ? "": "" + value;
				}
			}
			else {
				value = undefined;
			}
			
			return;
			
			// if skins change we may need to update the skin values
			var xml:XML = new XML(raw);
			if (xml.metadata.@dataname=="SkinPart") {
				//if (keyName=="") {
				//	if (skinPart==null) skinPart = [];
				//	skinPart.push(keyValue);
				//}
			}
		}
			
	}
}