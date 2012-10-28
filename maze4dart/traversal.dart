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

/**
 * Evaluates if the currentPath and the next Relationship
 * are unique in different contexts
 * 
 * Can be globaly unique, path unique
 * can be a Node or a Relationship
 */
class Unique{
  final Set<PropertyContainer> _nodes = new Set();
  
  Unique([List<PropertyContainer> initial]){
    if (initial != null)
      _nodes.addAll(initial);
  }
  
  bool checkUnique(Path path, Relationship nextRel){
    Node n = path.endNode();
    Node checkMe = nextRel.getOtherNode(n);
    if (this._nodes.contains(checkMe)) return false;
    this._nodes.add(checkMe);
    return true;
  }
}

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
  
  Unique _unique = new Unique();
  
  Traversal addEvaluator(Evaluator e) {
    _evaluators.add(e); return this;
  }
  
  /**
   * Adds a check for uniqueness
   * the defaul is a global node checker
   * that ensures that nodes are explored only once
   */
  Traversal addUniqueCheck(Unique unique){
    _unique = unique; return this;
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
  OrderPolicy<Path> _order = new StackOrderPolicy();
  
  
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
  
  Iterable<Path> traverse(Node start){
    Path firstPath = new Path._fromNode(start);
    this._order.add([firstPath]);
    this._unique = new Unique([start]);
    return new Traverser2._inner(this);
  }
}

class Traverser2 implements Iterable<Path>{
  
  final Traversal _traversal;
  
  Iterable<Path> explorer(Path path, bool hasNext) {
    var nextPath = [];
    var currentPath = path;
    /* Evaluate the first path from the Pipe */
    Evaluation e = _traversal._executeEvaluators(currentPath);
    /* if we are allowed we include we add to return object */
    if (e.toInclude())
      nextPath.add(currentPath);
    /* If we are not allowed to continue then we
     * evaluate the paths according to the configured 
     * evaluators until we find a path
     * that we are allowed to continue on */
    while (!e.toContinue() && _traversal._order.hasNext()){
      currentPath = _traversal._order.next();
      e = _traversal._executeEvaluators(currentPath);
    }
    if (!e.toContinue()) /* we could not find anything to continue on*/
      return nextPath;
    
    /* expand the current path */
    Iterable<Relationship> expanded = _traversal._expander(currentPath);
    for (Relationship rel in expanded){
      /* We create new paths similar to currentPath but each
       * with the new expanded relationship added to it 
       * then add them to the OrderPolicy, do not
       * add them if the other node is already explored */
      if (_traversal._unique.checkUnique(currentPath,rel)){
        _traversal._order.add([new Path(currentPath,[rel])]);
      }
    }
    return nextPath;
  }
  Traverser2._inner(this._traversal);
 
  Iterator<Path> iterator() => new Pipe(_traversal._order,explorer);
  
}