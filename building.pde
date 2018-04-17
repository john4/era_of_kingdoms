abstract class Building extends WorldlyObject implements Comparable<Building> {
  int[] c = new int[3];
  String name;
  ArrayList<Human> assignedHumans;
  int assignmentLimit;

  Building(Cell location, String name) {
    super(location);
    this.c = new int[]{20, 20, 20};
    this.name = name;
    this.assignedHumans = new ArrayList<Human>();
    this.assignmentLimit = Integer.MAX_VALUE;
    location.addBuilding(this);
  }

  boolean removeAssignee(Human h) {
    return this.assignedHumans.remove(h);
  }

  boolean addAssignee(Human h) {
    if (this.numFreeAssignments() > 0) {
      this.assignedHumans.add(h);
      return true;
    }
    return false;
  }

  int numFreeAssignments() {
    return this.assignmentLimit - this.assignedHumans.size();
  }

  // buildings sortable by how many available assignee spaces they have left
  @Override public int compareTo(Building b) {
    int ourFreeAssign = this.numFreeAssignments();
    int theirFreeAssign = b.numFreeAssignments();
    if (ourFreeAssign > theirFreeAssign) {
      return -1;
    } else if (ourFreeAssign < theirFreeAssign) {
      return 1;
    }
    return 0;
  }

  void draw() {
    fill(c[0], c[1], c[2]);
    rect(this.loc.x + 1, this.loc.y + 1, this.w, this.h);
  }

  String getName() {
    return this.name;
  }
}

enum BuildingCode {
  NONE, FARM, CROP, HOVEL, SAWMILL, STOCKPILE, TOWNSQUARE, FOUNDRY, BARRACKS;

  @Override
    public String toString() {
        return name().toLowerCase();
    }
}

enum ResourceCode {
  LUMBER, METAL;

  @Override
    public String toString() {
        return name().toLowerCase();
    }
}

class BuildingCosts {
  HashMap<BuildingCode, HashMap<ResourceCode, Integer>> costs;

  BuildingCosts() {
    HashMap<ResourceCode, Integer> free = new HashMap<ResourceCode, Integer>();
    free.put(ResourceCode.LUMBER, 0);
    free.put(ResourceCode.METAL, 0);

    HashMap<ResourceCode, Integer> farm = new HashMap<ResourceCode, Integer>();
    farm.put(ResourceCode.LUMBER, 12);
    farm.put(ResourceCode.METAL, 0);

    HashMap<ResourceCode, Integer> sawmill = new HashMap<ResourceCode, Integer>();
    sawmill.put(ResourceCode.LUMBER, 16);
    sawmill.put(ResourceCode.METAL, 4);

    HashMap<ResourceCode, Integer> hovel = new HashMap<ResourceCode, Integer>();
    hovel.put(ResourceCode.LUMBER, 4);
    hovel.put(ResourceCode.METAL, 0);

    HashMap<ResourceCode, Integer> stockpile = new HashMap<ResourceCode, Integer>();
    stockpile.put(ResourceCode.LUMBER, 4);
    stockpile.put(ResourceCode.METAL, 0);

    HashMap<ResourceCode, Integer> barracks = new HashMap<ResourceCode, Integer>();
    barracks.put(ResourceCode.LUMBER, 32);
    barracks.put(ResourceCode.METAL, 16);

    HashMap<ResourceCode, Integer> foundry = new HashMap<ResourceCode, Integer>();
    foundry.put(ResourceCode.LUMBER, 24);
    foundry.put(ResourceCode.METAL, 0);

    costs = new HashMap<BuildingCode, HashMap<ResourceCode, Integer>>();
    for (BuildingCode buildingCode : BuildingCode.values()) {
      costs.put(buildingCode, free);
    }

    costs.put(BuildingCode.FARM, farm);
    costs.put(BuildingCode.SAWMILL, sawmill);
    costs.put(BuildingCode.HOVEL, hovel);
    costs.put(BuildingCode.STOCKPILE, stockpile);
    costs.put(BuildingCode.BARRACKS, barracks);
    costs.put(BuildingCode.FOUNDRY, foundry);
  }
}
