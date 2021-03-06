#import('core.dart');
#import("/Applications/dart/dart-sdk/pkg/unittest/unittest.dart");

class TestRelationshipType implements RelationshipType{
  const TestRelationshipType();
}



main (){
  group('Traversal',(){
    GraphImpl g = new GraphImpl([]);
    Node root = g.generateTree();
    var eval = assertNodePaths(List<List<int>> expectedNodes, Iterable<Path> traversalResult,[bool verify=true]){
      int i = 0;
      for (Path path in traversalResult){
        /*we are counting nodes but the path.length() is the number of relationships*/
        if (verify)
          expect(path.length(),expectedNodes[i].length-1);
        else
          print("idx:$i length : ${path.length()} expected length:${expectedNodes[i].length-1}");
        Iterator<Node> nodes = path.nodes();
        int j = 0;
        while(nodes.hasNext()){
          Node node = nodes.next();
          if (verify)
            expect(node.getId(),expectedNodes[i][j]);
          else
            print(" result ${node}, expected ($i,$j):${expectedNodes[i][j]}");
          j++;
        }
        i++;
      }
    };
    /* the tree is a directed graph where the parrent points to the children:
     *               n0(root)
     *              /        \ 
     *            n1           n2
     *          /    \        /    \
     *        n3      n4     n5      n6
     *       /\       /\     /\      /\
     *     n7  n8   n9 n10 n11 n12 n13 n14
     *             */
    test("bfs_search",(){
      Node end = g.getNodeById(12);
      Traversal t = new Traversal().breadthFirst().addEvaluator((Path p) {
        if (p.endNode() == end)
          return Evaluation.INCLUDE_AND_CONTINUE; /* only include the path with the end node */
        return Evaluation.EXCLUDE_AND_CONTINUE;
      });
      Iterable<Path> traversal = t.traverse(root);
      eval([[0,2,5,12]],traversal,true);
    });

    test("dfs_traversal",(){
      Traversal t = new Traversal().depthFirst();
      Iterable<Path> traversal = t.traverse(root);
      eval([[0],
            [0,2],
            [0,2,6],
            [0,2,6,14],[0,2,6,13],
            [0,2,5],
            [0,2,5,12],[0,2,5,11],
            [0,1],
            [0,1,4],
            [0,1,4,10],[0,1,4,9],
            [0,1,3],
            [0,1,3,8],[0,1,3,7]],traversal,true);
    });
    test("bfs_traversal",(){
      Traversal t = new Traversal().breadthFirst();
      Iterable<Path> traversal = t.traverse(root);
      eval([[0],
            [0,1],[0,2],
            [0,1,3],[0,1,4],[0,2,5],[0,2,6],
            [0,1,3,7],[0,1,3,8],[0,1,4,9],[0,1,4,10],[0,2,5,11],[0,2,5,12],[0,2,6,13],[0,2,6,14]],traversal,true);
    });   
  });
  group('Index',() {
    test('add_get',(){
      /* specify the key/value where you want to index */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      idx.add(pc, "one", 3);
      expect(idx.get("one", 3),[pc]);
    });
    test('add_null_key',(){
      /* test stuff here */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      expect((){idx.add(pc, null, 3);},throwsA(new isInstanceOf<IllegalArgumentException>()));
    });
    test('add_null_value',(){
      /* test stuff here */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      expect((){idx.add(pc, "one", null);},throwsA(new isInstanceOf<IllegalArgumentException>()));
    });    
    test('put_if_absent',(){
      /* test stuff here */
      /* specify the key/value where you want to index */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      expect(idx.putIfAbsent(pc,"one",3),[]);
      /* make sure we did not change stuff */
      expect(idx.get("one", 3),[pc]);
    });
    test('put_if_absent_present',(){
      /* test stuff here */
      /* specify the key/value where you want to index */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      idx.add(pc, "one", 3);
      expect(idx.get("one", 3),[pc]);
      expect(idx.putIfAbsent(pc,"one",3),[pc]);
      /* make sure we did not change stuff */
      expect(idx.get("one", 3),[pc]);
    });
    test('add_get_implicit',(){
      /* relies on the inner values of the container
       * to autoindex */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one", 2);
      idx.add(pc);
      expect(idx.get("one",2),[pc]);
    });

    test('add_get_implicit_multiple',(){
      /* relies on the inner values of the container
       * to autoindex and now allows multiple values */
      Index idx = new IndexImpl(["one","two"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one", 2);
      pc.setProperty("two", 2);
      pc.setProperty("three", 2);
      idx.add(pc);
      expect(idx.get("one",2),[pc]);
      expect(idx.get("two",2),[pc]);
      expect(idx.get("three", 2),isEmpty);
      /* the third property is not indexable */
    });
    test('add_get_remove_get',(){
      /* relies on the inner values of the container
       * to autoindex and now allows multiple values */
      Index idx = new IndexImpl(["one","two"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one", 2);
      pc.setProperty("two", 2);
      idx.add(pc);
      expect(idx.get("one",2),[pc]);
      expect(idx.get("two",2),[pc]);
      idx.remove(pc, "one", 2);
      expect(idx.get("one", 2),isEmpty);
      expect(idx.get("two", 2),[pc]);
    });
    
    test('add_get_remove_same_key',(){
      /* add a property with two values
       * on the same key, remove one value
       * check the other one is still intact*/
      Index idx = new IndexImpl(["one","two"]);
      PropertyContainer pc = new PropertyContainerImpl();
      idx.add(pc,"one",2);
      idx.add(pc,"one","3");
      expect(idx.get("one",2),[pc]);
      expect(idx.get("one","3"),[pc]);
      idx.remove(pc, "one", "3");
      expect(idx.get("one", "3"),isEmpty);
      expect(idx.get("one", 2),[pc]);
    });
    test('add_remove_object_complete',(){
      /* add a property with two values
       * on the same key, remove one value
       * check the other one is still intact*/
      Index idx = new IndexImpl(["one","two","three"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one",2);
      pc.setProperty("two","3");
      pc.setProperty("three",4.15);
      pc.setProperty("four",new Object());
      idx.add(pc);
      expect(idx.get("one",2),[pc]);
      expect(idx.get("two","3"),[pc]);
      expect(idx.get("three",4.15),[pc]);
      expect(idx.get("four",new Object()),isEmpty);      
      idx.remove(pc);
      expect(idx.get("one",2),isEmpty);
      expect(idx.get("two","3"),isEmpty);
      expect(idx.get("three",4.15),isEmpty);
      expect(idx.get("four",new Object()),isEmpty);      
    });    
    test('add_remove_multiple_object_complete',(){
      /* add a property with two values
       * on the same key, remove one value
       * check the other one is still intact*/
      Index idx = new IndexImpl(["one","two","three"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one",2);
      pc.setProperty("two","3");
      pc.setProperty("three",4.15);
      pc.setProperty("four",new Object());
      PropertyContainer pc2 = new PropertyContainerImpl();
      pc2.setProperty("one",3);
      pc2.setProperty("two","3");
      pc2.setProperty("three",4.15);
      pc2.setProperty("four",new Object());
      idx.add(pc);
      idx.add(pc2);
      expect(idx.get("one",2),[pc]);
      expect(idx.get("two","3"),[pc,pc2]);
      expect(idx.get("three",4.15),[pc,pc2]);
      expect(idx.get("four",new Object()),isEmpty);      
      idx.remove(pc);
      idx.remove(pc2);
      expect(idx.get("one",2),isEmpty);
      expect(idx.get("one",3),isEmpty);
      expect(idx.get("two","3"),isEmpty);
      expect(idx.get("three",4.15),isEmpty);
      expect(idx.get("four",new Object()),isEmpty);      
    });     
  });
  group('Graph 1',(){
    Graph graph = new GraphImpl(["one","two","three","four"]);
    test('create_node_multi_props_delete',(){
      Node n = graph.createNode({"one":1,"two":4.15,"four":"four"});
      expect(0,n.getId());
      expect(n,graph.getNodeById(0));
      ReadOnlyIndex idx = graph.getNodeIndex();
      expect(idx.get("one", 1),[n]);
      expect(idx.get("two", 4.15),[n]);
      expect(idx.get("four","four"),[n]);
      expect(idx.get("three", 0),isEmpty);
      n.delete();
      expect(graph.getNodeById(0),isNull);
      expect(idx.get("one", 1),isEmpty);
      expect(idx.get("two", 4.15),isEmpty);
      expect(idx.get("four","four"),isEmpty);      
    });
    test('create_and_delete_node',(){
      Node n = graph.createNode({"one":2});
      expect(n.getId(),1);
      expect(graph.getNodeById(1),n);
      ReadOnlyIndex idx = graph.getNodeIndex();
      expect(idx.get("one", 2),[n]);
      n.delete();
      expect(idx.get("one", 2),isEmpty);
      expect(graph.getNodeById(1),isNull);
    });
    test('create_2_nodes_and_relationship_check_delete',(){
      var test_bool = true;
      Node n1 = graph.createNode();
      Node n2 = graph.createNode();
      int n1Id = n1.getId();
      int n2Id = n2.getId();
      Relationship rel = n1.createRelationship(n2);
      int relId = rel.getId();
      expect(rel.getStartNode(),n1);
      expect(rel.getEndNode(),n2);
      expect(rel.getOtherNode(n2),n1);
      expect(rel.getOtherNode(n1),n2);
      expect(DefaultRelationshipType.DEFAULT,rel.getType());
      expect(graph.getNodeById(n1Id),n1);
      expect(graph.getNodeById(n2Id),n2);
      expect(graph.getRelationshipById(relId),rel);
      n1.delete();
      n2.delete();
      expect(() => rel.getStartNode(),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(() => rel.getEndNode(),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(() => rel.getOtherNode(n2),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(() => rel.getOtherNode(n1),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(() => rel.delete(),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(() => rel.getType(),throwsA(new isInstanceOf<IllegalStateError>()));
      expect(graph.getNodeById(n1Id),isNull);
      expect(graph.getNodeById(n2Id),isNull);
      expect(graph.getRelationshipById(relId),isNull);
    });

    test('create_rel_autoindex',(){
      Node n1 = graph.createNode();
      Node n2 = graph.createNode();
      int n1Id = n1.getId();
      int n2Id = n2.getId();
      Relationship rel = n1.createRelationship(n2,props:{"one":2,"two":"two","five":4.15});
      int relId = rel.getId();
      expect(graph.getRelationshipById(relId),rel);
      expect(graph.getRelationshipIndex().get("one", 2),[rel]);
      expect(graph.getRelationshipIndex().get("two", "two"),[rel]);
      expect(graph.getRelationshipIndex().get("five", 4.15),isEmpty);
      n1.delete();
      n2.delete();
      expect(graph.getRelationshipById(relId),isNull);
      expect(() => rel.getStartNode(),throwsA(new isInstanceOf<IllegalStateError>()));
    });
    
    test('create_graph_filter_rel_on_direction_delete',(){
      /*4 nodes */
      Node n1 = graph.createNode();
      Node n2 = graph.createNode();
      Node n3 = graph.createNode();
      Node n4 = graph.createNode();
      /*7 edges */
      Relationship rel1 = n1.createRelationship(n2, props:{"four":1});
      Relationship rel2 = n2.createRelationship(n1, props:{"four":2});
      Relationship rel3 = n2.createRelationship(n4, props:{"four":3});
      Relationship rel4 = n4.createRelationship(n3, props:{"four":4});
      Relationship rel5 = n4.createRelationship(n2, props:{"four":5});
      Relationship rel6 = n3.createRelationship(n1, props:{"four":6});
      Relationship rel7 = n1.createRelationship(n4, props:{"four":7});
      /*check all edges are correct */
      expect(n1.getRelationships(Direction.OUTGOING),[rel1,rel7]);
      expect(n1.getRelationships(Direction.INCOMING),[rel2,rel6]);
      expect(n2.getRelationships(Direction.OUTGOING),[rel2,rel3]);
      expect(n2.getRelationships(Direction.INCOMING),[rel1,rel5]);
      expect(n3.getRelationships(Direction.OUTGOING),[rel6]);
      expect(n3.getRelationships(Direction.INCOMING),[rel4]);
      expect(n4.getRelationships(Direction.OUTGOING),[rel4,rel5]);
      expect(n4.getRelationships(Direction.INCOMING),[rel3,rel7]);
      /*get them by property from inner index */
      expect(graph.getRelationshipIndex().get("four", 1),[rel1]);
      expect(graph.getRelationshipIndex().get("four", 2),[rel2]);
      expect(graph.getRelationshipIndex().get("four", 3),[rel3]);
      expect(graph.getRelationshipIndex().get("four", 4),[rel4]);
      expect(graph.getRelationshipIndex().get("four", 5),[rel5]);
      expect(graph.getRelationshipIndex().get("four", 6),[rel6]);
      expect(graph.getRelationshipIndex().get("four", 7),[rel7]);
      n2.delete();
      /* all relationships going in and out of n2 should be gone */
      expect(graph.getRelationshipIndex().get("four", 1),[]);
      expect(graph.getRelationshipIndex().get("four", 2),[]);
      expect(graph.getRelationshipIndex().get("four", 3),[]);
      expect(graph.getRelationshipIndex().get("four", 5),[]);
      /* calls into rel 1,2,3,5 should be invalid */
    });
    test('property_lookup',(){
      Graph g = new GraphImpl(["knows"]);
      /*4 nodes */
      Node n1 = g.createNode();
      Node n2 = g.createNode();
      Node n3 = g.createNode();
      Node n4 = g.createNode();
      /*7 edges */
      Relationship rel1 = n1.createRelationship(n2, props:{"knows":2});
      Relationship rel2 = n2.createRelationship(n1, props:{"knows":1});
      Relationship rel3 = n2.createRelationship(n4, props:{"knows":4});
      Relationship rel4 = n4.createRelationship(n3, props:{"knows":3});
      Relationship rel5 = n4.createRelationship(n2, props:{"knows":2});
      Relationship rel6 = n3.createRelationship(n1, props:{"knows":1});
      Relationship rel7 = n1.createRelationship(n4, props:{"knows":4});
      /* autoindex */
      expect(g.getRelationshipIndex().get("knows", 1),[rel2,rel6]);
      expect(g.getRelationshipIndex().get("knows", 2),[rel1,rel5]);
      expect(g.getRelationshipIndex().get("knows", 3),[rel4]);
      expect(g.getRelationshipIndex().get("knows", 4),[rel3,rel7]);
    });
  });
  
  group('Pipe',(){
    test("no change",(){
      var initial = [1,2,3,4,5,6,8,9];
      Pipe p = new Pipe(initial, (v,hn) => [v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,initial);
    });
    test("squared",(){
      var initial = [1,2,3,4,5,6,8,9];
      var expected = [1,4,9,16,25,36,64,81];
      Pipe p = new Pipe(initial, (v,hn) => [v*v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,expected);
    });
    test("no change and squared",(){
      var initial = [1,2,3,4,5,6,8,9];
      var expected = [1,1,2,4,3,9,4,16,5,25,6,36,8,64,9,81];
      Pipe p = new Pipe(initial, (v,hn) => [v, v*v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,expected);
    });
    test("empty",(){
      var initial = [1,2,3,4,5,6,8,9];
      Pipe p = new Pipe(initial, (v, hn) => []);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,[]);
    });
    
    test("incremental",(){
      var initial = [];
      Pipe p = new Pipe.wrap(initial);
      for (int i = 0; i< 5; i++ ) {
        p = new Pipe([p,[i]],(v, hn) => v);
      }
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,[0,1,2,3,4]);
    });
    
  });
  
}
