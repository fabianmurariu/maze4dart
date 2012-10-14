class PropertyContainerImpl implements PropertyContainer {
  bool __valid = false;
  final _inner = new Map<String, Object>();
  Object getProperty(String name) => this._inner[name];
  void setProperty(String name, Object value) { this._inner[name]=value;}
  Collection<String> getKeys() => this._inner.getKeys();
  bool hasProperty(String key) => this._inner.containsKey(key);
  Object removeProperty(String key) => this._inner.remove(key);

  _check(var value){
    if (this.__valid) return value; else throw new IllegalStateError(" Object is invalid");
  }
  
  _validate() => this.__valid = true;
  _invalidate() { _check(this.__valid); return this.__valid = false; }
  
}
