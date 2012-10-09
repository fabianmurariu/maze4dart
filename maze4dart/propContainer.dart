
class PropertyContainerImpl implements PropertyContainer {
  /* FIXME: on delete of properties one must clean up the index
   * we need to overwrite methods that change to keep the index
   * in sync */
  final _inner = new Map<String, Object>();
  Object getProperty(String name) => this._inner[name];
  void setProperty(String name, Object value) { this._inner[name]=value;}
  Collection<String> getKeys() => this._inner.getKeys();
  bool hasProperty(String key) => this._inner.containsKey(key);
  Object removeProperty(String key) => this._inner.remove(key);
}
