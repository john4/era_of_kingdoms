class Message {
  String message;
  int expiration; // messages should be removed after the expiration time

  Message(String message, int expiration) {
    this.message = message;
    this.expiration = expiration;
  }
}
