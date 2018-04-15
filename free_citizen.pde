class FreeCitizen extends Citizen {
  final HumanCode type = HumanCode.FREE;

  FreeCitizen(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{150,150,150};
  }

  boolean isFree() {
    return true;
  }
}
