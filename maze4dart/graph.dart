
class GraphImpl implements Graph {
  
  Index _nodeIdx;
  Index _relIdx;
  AddOnlyIndex _readNodeIdx;
  AddOnlyIndex _readRelIdx;
  int _nodeCount = 0;
  int _relCount = 0;
  List<String> _idxFields;
  bool _autoIndex;
  /**
   * Create the graph, create the Index suport for
   * node & relationship, configure the indexable fields
   */  
  GraphImpl(bool autoindex, List<String> idxFields){
    this._idxFields = idxFields;
    this._autoIndex = autoindex;
    List<String> nIdxFields = [Standard._NODE_ID_INDEX_FIELD];
    nIdxFields.addAll(idxFields);
    this._nodeIdx = new IndexImpl(nIdxFields);
    this._readNodeIdx = new AddOnlyIndexImpl(this._nodeIdx);
    List<String> rIdxFields = [Standard._REL_ID_INDEX_FIELD];
    rIdxFields.addAll(idxFields);
    this._relIdx = new IndexImpl(rIdxFields);
    this._readRelIdx = new AddOnlyIndexImpl(this._relIdx);
  }
  
  Node createNode([Map<String,Object> props]){
    int count = this._next(Standard._NODE_COUNTER);
    Node n = new NodeImpl(count, this);
    if (props != null){
      props.forEach((k,v) => n.setProperty(k, v));
    }
    _nodeIdx.add(n, Standard._NODE_ID_INDEX_FIELD, n.getId());
    if (this._autoIndex)
      _nodeIdx.add(n);
    return n;
  }
  
  Node getNodeById(int id){
    List hits = this._nodeIdx.get(Standard._NODE_ID_INDEX_FIELD, id);
    return hits==null?null:(hits.length==1?hits[0]:null);
  }
  
  Relationship getRelationshipById(int id){
    List hits = this._relIdx.get(Standard._REL_ID_INDEX_FIELD, id);
    return hits==null?null:(hits.length==1?hits[0]:null);    
  }
  
  AddOnlyIndex getRelationshipIndex() => this._readRelIdx;
  
  AddOnlyIndex getNodeIndex() => this._readNodeIdx;
  
  int _next(String counter){
    switch(counter){
      case Standard._NODE_COUNTER:
        return this._nodeCount++;
      case Standard._REL_COUNTER:
        return this._relCount++;
      default:
        return this._nodeCount++; /*if nothing matches increment the node counter and return*/        
    }
  }
  
  bool isAutoIndex() => this._autoIndex;
}
