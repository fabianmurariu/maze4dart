/** 
 * a path is built on an old path + new relationships
 * every time we expand a node it will create 
 * new paths depending on how many relationships
 * are succesfuly expanded
 * */
class Path implements Iterable<Relationship>{

  /* a path must maintain length
   * this represents the number of
   * relationships in the path */
  int _length = 0;
  /* a path must maintain weight
   * this represents the sum of
   * the cost of each relationship
   * and it is equal to length when the
   * cost is 1 */
  int _weight = 0;
  
  /* all paths should start from 
   * a node */
  Node _startNode;
  
  /* the old path on top of which we are 
   * adding new relations */
  Path _oldPath;
  
  /* the first relationship is in the oldPaths */
  Relationship _firstRelationship;
  
  /* relationships additional to the previous Path */
  List<Relationship> _rels = [];
  
  Path._fromNode(Node n){
    this._startNode = n;
  }
  
  Path(Path oldPath, List<Relationship> newRels,[String costProp]){
    if (newRels == null || newRels.length <= 0)
      throw new ArgumentError("new Rels list cannot be empty or null");
    this._oldPath = oldPath;
    this._rels.addAll(newRels);
    this._firstRelationship = oldPath._firstRelationship == null?newRels[0]:oldPath._firstRelationship;
    this._length += (oldPath._length+newRels.length);
    if (costProp == null) {
      this._weight += (oldPath._weight+newRels.length);
    } else {
      int newcost = 0;
      /* this will fail if you mess up the property cost 
       * TODO: math.abs on property to ignore negative values*/
      newRels.forEach((rel) => (newcost+=rel.getProperty(costProp)));
      this._weight +=newcost;
    }
  }
  /** Utility to get the last relationship */
  Relationship lastRelationship() => this._rels.isEmpty()?null:this._rels.last();
  /** Utility to get the first relationship */
  Relationship firstRelationship() => this._firstRelationship;

  /* if first/last relationships are null then we pick _startNode
   * otherwise we pick endNode of lastRelationship
   * first/last rels should either be both null or both not null
   * otherwise something is wrong with the internal state */
  Node endNode()  {
    if (this.lastRelationship()==null && this._firstRelationship==null){
      return this._startNode;
    } else {
      return this.lastRelationship().getEndNode();
    }
  }
  /* if first/last relationships are null then we pick _startNode
   * otherwise we pick startNode of firstRelationship 
   * first/last rels should either be both null or both not null
   * otherwise something is wrong with the internal state */  
  Node startNode() {
    if (this.lastRelationship()==null && this._firstRelationship==null){
      return this._startNode;
    } else {
      return this._firstRelationship.getStartNode();
    }    
  }
  
  int length() => this._length;
  
  int weight() => this._weight;
  
  Iterator<Relationship> relationships() => this.iterator();
  
  Iterator<Node> nodes() => new Pipe<Relationship,Node>([this],
      (path,hasNext) {
        /*FIXME: figure out a way to do this lazy */
        var result = [path.startNode()];
        for (Relationship rel in path)
          result.add(rel.getEndNode());
        return result;
      });
  
  Iterator<Relationship> iterator() => new Pipe<Relationship,Relationship>([this._oldPath,this._rels].filter((v)=>v!=null),(v,hn)=>v);
  
}
