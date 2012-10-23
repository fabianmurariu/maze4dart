/** 
 * a path is built on a collection of paths
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
  
  Iterator<Node> nodes() => new Pipe<Relationship,Node>([this._oldPath,this._rels].filter((v)=>v!=null),
      (rel,hasNext) =>
          hasNext?[rel.getStartNode()]:[rel.getStartNode(),rel.getEndNode()]);
  
  Iterator<Relationship> iterator() => new Pipe<Relationship,Relationship>([this._oldPath,this._rels].filter((v)=>v!=null),(v,hn)=>v);
  
}

/**
 * Expand a path
 * return the relationships
 */
typedef Iterable<Relationship> Expander(Path path);

/**
 * Evaluates a path, if it is to be followed
 * or included in the final result
 */
typedef Evaluation Evaluator(Path path);

class Evaluation{
  static Evaluation EXCLUDE_AND_CONTINUE = new Evaluation._inner(false, true);
  static Evaluation EXCLUDE_AND_PRUNE = new Evaluation._inner(false, false);
  static Evaluation INCLUDE_AND_CONTINUE = new Evaluation._inner(true, true);
  static Evaluation INCLUDE_AND_PRUNE = new Evaluation._inner(true, false);
  
  /* true if the path is to be explored further */
  final bool _cont;
  /* True if the path will be included in the traversal result */
  final bool _include;
  
  Evaluation._inner(this._include, this._cont);
  
  bool toInclude() => this._include;
  
  bool toContinue() => this._cont;
  
  factory Evaluation.valueOf(bool include, bool cont) {
    switch (include) {
      case true:
        switch (cont){
          case true: return INCLUDE_AND_CONTINUE;
          case false: return INCLUDE_AND_PRUNE;
        }
        break;
      case false:
        switch (cont){
          case true: return EXCLUDE_AND_CONTINUE;
          case false: return EXCLUDE_AND_PRUNE;
        }
        break;      
    }
  }
}

abstract class OrderPolicy<T extends Path> implements Iterable<T>,Iterator<T>{
  Queue<Path> _inner = new Queue();
  Iterator<T>  iterator() => this;
  bool hasNext() => !this._inner.isEmpty();
  T next();
  /* we always addFirst but the Queue will removeLast First In Last Out
   * the Stack will remove first Last In First Out */
  void add(Iterable<Path> paths) {
    if (paths == null)
      throw new ArgumentError("Cannot add null paths");
    for (Path p in paths) { 
      this._inner.addFirst(p);
    }
  }
}

class QueueOrderPolicy extends OrderPolicy<Path>{
  Path next() {
    if (hasNext()) return this._inner.removeLast();
    else throw new NoMoreElementsException();
  }
}

class StackOrderPolicy extends OrderPolicy<Path>{
  Path next() {
    if (hasNext()) return this._inner.removeFirst();
    else throw new NoMoreElementsException();
  }  
}
/* Traverses a graph from start Node to
 * end Node, depending on order policy
 * and expander */
class Traversal{
  
  Expander _expander = (Path p) {
    Node n = p.endNode();
    return n.getRelationships(Direction.BOTH, DefaultRelationshipType.DEFAULT);
  };
  
  /**
   * Default evaluator outputs every path
   * and follows every path 
   */
  List<Evaluator> _evaluators = [(Path p) => (Evaluation.INCLUDE_AND_CONTINUE) ];
  
  Traversal addEvaluator(Evaluator e) {
    _evaluators.add(e); return this;
  }
  
  /**
   * All evaluators need to agree
   * on the path include/continue 
   */
  Evaluation _executeEvaluators(Path p){
    /* for and 'true' has no impact on the
     * outcome of the expression, if a false expression
     * is & with true the result is still false and
     * if a true expression is & true then it is still true*/
    bool include = true; 
    bool cont = true;
    this._evaluators.forEach((eval) {
      Evaluation e = eval(p);
      include = include && e.toInclude();
      cont = cont && e.toContinue();
    });
    return new Evaluation.valueOf(include, cont);
  }
  
  /* the order in which the expanded nodes
   * are sorted, queue for BFS, stack for DFS
   * priority-queue for various shortest path */
  OrderPolicy<Path> _order;
  
  
  Traversal customExpander(Expander expander) {
    this._expander = expander;
    return this;
  }
  
  Traversal expander([RelationshipType type = DefaultRelationshipType.DEFAULT,
      Direction direction=Direction.OUTGOING]){
    /*FIXME: add property based expander here */
    _expander = (Path p) {
      Node n = p.endNode();
      return n.getRelationships(direction, type);
    };
  }
  
  /** BFS traversal, uses a QueueOrderPolicy */
  Traversal breadthFirst(){
    this._order = new QueueOrderPolicy();
    return this;
  }
  
  /** DFS traversal, uses a StackOrderPolicy */
  Traversal depthFirst(){
    this._order = new StackOrderPolicy();
    return this;
  }
  
  /** Custom order policy */
  Traversal orderPolicy(OrderPolicy<Path> op){
    this._order = op;
    return this;
  }
  
  /**
   * Start traversing and return a Iterator
   * with all available paths, sorted by weight
   * You can start from one node or from more than one
   */
  Iterable<Path> start(Node node){
    var result = new List<Path>();
    if (node == null)
      throw new ArgumentError("start node cannot be null");
    /* first set up the explored set, and add the first path */
    Set<Node> explored = new Set(); /* all nodes that were explored*/
    Path start = new Path._fromNode(node);
    _order.add([start]);
    while(_order.hasNext()){
      /* expand the next path as selected by the order policy */
      Path currentPath = _order.next();
      Evaluation e = _executeEvaluators(currentPath);
      /* we 'continue' the loop we do NOT continue onto this path */
      if (!e.toContinue()) continue; 
      /* include this path into results */
      if (e.toInclude()) result.add(currentPath); 
      Node currentNode = currentPath.endNode();
      if (!explored.contains(currentNode)){
        /* we have not evaluated the end node of the
         * current Path */
        explored.add(currentNode);
        Iterable<Relationship> expanded = _expander(currentPath);
        /* We create new paths similar to currentPath but each
         * with the new expanded relationship added to it 
         * then add them to the OrderPolicy, do not
         * add them if the other node is already explored */
        for(Relationship rel in expanded){
          Node aNode = rel.getOtherNode(currentNode);
          if (!explored.contains(aNode)){
            _order.add([new Path(currentPath,[rel])]);
          }
        }
      }
    }
    return result;
  }
}