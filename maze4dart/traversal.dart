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
   */
  Iterator<T> iterator() {
    return new Pipe<Relationship,T>(this._path.iterator(),
        (rel, hasNext) =>
          hasNext?[rel.getStartNode(),rel]:[rel.getStartNode(),rel,rel.getEndNode()]);
  }
  
  Iterator<Node> nodes() { 
    return new Pipe<Relationship,Node>(this._path.iterator(),
      (rel,hasNext) =>
        hasNext?[rel.getStartNode()]:[rel.getStartNode(),rel.getEndNode()]);
  }
  
  Iterator<Relationship> relationships() => this._path.iterator();
}

