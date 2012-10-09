
class RelationshipImpl extends PropertyContainerImpl implements Relationship {
  final int _id;
  final GraphImpl _graph;
  final Node _startNode;
  final Node _endNode;
  final RelationshipType _type;
  int _startNodetListId;
  int _endNodeListId;
  RelationshipImpl(this._id,this._type,this._startNode, this._endNode,this._graph);
  /**
   * Remove relationship from adjiacent nodes
   * remove relationship from index
   * if indexing is supported
   * if calling node is not null
   * we assume it already deleted the
   * relation
   * 
   * @throws
   *  IllegalArgumentException if callingNode isn't the 
   *  the startNode or endNode;
   */
  void delete(){
    this._startNode._removeRelationship(this);
    this._endNode._removeRelationship(this);
    if (this._graph._autoIndex){
      this._graph._relIdx.remove(this);
    }
    this._graph._relIdx.remove(this,Standard._REL_ID_INDEX_FIELD,this._id);
  }
  Node getEndNode() => this._endNode;
  
  int getId() => this._id;
  
  List<Node> getNodes() => [this._startNode,this._endNode];
  
  Node getOtherNode(Node n) => this._startNode==n?this._endNode:this._startNode;
  
  Node getStartNode() => this._startNode;
  
  RelationshipType getType() => this._type;
  
  bool isType(RelationshipType type) => this._type==type;
}
