#import('core.dart');
#import("/Applications/dart/dart-sdk/pkg/unittest/unittest.dart");

class TestRelationshipType implements RelationshipType{
  const TestRelationshipType();
}

main (){
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
      print("stophere");
      n2.delete();
      /* all relationships going in and out of n2 should be gone */
      expect(graph.getRelationshipIndex().get("four", 1),[]);
      expect(graph.getRelationshipIndex().get("four", 2),[]);
      expect(graph.getRelationshipIndex().get("four", 3),[]);
      expect(graph.getRelationshipIndex().get("four", 5),[]);
      /* calls into rel 1,2,3,5 should be invalid */
    });
  });
  
  group('Pipe',(){
    test("no change",(){
      var initial = [1,2,3,4,5,6,8,9];
      Pipe p = new Pipe(initial.iterator(), (v,hn) => [v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,initial);
    });
    test("squared",(){
      var initial = [1,2,3,4,5,6,8,9];
      var expected = [1,4,9,16,25,36,64,81];
      Pipe p = new Pipe(initial.iterator(), (v,hn) => [v*v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,expected);
    });
    test("no change and squared",(){
      var initial = [1,2,3,4,5,6,8,9];
      var expected = [1,1,2,4,3,9,4,16,5,25,6,36,8,64,9,81];
      Pipe p = new Pipe(initial.iterator(), (v,hn) => [v, v*v]);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,expected);
    });
    test("empty",(){
      var initial = [1,2,3,4,5,6,8,9];
      Pipe p = new Pipe(initial.iterator(), (v, hn) => []);
      var result = [];
      while (p.hasNext()){
        result.add(p.next());
      }
      expect(result,[]);
    });
    
  });

}
