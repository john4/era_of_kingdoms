class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  Hal hal;
  double gameStateIndex;
  boolean isGameOver;

  GameState() {
    humanPlayer = new PlayerState(new int[] { 255, 215, 0 });
    computerPlayer = new PlayerState(new int[] { 128, 0, 0 });
    hal = new Hal(this, computerPlayer, humanPlayer);

    gameStateIndex = 0;
    isGameOver = false;
  }

  void step() {
    if (!isGameOver) {
      humanPlayer.step(gameStateIndex);
      computerPlayer.step(gameStateIndex);
      hal.behave();

      if (humanPlayer.foodSupply < 1) {
        isGameOver = true;
      }

      if (gameStateIndex % (FRAME_RATE * 5) == 0 && humanPlayer.foodSupply < 20) {
        userInterface.messageQueue.add(new Message("Your people are starving...", 10*FRAME_RATE + gameStateIndex));
      }

      if (gameStateIndex % FRAME_RATE == 0) {
        userInterface.messageQueue.clean(gameStateIndex);
      }
      gameStateIndex += 1;
    }
  }

  void draw() {
    if (isGameOver) {
      textSize(34);
      text("YOUR PEOPLE STARVED", width / 2, height / 2);
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

  ArrayList<Soldier> getSoldiers() {
    ArrayList<Soldier> results = new ArrayList<Soldier>();
    results.addAll(humanPlayer.soldiers);
    results.addAll(computerPlayer.soldiers);
    return results;
  }
}
