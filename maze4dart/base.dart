interface PropertyContainer {
  Object getProperty(String name);
  void setProperty(String name, Object value);
  Collection<String> getKeys();
  bool hasProperty(String key);
  Object removeProperty(String key);
}
/**
 * Describes a node
 * Every node has a list of relationships
 * that both point to it and start from it
 */
interface Node extends PropertyContainer{
  /**
   * Creates a relationship with this node
   * as (Start Node) and having "n" as (End Node)
   * It specifies the type of the relationship
   * as well as associated properties
   */
  Relationship createRelationship(Node n, [RelationshipType type,Map<String,Object> props]);
  /**
   * Returns the Id of the node
   */
  int getId();
  /**
   * Removes the node and all the relationships
   * associated with it, both pointing at it and
   * pointing away from it
   */
  void delete();
  /**
   * Returns a list of relationships of this node, filters
   * by direction and type.
   */
  List<Relationship> getRelationships([Direction direction = Direction.BOTH, 
      RelationshipType type= DefaultRelationshipType.DEFAULT]);
  /**
   * Checks if the node as at least one relationship
   * of "type" and/or "direction"
   */
  bool hasRelationships([Direction direction = Direction.BOTH, RelationshipType type]);
  
  void _removeRelationship(Relationship r, [int index]);

  void _addRelationship(Relationship rel);
}
/**
 * Describes a relationship
 * Every relationship is directed but
 * can be traversed in both directions
 * (Start Node) --> (End Node)
 */
interface Relationship extends PropertyContainer{
  /**
   * Removes the relationship from every node,
   * from the graph and from the internal index
   */
  void delete([Node callingNode]);
  /**
   * Returns the node towards which this relationship
   * is pointing (End Node)
   */
  Node getEndNode();
  /**
   * Returns the id of the relationship
   */
  int getId();
  /**
   * Returns a list of the nodes
   * involved in this relation
   * [(Start node), (End node)]
   */
  List<Node> getNodes();
  /**
   * Utility method, returns the
   * other node of the relation given
   * node n
   */
  Node getOtherNode(Node n);
  
  /**
   * Returns the node that starts the relationship
   * (Start Node)
   */
  Node getStartNode();
  /**
   * Returns the type of the relationship
   */
  RelationshipType getType();
  /**
   * Checks if the type of the relationship
   * matches "type"
   */
  bool isType(RelationshipType type);
}

/**
 * Can assign a type to the Relationship
 */
interface RelationshipType {

}
/**
 * When not specified all relationships are 
 * defaulted to DefaultRelationshipType
 */
class DefaultRelationshipType implements RelationshipType{
  static const DEFAULT = const DefaultRelationshipType();
  const DefaultRelationshipType();
}
/**
 * Every time a relationship is created
 * it will be added both to the start node
 * and the end-node, however the initial direction
 * is retained, this allows to traverse the graph
 * in both directions
 */
class Direction {
  static const INCOMING = const Direction(0);
  static const OUTGOING = const Direction(1);
  static const BOTH = const Direction(2);
  
  final int _inner;
  const Direction(this._inner);
}

class Standard {
  /**
   * Default cost property
   * used to traverse graph
   * in algorithms that use cost 
   */
  static const COST = "maze4dart:cost";
  /**
   * the default field used
   * to index the node id
   * in the internal index
   */
  static const _NODE_ID_INDEX_FIELD = "node:id:idx";
  /**
   * the default field used
   * to index the relationship id
   * in the internal index
   */
  static const _REL_ID_INDEX_FIELD = "rel:id:idx";
  /**
   * Marker used to select the internal
   * graph node counter
   */
  static const _NODE_COUNTER = "maze4dart:node:counter";
  /**
   * Merker used to select the internal
   * graph relationship counter
   */
  static const _REL_COUNTER = "maze4dart:rel:counter";
}

/**
 * Index that doesn't allow you
 * to change existing values,
 * you can add or put and object but
 * cannot change existing ones
 */
interface ReadOnlyIndex<T extends PropertyContainer>{
  /**
   * Returns the objects associated with
   * the key/value pair
   */
  List<T> get(String key, Object value);
  
}
interface Index<T extends PropertyContainer> extends ReadOnlyIndex<T>{
  /**
   * Add object to the key/value multimap
   * doesn't care if there is something already 
   * there, it just appends the object
   * 
   * If key/value are not present then we go 
   * through every property of object
   * and index it if configured
   */
  void add(T object, [String key, Object value]);

  /**
   * Adds the Object to the Index
   * at key/value location only if
   * there is no previous entry
   */
  List<T> putIfAbsent(T object, String key, Object value);
  /**
   * removes the object associated with the key/value pair
   */
  void remove(T object,[String key, Object value]);
  /**
   * Removes every entry from the index
   */
  void clear();
}
/**
 * Core interface for the graph,
 * the place where all the nodes are created,
 * all Indexes are kept,
 * provides fast and easy lookup by Id for both Nodes and Relationships
 */
interface Graph {
  /**
   * Creates a node
   * if a map of default properties is
   * provided they they are added to
   * the Node
   * If a list of property names are provided
   * if configured they will be picked
   * up by the indexer if it is available 
   */
  Node createNode([Map<String,Object> props]);
  /**
   * Returns the Node with id,
   * null if there is none
   */
  Node getNodeById(int id);
  /**
   * Returns the relationship with id,
   * null if there is none
   */
  Relationship getRelationshipById(int id);
  
  /**
   * Returns the default node index
   * If no index is required then
   * configure the graph to autoindex=false
   */
  ReadOnlyIndex getNodeIndex();
  
  /**
   * Returns the default relationship index
   * If no index is required then
   * configure the graph to autoindex=false
   * 
   */
  ReadOnlyIndex getRelationshipIndex(); 

  /**
   * Returns true if relationships and nodes
   * are automaticaly indexed, this means 
   * that other properties than id are indexed */
  bool isAutoIndex();
  
  /**
   * returns and increments
   * the internal counter
   */
  int _next(String counter);
  
}

class IllegalStateError implements Error{
  final message;

  /** The [message] describes the erroneous argument. */
  const IllegalStateError([this.message = ""]);

  String toString() {
    if (message != null) {
      return "Illegal argument(s): $message";
    }
    return "Illegal argument(s)";
  }  
}
