maze4dart
=========

In memory property graph library written in Dart
------------------------------------------------

Features:
*	Assign any property to nodes
*	Assign any property to relationships
*	Graph is by default directed
*	Nodes can filter relationships by type and properties
*	Lookup nodes/relationships by id or indexed properties
*	Automatic index on declared properties
*	Simple Index implementation for manual indexing
*	Versatile traversal API inspired by neo4j

Create a simple graph, look for relationships via "knows" property:
Node Rels
1 	 2 4
2	 1 4
3	 1
4	 2 3
Code:
```java
	  Graph graph = new GraphImpl(["knows"]);
	  /* 4 nodes */
      Node n1 = graph.createNode();
      Node n2 = graph.createNode();
      Node n3 = graph.createNode();
      Node n4 = graph.createNode();
      /* 7 edges */
      Relationship rel1 = n1.createRelationship(n2, props:{"knows":2});
      Relationship rel2 = n2.createRelationship(n1, props:{"knows":1});
      Relationship rel3 = n2.createRelationship(n4, props:{"knows":4});
      Relationship rel4 = n4.createRelationship(n3, props:{"knows":3});
      Relationship rel5 = n4.createRelationship(n2, props:{"knows":2});
      Relationship rel6 = n3.createRelationship(n1, props:{"knows":1});
      Relationship rel7 = n1.createRelationship(n4, props:{"knows":4});
      /* get relationships by INCOMING/OUTGOING*/
      n1.getRelationships(Direction.OUTGOING);//[rel1,rel7];
      n1.getRelationships(Direction.INCOMING);//[rel2,rel6];
      n2.getRelationships(Direction.OUTGOING);//[rel2,rel3];
      n2.getRelationships(Direction.INCOMING);//[rel1,rel5];
      n3.getRelationships(Direction.OUTGOING);//[rel6];
      n3.getRelationships(Direction.INCOMING);//[rel4];
      n4.getRelationships(Direction.OUTGOING);//[rel4,rel5];
      n4.getRelationships(Direction.INCOMING);//[rel3,rel7];
      /* autoindex */
      g.getRelationshipIndex().get("knows", 1);//[rel2,rel6]);
      g.getRelationshipIndex().get("knows", 2);//[rel1,rel5]);
      g.getRelationshipIndex().get("knows", 3);//[rel4]);
      g.getRelationshipIndex().get("knows", 4);//[rel3,rel7]);
```
