
class NodeImpl extends PropertyContainerImpl implements Node {
  final int _id;
  /*maybe replace with a tree map, better for access*/
  final _rels = new List<Relationship>(); 
  final GraphImpl _graph;
  
  NodeImpl(this._id,this._graph);
  
  Relationship createRelationship(Node n, [RelationshipType type,Map<String,Object> props]){
    /* create the relationship */
    RelationshipImpl rel = new RelationshipImpl(this._graph._next(Standard._REL_COUNTER), 
        type==null?DefaultRelationshipType.DEFAULT:type, this, n, this._graph);
    this._rels.add(rel);
    /* tell the other guy */
    n._addRelationship(rel);
    /* autoindex all properties or just the ones configured in the index */
    if (this._graph.isAutoIndex()) {
      this._graph._relIdx.add(rel);
    }
    /* always index the id */
    this._graph._relIdx.add(rel,Standard._REL_ID_INDEX_FIELD,rel.getId());
  }
  
  /**
   * called by the start node once it has created
   * a relationship with the end node
   */
  void _addRelationship(Relationship rel){
    this._rels.add(rel);
  }
  
  int getId() => this._id;

  void delete(){
    /* delete all relationships */
    this._rels.forEach((rel) => rel.delete());
    this._rels.clear();
    if (this._graph.isAutoIndex()){
      this._graph._nodeIdx.remove(this);
    }
    this._graph._nodeIdx.remove(this,Standard._NODE_ID_INDEX_FIELD,this._id);
  }
  
  Function makeFilter(Direction direction, RelationshipType type){
    return (Relationship r) {
      bool checkType = (type == null || r.getType() == type);
      bool checkDirection = true;
      /* switch on enums? */
      if (direction == Direction.BOTH){
        checkDirection == true;
      } else if (direction == Direction.INCOMING){
        checkDirection = (r.getEndNode() == this);
      } else if (direction == Direction.OUTGOING){
        checkDirection = (r.getStartNode() == this);
      }
      return checkType && checkDirection;      
    };
  }
  
  List<Relationship> getRelationships([Direction direction = Direction.BOTH, 
      RelationshipType type = DefaultRelationshipType.DEFAULT]){
    if (type == null && direction == null)
      return this._rels; /* could use a immutable list over here */
    var include = makeFilter(direction, type);
    return this._rels.filter(include); 
  }
  
  bool hasRelationships([Direction direction = Direction.BOTH, 
      RelationshipType type = DefaultRelationshipType.DEFAULT]){
    var include = makeFilter(direction, type);
    for (int i = 0; i < this._rels.length; i++){
      if (include(this._rels[i])) return true;
    }
  }
  
  void _removeRelationship(Relationship r, [int index]){
    if (index != null){
      if (this._rels.length > index) {
        Relationship del = this._rels[index];
        if (del == r) this._rels.removeAt(index);
      }
    } else {
      for (int i = 0; i<this._rels.length; i++){
        if (this._rels[i] == r) this._rels.removeAt(i);
      }
    }
  }

}