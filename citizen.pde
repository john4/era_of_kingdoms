class Citizen extends Human {
  boolean isCarryingSupply;
  
  Citizen(Cell initialLocation, Building buildingAssignment) {
    super(initialLocation, buildingAssignment);
  }
  
  boolean isFree() {
    return false;
  }
}
