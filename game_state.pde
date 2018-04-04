class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  double gameStateIndex;

  GameState() {
    humanPlayer = new PlayerState();
    computerPlayer = new PlayerState();

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
    results.addAll(humanPlayer.buildings);
    results.addAll(computerPlayer.buildings);
    return results;
  }
}