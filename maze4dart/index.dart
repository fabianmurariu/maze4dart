typedef Object Handle<T>(List<T> hits, T object);
typedef Object Lookup<T>(T object, String key, Object value, Handle<T> handle);
class IndexImpl<T extends PropertyContainer> implements Index {
  /**
   * Internal multi-MAP supporting the index
   */
  final Map<String,Map<Object,List<T>>> _inner = new Map();
  /**
   * Configurable, all keys that will be auto
   * indexed should be in this list
   */
  final List<String> _indexableKeys;
  
  IndexImpl(this._indexableKeys);

  /**
   * Find where object needs to be updated
   * then delegate to handle
   * This function changes the index
   * by adding the maps/lists needed to
   * support lookups
   */
   Object _updateAndHandle(T object, String key, Object value, Handle<T> handle){
    if (this._indexableKeys.indexOf(key) >= 0){
      Map<Object,List<T>> index = this._inner[key];
      if (index == null) {
        index = new Map();
        this._inner[key] = index;
      } 
      List<T> hits = index[value];
      if (hits == null) {
        hits = new List();
        index[value]=hits;
      }
      return handle(hits,object);      
    }
  }
  /**
   * Find where the objects should be
   * then if found delegate to handle
   * 
   * If not found then return an empty list
   */
  Object _findAndHandle(T object, String key, Object value, Handle<T> handle){
    if (this._indexableKeys.indexOf(key) >= 0){
      Map<Object,List<T>> index = this._inner[key];
      if (index == null)
        return [];
      List<T> hits = index[value];
      if (hits == null){
        return []; /* kind empty list */
      }
      Object o =  handle(hits,object);
      /* do some cleanup on this key */
      if (hits.length == 0)
        index.remove(value);
      if (index.length == 0)
        this._inner.remove(key);
      return o;
    } else {
      return [];
    }
  }
  
  void add(T object, [String key, Object value]){
    if ((key==null) != (value==null))
      throw new IllegalArgumentException([key,value]); /* key AND values are a must */
    _delegateHandler(object, (hits,object) => hits.add(object), this._updateAndHandle, key, value);
  }
  
  List<T> putIfAbsent(T object, String key, Object value){
    if (key == null || value == null)
      throw new IllegalArgumentException([key,value]);
    return _updateAndHandle(object, key, value, 
        (hits,object) {
          if (hits.length > 0) return new List.from(hits);
          hits.add(object); 
          return [];
        });
  }
  
  /**
   * if: key and value are not null
   * then lookup the object via key/value pair
   * else: lookup using every indexable key/value pair
   * available in the PropertyContainer T
   */
  T _delegateHandler(T object, Handle<T> handle, Lookup<T> lookup,[String key, Object value]){
    if (key != null && value != null){
      return lookup(object,key,value,handle);
    } else {
      /* it's either key and value are 
       * both null or both not null
       * otherwise we ignore them */
       object.getKeys().forEach((key) {
         lookup(object, key, object.getProperty(key),handle);
       });
       return null; /* there could be multiple key/value mappings of other objects so we don't return them all */
    }
    
  }
  
  List<T> get(String key, Object value){
    if (key ==null || value == null)
      throw new IllegalArgumentException([key,value]);
    return this._findAndHandle(null,key,value,(hits,object) { return hits;});
  }
  
  void remove(T object,[String key, Object value]){
    this._delegateHandler(object, (hits, object) {
      int i = hits.indexOf(object);
      if (i >= 0)
        hits.removeAt(i);
    },this._findAndHandle,key, value);
  }
  
  void clear(){
    /* doesn't _inner.clear() suffice? */
    this._inner.forEach((key1,subMap) { 
      subMap.forEach((key2,list) => list.clear());
      subMap.clear();
      });
    this._inner.clear();
  }
}
/**
 * Add only index, wraps a real index implementation
 * but only exposes get, and putIfAbsent it doesn't allow
 * the caller to change existing values
 */
class ReadOnlyIndexImpl<T extends PropertyContainer> implements ReadOnlyIndex{
  Index _inner;
  ReadOnlyIndexImpl(this._inner);
  List<T> get(String key, Object value) => this._inner.get(key, value);
}