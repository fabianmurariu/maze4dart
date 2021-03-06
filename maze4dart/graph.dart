
class GraphImpl implements Graph {
  
  Index _nodeIdx;
  Index _relIdx;
  ReadOnlyIndex _readNodeIdx;
  ReadOnlyIndex _readRelIdx;
  int _nodeCount = 0;
  int _relCount = 0;
  List<String> _idxFields;
  bool _autoIndex;
  /**
   * Create the graph, create the Index suport for
   * node & relationship, configure the indexable fields
   */  
  GraphImpl([List<String> idxFields]){
    this._idxFields = idxFields==null?[]:idxFields;
    this._autoIndex = this._idxFields.length > 0;
    List<String> nIdxFields = [Standard._NODE_ID_INDEX_FIELD];
    nIdxFields.addAll(idxFields);
    this._nodeIdx = new IndexImpl(nIdxFields);
    this._readNodeIdx = new ReadOnlyIndexImpl(this._nodeIdx);
    List<String> rIdxFields = [Standard._REL_ID_INDEX_FIELD];
    rIdxFields.addAll(idxFields);
    this._relIdx = new IndexImpl(rIdxFields);
    this._readRelIdx = new ReadOnlyIndexImpl(this._relIdx);
  }
  
  Node createNode([Map<String,Object> props]){
    int count = this._next(Standard._NODE_COUNTER);
    Node n = new NodeImpl._internal(count, this);
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
  
  ReadOnlyIndex getRelationshipIndex() => this._readRelIdx;
  
  ReadOnlyIndex getNodeIndex() => this._readNodeIdx;
  
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
  
  bool isAutoIndex() => this._autoIndex || this._idxFields.length==0;
  
  /**
   * Generate a tree of depth and order(number of children per parent)
   * 2 < depth < 9
   * 0 < order < 5
   */
  Node generateTree([int depth = 4, order = 2]){
    if (depth < 2 || order < 0 || depth > 9 || order >5 )
      throw new ArgumentError(" Sane trees pls depth:$depth order:$order ");
    Node root = createNode();
    print (root);
    _tree([root], 1, depth, order);
    return root;
  }
  
  void _tree(List<Node> parents, num level, num maxLevel, int order){
    if (level >= maxLevel)
      return;
    level+=1;
    var children = [];
    for (Node parent in parents){
      for (int i = 0; i< order; i++) {
        Node n = createNode();
        parent.createRelationship(n);
        children.add(n);
      }
    }
    print(children);
    _tree(children,level,maxLevel,order);
  }
}
