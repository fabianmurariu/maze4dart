/**
 * The external processing function
 * gets two params, 
 *  o : the object to be processed
 *  hasNext: information if we are at the end of the incoming stream
 */
typedef Iterable<OUT> Process<IN,OUT>(IN o, bool hasNext);

/**
 * Decorate an iterator,
 * on every next() call the clojure, it will
 * process the value and return its own
 * result which can be a single value or multiple
 * 
 * Inspired by https://github.com/tinkerpop/pipes
 * but with the twist that the processing entity
 * itself will return an Iterator (one or more values)
 */
class Pipe<IN,OUT> implements Iterator<OUT>,Iterable<OUT>{
  final Iterator<IN> _wrapped;
  OUT _nextEnd;
  OUT _currentEnd;
  Iterator<OUT> _nextResult;
  final Process _proc;
  bool _available = false;
  
  Pipe.wrap(Iterable<IN> iterable):this._proc=((v,hn)=>[v]),this._wrapped=iterable.iterator();
  
  Pipe(Iterable<IN> iterable, Process proc):
    this._proc=proc,
    this._wrapped=iterable.iterator();
  
  OUT next(){
    if (this._available) {
      this._available = false;
      return (this._currentEnd = this._nextEnd);
    } else {
      return (this._currentEnd = this.processNextElement());
    }
  }
  
  bool hasNext(){
    if (this._available) return true;
    else {
      try{
        this._nextEnd = processNextElement();
        return (this._available = true);
      } on NoMoreElementsException catch(e){
        return this._available = false;
      }
    }
  }
  
  /**
   * Gets the next element in the returning iterator
   */
  OUT processNextElement() {
    /* loop until you get a iterator with elements */
    while (_nextResult == null || !this._nextResult.hasNext()) {
      this._nextResult = processNext();
      if (this._nextResult == null) throw new ArgumentError(" null Iterator returned ");
    }
    return this._nextResult.next();
  }
  /**
   * better to return an empty iterator
   * than a null one
   */
  Iterator<OUT> processNext() { 
    var nxt = this._wrapped.next();
    var hn = this._wrapped.hasNext();
    var out = this._proc(nxt,hn);
    return out == null?const Empty():out.iterator();
  }
  
  Iterator<OUT> iterator() => this;
}

/**
 * Easy solution when there is nothing to return
 */
class Empty<S> implements Iterator<S>{
  const Empty();
  bool hasNext() => false;
  S next() { throw new NoMoreElementsException(); }
}
