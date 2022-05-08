part of layout;

late Player destroySound;
late Player flightMusic;

void initSound() {
  flightMusic = Player(id: 69420, commandlineArguments: ['--no-video']);
  destroySound = Player(id: 69421, commandlineArguments: ['--no-video']);

  final destroy = Media.asset(
    'assets/audio/destroy.wav',
  );

  final flight = Media.asset(
    'assets/audio/Flight.ogg',
  );

  destroySound.add(
    destroy,
  );

  flightMusic.add(
    flight,
  );

  flightMusic.playbackStream.listen((event) {
    if (event.isCompleted) {
      flightMusic.play(); // Loop
    }
  });
}

void playSound(Player sound, [double? volume]) {
  if (inBruteForce) return;
  if (sound.playback.isPlaying) {
    sound.seek(Duration.zero);
  } else {
    sound.play();
  }
  sound.setVolume(volume ?? game.sfxVolume);
}

void playOnLoop(Player sound, double volume) {
  if (sound.playback.isPlaying) {
    sound.seek(Duration.zero);
  } else {
    sound.play();
  }
  sound.setVolume(volume);
}

void setLoopSoundVolume(Player sound, double volume) {
  if (volume == 0) {
    sound.stop();
  } else {
    if (sound.playback.isPlaying) {
      sound.setVolume(volume);
    } else {
      playOnLoop(sound, volume);
    }
  }
}
