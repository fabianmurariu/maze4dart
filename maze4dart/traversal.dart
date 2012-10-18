/**
 * Defines a path through the graph
 * it relies only on relationships but can give
 * out information about nodes as well
 */
class Path<T extends PropertyContainer> extends Iterable<T> {
  /**
   * A path is defined by the number of relationships
   */
  List<Relationship> _path = new List<Relationship>();
  
  /* weight of the path
   * by default adding a new relationship
   * to the path will increase the weight by 1
   * unless the relationship has a COST associated
   * property which then will be added to weight
   *  */
  num weight = 0.00;
  
  Node endNode() => this._path.length>0?this._path.last().getEndNode():null;
  
  Node startNode() => this._path.length>0?this._path[0].getStartNode():null;

  /**
   * Return the total number of relationships
   * the total number of nodes 
   */
  int length() => this._path.length;
  
  Relationship lastRelationship() => this._path.length>0?this._path.last():null;
  
  Relationship firstRelationship() => this._path.length>0?this._path[0]:null;
  
  /**
   * return Start Node, Rel, Node, ..., Node, Rel, End Node
   * this iterator is usable even if the path changes
   */
  Iterator<T> iterator() {
    return new Pipe<Relationship,T>(this._path.iterator(),
        (rel, hasNext) =>
          hasNext?[rel.getStartNode(),rel]:[rel.getStartNode(),rel,rel.getEndNode()]);
  }
  
  /**
   * return all nodes
   * this iterator is usable even if the path changes
   */
  Iterator<Node> nodes() { 
    return new Pipe<Relationship,Node>(this._path.iterator(),
      (rel,hasNext) =>
        hasNext?[rel.getStartNode()]:[rel.getStartNode(),rel.getEndNode()]);
  }
  
  Iterator<Relationship> relationships() => this._path.iterator();
  
  _addRelationship(Relationship rel) => this._path.add(rel); 
}

/**
 * Expand a path
 * return the relationships
 */
typedef Iterable<Relationship> Expander(Path path);

class Evaluator{
  static const int EXCLUDE_AND_CONTINUE = 0;
  static const int EXCLUDE_AND_PRUNE = 1;
  static const int INCLUDE_AND_CONTINUE = 2;
  static const int INCLUDE_AND_PRUNE = 3;
  const Evaluator();
}
