#import('core.dart');
#import("/Applications/dart/dart-sdk/pkg/unittest/unittest.dart");


main (){
  group('Index',() {
    test('add_get',(){
      /* specify the key/value where you want to index */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      idx.add(pc, "one", 3);
      expect([pc],idx.get("one", 3));
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
    });
    test('add_get_implicit',(){
      /* relies on the inner values of the container
       * to autoindex */
      Index idx = new IndexImpl(["one"]);
      PropertyContainer pc = new PropertyContainerImpl();
      pc.setProperty("one", 2);
      idx.add(pc);
      expect([pc],idx.get("one",2));
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
      expect([pc],equals(idx.get("one",2)));
      expect([pc],idx.get("two",2));
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
      expect([pc],equals(idx.get("one",2)));
      expect([pc],equals(idx.get("two",2)));
      idx.remove(pc, "one", 2);
      expect(idx.get("one", 2),isEmpty);
      expect([pc],equals(idx.get("two", 2)));
    });
    
    test('add_get_remove_same_key',(){
      /* add a property with two values
       * on the same key, remove one value
       * check the other one is still intact*/
      Index idx = new IndexImpl(["one","two"]);
      PropertyContainer pc = new PropertyContainerImpl();
      idx.add(pc,"one",2);
      idx.add(pc,"one","3");
      expect([pc],equals(idx.get("one",2)));
      expect([pc],equals(idx.get("one","3")));
      idx.remove(pc, "one", "3");
      expect(idx.get("one", "3"),isEmpty);
      expect([pc],equals(idx.get("one", 2)));
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
      expect([pc],equals(idx.get("one",2)));
      expect([pc],equals(idx.get("two","3")));
      expect([pc],equals(idx.get("three",4.15)));
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
      expect([pc],equals(idx.get("one",2)));
      expect([pc,pc2],equals(idx.get("two","3")));
      expect([pc,pc2],equals(idx.get("three",4.15)));
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
    Graph graph = new GraphImpl(true, ["one","two","three","four"]);
    test('create_node',(){
      Node n = graph.createNode({"one":1,"two":4.15,"four":"four"});
      expect(0,n.getId());
      expect(n,graph.getNodeById(0));
      AddOnlyIndex idx = graph.getNodeIndex();
      expect([n],idx.get("one", 1));
      expect([n],idx.get("two", 4.15));
      expect([n],idx.get("four","four"));
      expect(idx.get("three", 0),isEmpty);
    });
    test('create_and_delete_node',(){
      Node n = graph.createNode({"one":2});
      expect(1,n.getId());
      expect(n,graph.getNodeById(1));
      AddOnlyIndex idx = graph.getNodeIndex();
      expect([n],idx.get("one", 2));
      n.delete();
      expect(idx.get("one", 2),isEmpty);
      expect(graph.getNodeById(1),isNull);
    });
    test('create_index_and_delete_node_FAIL',(){
      Node n = graph.createNode({"one":2});
      expect(2,n.getId());
      expect(n,graph.getNodeById(2));
      AddOnlyIndex idx = graph.getNodeIndex();
      expect([n],idx.get("one", 2));
      expect(idx.putIfAbsent(n, "two", 2),isNull);
      n.delete();
      expect(idx.get("one", 2),isEmpty);
      expect(graph.getNodeById(3),isNull);
      /* fail, we need to register callbacks
       * into delete or something */
      expect(idx.get("two", 2),isEmpty);
    });

  });

}
