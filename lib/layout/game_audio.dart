part of layout;

late Player destroySound;
late Player flightMusic;

Device? _audioDevice;

void setSoundDevice(Device device) {
  _audioDevice = device;
  destroySound.setDevice(device);
  flightMusic.setDevice(device);
  storage.setString("audioDevice", device.id);
}

Device getAudioDevice() {
  if (_audioDevice != null) return _audioDevice!;
  if (storage.getString("audioDevice") != null) {
    final audioDevice = storage.getString("audioDevice")!;

    for (var device in Devices.all) {
      if (device.id == audioDevice) {
        return device;
      }
    }
  }
  return Devices.all.last; // Typically first is speakers and last is headphones, so headphones users can have a decent-ish experience
}

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
  sound.play();
  sound.setVolume(volume ?? (storage.getDouble("sfx_volume") ?? 1));
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
