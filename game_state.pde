class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  double gameStateIndex;

  GameState() {
    humanPlayer = new PlayerState(new int[] { 255, 215, 0 });
    computerPlayer = new PlayerState(new int[] { 128, 0, 0 });

    gameStateIndex = 0;
  }

  void step() {
    humanPlayer.step(gameStateIndex);
    computerPlayer.step(gameStateIndex);

    gameStateIndex += 1;
  }

  void draw() {
    if (state.humanPlayer.placingBuilding != BuildingCode.NONE) {
      for (Panel p : userInterface.panels) {
        p.isVisible = false;
      }
    }

    humanPlayer.draw();
    computerPlayer.draw();
  }

  ArrayList<Building> getBuildings() {
    ArrayList<Building> results = new ArrayList<Building>();
    results.addAll(humanPlayer.getBuildings());
    results.addAll(computerPlayer.getBuildings());
    return results;
  }

  ArrayList<Soldier> getSoldiers() {
    ArrayList<Soldier> results = new ArrayList<Soldier>();
    results.addAll(humanPlayer.soldiers);
    results.addAll(computerPlayer.soldiers);
    return results;
  }
}