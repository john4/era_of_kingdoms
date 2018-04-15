class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  Hal hal;
  double gameStateIndex;
  boolean isGameOver;

  GameState() {
    boolean humanLeft = int(random(2)) == 1;
    humanPlayer = new PlayerState(new int[] { 255, 215, 0 }, humanLeft);
    computerPlayer = new PlayerState(new int[] { 128, 0, 0 }, !humanLeft);
    hal = new Hal(this, computerPlayer, humanPlayer);

    gameStateIndex = 0;
    isGameOver = false;
  }

  void step() {
    if (!isGameOver) {
      humanPlayer.step(gameStateIndex);
      computerPlayer.step(gameStateIndex);
      hal.behave();

      int humanPopulation = humanPlayer.getCitizens().size() + humanPlayer.getSoldiers().size();
      int computerPopulation = computerPlayer.getCitizens().size() + computerPlayer.getSoldiers().size();

      if (humanPopulation < 1 || computerPopulation < 1) {
        isGameOver = true;
      }

      if (gameStateIndex % (FRAME_RATE * 5) == 0 && humanPlayer.foodSupply < 1) {
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
      int humanPopulation = humanPlayer.getCitizens().size() + humanPlayer.getSoldiers().size();
      textSize(34);

      if (humanPopulation < 1) {
        text("YOUR PEOPLE STARVED", 30, height / 2);
      } else {
        text("YOU DESTROYED THE ENEMY", 30, height / 2);
      }

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

  ArrayList<Human> getSoldiers() {
    ArrayList<Human> results = new ArrayList<Human>();
    results.addAll(humanPlayer.getSoldiers());
    results.addAll(computerPlayer.getSoldiers());
    return results;
  }
}
