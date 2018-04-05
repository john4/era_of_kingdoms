class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  double gameStateIndex;
  boolean isGameOver;

  GameState() {
    humanPlayer = new PlayerState();
    computerPlayer = new PlayerState();

    gameStateIndex = 0;
    isGameOver = false;
  }

  void step() {
    if (!isGameOver) {
      humanPlayer.step(gameStateIndex);
      computerPlayer.step(gameStateIndex);

      if (humanPlayer.foodSupply < 1) {
        isGameOver = true;
      }

      gameStateIndex += 1;
    }
  }

  void draw() {
    if (isGameOver) {
      textSize(4);
      text("YOUR PEOPLE STARVED", this.pos.x, this.pos.y);
      return;
    }

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
}