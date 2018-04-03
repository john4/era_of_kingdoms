import java.util.HashMap;

static final int SUCCESS = 1;
static final int FAIL = 0;

abstract class Task {
  abstract int execute();  // returns FAIL = 0, SUCCESS = 1
  Blackboard blackboard;
}

class Blackboard {
  HashMap<String, Object> lookup;

  Blackboard() {
    lookup = new HashMap<String, Object>();
  }

  public Object get(String key) {
    return lookup.get(key);
  }

  public void put(String key, Object val) {
    lookup.put(key, val);
  }
}

/** Tries children in order until one returns success (return “fail” if all fail) */
class Selector extends Task {
  Task[] children;

  Selector(Blackboard bb, Task[] children) {
    this.blackboard = bb;
    this.children = children;
  }

  int execute() {
    for (int i = 0; i < children.length; i++) {
      int s = children[i].execute();
      if (s == SUCCESS) {
        return SUCCESS;
      }
    }

    return FAIL;
  }
}

/** Tries all its children in turn, returns failure if any fail (or success if all succeed) */
class Sequence extends Task {
  Task[] children;

  Sequence(Blackboard bb, Task[] children) {
    this.blackboard = bb;
    this.children = children;
  }

  int execute() {
    for (int i = 0; i < children.length; i++) {
      int s = children[i].execute();
      if (s == FAIL) {
        return FAIL;
      }
    }
    return SUCCESS;
  }
}