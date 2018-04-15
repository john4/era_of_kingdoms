class GameState {
  PlayerState humanPlayer;
  PlayerState computerPlayer;
  double gameStateIndex;
  boolean isGameOver;

  GameState() {
    humanPlayer = new PlayerState(new int[] { 255, 215, 0 });
    computerPlayer = new PlayerState(new int[] { 128, 0, 0 });

    gameStateIndex = 0;
    isGameOver = false;
  }

  void step() {
    if (!isGameOver) {
      humanPlayer.step(gameStateIndex);
      computerPlayer.step(gameStateIndex);

      int humanPopulation = humanPlayer.citizens.size() + humanPlayer.soldiers.size();
      int computerPopulation = computerPlayer.citizens.size() + computerPlayer.soldiers.size();

      if (humanPopulation < 1 || computerPopulation < 1) {
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
      int humanPopulation = humanPlayer.citizens.size() + humanPlayer.soldiers.size();
      textSize(34);

      if (humanPopulation < 1) {
        text("YOUR PEOPLE STARVED", width / 2, height / 2);
      } else {
        text("YOU DESTROYED THE ENEMY", width / 2, height / 2);
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

  ArrayList<Soldier> getSoldiers() {
    ArrayList<Soldier> results = new ArrayList<Soldier>();
    results.addAll(humanPlayer.soldiers);
    results.addAll(computerPlayer.soldiers);
    return results;
  }
}
