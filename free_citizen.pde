class FreeCitizen extends Citizen {
  FreeCitizen(Cell initialLocation, Building buildingAssignment) {
    super(initialLocation, buildingAssignment);
    this.c = new int[]{150,150,150};
  }
  
  boolean isFree() {
    return true;
  }
}
