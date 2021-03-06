
package com.flexcapacitor.utils {
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	/**
	 * Utils for working with Arrays
	 * */
	public class ArrayUtils {
		
		public function ArrayUtils() {
			
		}
		
		/**
		 * Returns true if an item is found
		 * */
		public static function hasItem(haystack:*, needle:*, property:String = null, caseSensitive:Boolean = true):Boolean {
			var value:Object = getItem(haystack, needle, property, caseSensitive);
			return value!=null;
		}
		
		/**
		 * Finds a value in an Array, ArrayList or ArrayCollection.  <br>
		 * This is a for loop wrapped in a method. <br><br>
		 * 
		 * It lets you specify a property so if the Array is filled with objects it 
		 * will check the property specified of each object for the value specified.<br><br>
		 * 
		 * You can specify findAll to return an array if multiple items are matched.
<pre>

// search an array for "blue"
var items:Array = ["red","yellow","green","blue","violet","red","orange"];
var result:Object = ArrayUtils.getItem(items, "blue");
trace(result); // returns "blue"


// search an array for "red" and return all the matches  
var result:Object = ArrayUtils.getItem(items, "red", false, true);
trace(result); // returns ["red","red"]

// create multiple objects with a "name" property
var person1:Object = new Object();
person1.name = "John";
var person2:Object = new Object();
person2.name = "Linda";

// put those objects in an array and search the objects for person named "john"
var people:Array = [person1, person2];
var person:Person = ArrayUtils.getItem(people, "john", "name", false);
trace(person); // john

// searching by the "name" property look for "john" in an array of objects
var peopleArrayList:ArrayList = new ArrayList([person1, person2]);
var person:Person = ArrayUtils.getItem(peopleArrayList, "john", "name", false);
trace(person); // john

// search for a person with name "linda" in an ArrayCollection
var peopleArrayCollection:ArrayCollection = new ArrayCollection([person1, person2]);
var person:Person = ArrayUtils.getItem(peopleArrayCollection, "linda", "name", false);
trace(person); // linda

// searching for a person with name "bill"
var peopleArrayCollection:ArrayCollection = new ArrayCollection([person1, person2]);
var person:Person = ArrayUtils.getItem(peopleArrayCollection, "bill", "name", false);
trace(person); // null

// searches for a person with the name "john" and finds all of the items that match
var people:Array = [person1, person2, person1];
var person:Person = ArrayUtils.getItem(people, "john", "name", false, true);
trace(person); // returns [person1, person1]; since we set "findAll" to true it returns an array of two items
</pre>
		 * 
		 * Returns the item matching your search or an array of items if you specified true for "findAll" in the
		 * parameters.
		 * */
		public static function getItem(haystack:*, needle:*, property:String = null, caseSensitive:Boolean = true, findAll:Boolean = false):Object {
			var needleLowerCase:* = !caseSensitive && needle is String ? String(needle).toLowerCase() : needle;
			var numberOfItems:int = haystack ? haystack.length : 0;
			var sourceArray:Array;
			var value:Object;
			var item:Object;
			var all:Array = [];
			
			if (haystack is ArrayCollection || haystack is ArrayList) {
				sourceArray = haystack.source;
			}
			else {
				sourceArray = haystack;
			}
			
			for (var i:int;i<numberOfItems;i++) {
				
				if (property==null) {
					value = sourceArray[i];
				}
				else {
					value = sourceArray[i][property];
				}
				
				if (caseSensitive) {
					if (value==needle) {
						item = sourceArray[i];
						
						if (findAll) {
							all.push(item);
							continue;
						}
						else {
							break;
						}
					}
				}
				else {
					if (value==needleLowerCase || 
						(value!=null && value.toString().toLowerCase()==needleLowerCase)) {
						item = sourceArray[i];
						
						if (findAll) {
							all.push(item);
							continue;
						}
						else {
							break;
						}
					}
				}
			}
			
			if (findAll) {
				return all;
			}
			else {
				return item;
			}
		}
		
		/**
		 * Same as getItem but returns the index(es). <br > <br >
		 * 
		 * Returns the index of the item matching your search or 
		 * an array of indexes of the items matching your search 
		 * if you specified true for "findAll" in the parameters.
		 * */
		public static function getItemIndex(haystack:*, needle:*, property:String = null, caseSensitive:Boolean = true, findAll:Boolean = false):Object {
			var needleLowerCase:* = !caseSensitive && needle is String ? String(needle).toLowerCase() : needle;
			var total:int = haystack ? haystack.length : 0;
			var sourceArray:Array;
			var value:Object;
			var item:Object;
			var all:Array = [];
			var index:int = -1;
			
			if (haystack is ArrayCollection || haystack is ArrayList) {
				sourceArray = haystack.source;
			}
			else {
				sourceArray = haystack;
			}
			
			for (var i:int;i<total;i++) {
				
				if (property==null) {
					value = sourceArray[i];
				}
				else {
					value = sourceArray[i][property];
				}
				
				if (caseSensitive) {
					if (value==needle) {
						index = i;
						if (findAll) {
							all.push(index);
							continue;
						}
						else {
							break;
						}
					}
				}
				else {
					if (value==needleLowerCase || 
						(value!=null && value.toString().toLowerCase()==needleLowerCase)) {
						index = i;
						if (findAll) {
							all.push(index);
							continue;
						}
						else {
							break;
						}
					}
				}
			}
			
			if (findAll) {
				return all;
			}
			else {
				return index;
			}
		}
		
		/**
		 * Removes an item from an array, array list or array collection
		 * */
		public static function removeItem(haystack:*, item:Object, findAll:Boolean = false):void {
			var total:int = haystack.length;
			var sourceArray:Array;
			var value:Object;
			var item:Object;
			var all:Array = [];
			
			if (haystack is ArrayCollection || haystack is ArrayList) {
				sourceArray = haystack.source;
			}
			else {
				sourceArray = haystack;
			}
			
			
			for (var i:int;i<total;i++) {
				value = sourceArray[i];
				
				if (value==item) {
					if (findAll) {
						sourceArray.splice(i,1);
						i = i-1;
						total = total-1;
						if (total==0) break;
						continue;
					}
					else {
						sourceArray.splice(i,1);
					}
				}
			}
		}
		
		/**
		 * Joins multiple arrays into a single new array.
		 * 
<pre>
var array:Array = [1,2,3];
var array2:Array = [4,5,6];

var newArray:Array = ArrayUtils.join(array, array2, [7,8,9]); 
</pre>
		 * @see add
		 * */
		public static function join(...Arguments):Array {
			var newArray:Array = [];
			var numberOfArguments:int = Arguments.length;
			
			for (var i:int;i<numberOfArguments;i++) {
				if (Arguments[i]) {
					newArray = newArray.concat(Arguments[i]);
				}
			}
			
			return newArray;
		}
		
		/**
		 * Add additional arrays to first array and supposed to return same array but 
		 * is returning a new array. See join.
		 * 
<pre>
var array:Array = [1,2,3];
var array2:Array = [4,5,6];

var newArray:Array = ArrayUtils.add([0], array, array2, [7,8,9]); 
</pre>
		 * @see join
		 * */
		public static function add(original:Array, ...Arguments):Array {
			var numberOfArguments:int = Arguments ? Arguments.length : 0;
			
			// if original is null then error will occur here 
			// we should let it error bc they want to add to a known array
			// if that is null then purpose is not met
			for (var i:int;i<numberOfArguments;i++) {
				if (Arguments[i]) {
					original = original.concat(Arguments[i]);
				}
			}
			
			return original;
		}
		
		/**
		 * Get array from vector
		 * */
		public static function getArrayFromVector(vector:*):Array {
			var numberOfItems:int = vector && "length" in vector ? vector.length : 0;
			var array:Array = [];
			
			for (var i:int = 0; i < numberOfItems; i++) {
				array.push(vector[i]);
			}
			
			return array;
		}
		
		/**
		 * Checks if one array contains any items in a second array  
		 * */
		public static function containsAny(array:Array, items:Array):Boolean {
			var itemFound:Boolean;
			
			if (array && array.length && items && items.length) {
				
				for each (var item:* in items) {
					itemFound = array.indexOf(item)!=-1;
					
					if (itemFound) {
						return itemFound;
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Adds any items in second array to first array. Modifies the original array.
		 * @param array the array containing a list of items
		 * @param itemsToAdd an array of items to add to the orginal array
		 * @returns returns the original array
		 * */
		public static function addMissingItems(array:Array, itemsToAdd:Array):Array {
			var originalItems:Array;
			var item:Object;
			
			if (array) {
				if (itemsToAdd && itemsToAdd.length) {
					
					for (var i:int = 0; i < itemsToAdd.length; i++) {
						item = itemsToAdd[i];
						
						// don't add twice
						if (array.indexOf(item)==-1) {
							array.push(item);
						}
					}
					
				}
			}
			
			return array;
		}
			
		/**
		 * Returns a new array that has none of the items from the second array
		 * @param array the original array containing a list of items
		 * @param itemsToRemove an array of items to remove from the orginal array
		 * @param returnRemovedItems if set to true returns a new array of items that were removed
		 * @returns returns a new array that contains the items that were removed or 
		 * if returnRemoveItems is true then returns a new array of the removed items
		 * */
		public static function removeAllItems(array:Array, itemsToRemove:Array, returnRemovedItems:Boolean = false):Array {
			var originalItems:Array;
			var removedItems:Array = [];
			var location:int;
			
			if (array && array.length && itemsToRemove && itemsToRemove.length) {
				originalItems = array.slice();
				
				for each (var item:* in itemsToRemove) {
					location = originalItems.indexOf(item);
					
					while (location!=-1) {
						if (removedItems.indexOf(item)==-1 && returnRemovedItems) {
							removedItems.push(item);
						}
						
						originalItems.splice(location, 1);
						location = originalItems.indexOf(item);
					}
				}
			}
			
			if (returnRemovedItems) {
				return removedItems;
			}
			
			return originalItems;
		}
		
		

	}
}