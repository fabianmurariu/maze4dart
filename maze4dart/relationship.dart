
class RelationshipImpl extends PropertyContainerImpl implements Relationship {
  final int _id;
  final GraphImpl _graph;
  final Node _startNode;
  final Node _endNode;
  final RelationshipType _type;
  
  RelationshipImpl(this._id,this._type,this._startNode, this._endNode,this._graph){
    if (this._startNode == null || this._endNode == null || this._id == null || this._graph == null || this._type == null)
      throw new ArgumentError("Null arguments: id:$this._id, type:$this._type, start:$this._startNode, end:$this._endNode, graph:$this._graph");
    _validate();
  }
  
  /**
   * Remove relationship from adjiacent nodes
   * remove relationship from index
   * if indexing is supported
   * if calling node is not null
   * we assume it already deleted the
   * relation
   * 
   * If nor null the calling node will
   * manage its internal state and 
   * remove the remove the relationship
   * from its list.
   *  
   * @throws
   *  IllegalArgumentException if callingNode isn't the 
   *  the startNode or endNode;
   */
  void delete([Node callingNode]){
    if (callingNode != null && ((callingNode == this._startNode) == (callingNode == this._endNode)))
      throw new ArgumentError(" Calling node $callingNode does not participate in relationship $this");
    if (callingNode != null) {
      this.getOtherNode(callingNode)._removeRelationship(this);
    } else {
      this._startNode._removeRelationship(this);
      this._endNode._removeRelationship(this);
    }
    _invalidate();
    _cleanupIndex();
  }
    
  void _cleanupIndex(){
    if (this._graph._autoIndex){
      this._graph._relIdx.remove(this);
    }
    this._graph._relIdx.remove(this,Standard._REL_ID_INDEX_FIELD,this._id);    
  }
  
  Node getEndNode() => _check(this._endNode);
  
  int getId() => _check(this._id);
  
  List<Node> getNodes() => _check([this._startNode,this._endNode]); 
  
  Node getOtherNode(Node n) => _check(this._startNode==n?this._endNode:this._startNode); 
  
  Node getStartNode() => _check(this._startNode); 
  
  RelationshipType getType() => _check(this._type);
  
  bool isType(RelationshipType type) => _check(this._type);
  
  toString() => "e[${this._id}](${this._startNode}->${this._endNode})";
}
