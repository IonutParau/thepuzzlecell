part of layout;

final destroySound = Player(id: 1);

void initSound() {
  destroySound.open(
    Media.asset(
      'assets/audio/destroy.wav',
    ),
    autoStart: false,
  );
}
