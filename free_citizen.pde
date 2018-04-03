class FreeCitizen extends Citizen {
  FreeCitizen(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{150,150,150};
  }

  boolean isFree() {
    return true;
  }
}
