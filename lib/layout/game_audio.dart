part of layout;

final flightMusic = AssetSource("audio/Flight.ogg");
final destroySound = AssetSource("audio/destroy.wav");
final floatMusic = AssetSource("audio/Float.ogg");
final driftMusic = AssetSource("audio/Drift.ogg");

// This will play only one sound at once via the power of magic
final sfxPlayer = AudioPlayer();

// This is moozik
final musicPlayer = AudioPlayer();
var _isMusicPlaying = false;
var _musicPlayerVolume = 0.0;

class Music {
  String name, id;
  Music(this.name, this.id);
}

List<Music> musics = [
  Music('Drift', 'drift'),
  Music('Flight', 'flight'),
  Music('Float', 'float'),
];

Music getCurrentMusicData() {
  final current = storage.getString("music") ?? (musics.first.id);

  for (var m in musics) {
    if (m.id == current) return m;
  }

  return musics.first;
}

Source get music {
  final m = storage.getString("music") ?? (musics.first.id);

  if (m == "flight") return flightMusic;
  if (m == "float") return floatMusic;
  if (m == "drift") return driftMusic;

  return flightMusic;
}

Future changeMusic(String newMusic) async {
  final volume = getMusicVolume();
  await storage.setString("music", newMusic);
  if (_isMusicPlaying) await musicPlayer.stop();
  _isMusicPlaying = false;
  await setLoopSoundVolume(
    music,
    volume,
  );
}

double getMusicVolume() {
  if (_isMusicPlaying) {
    return _musicPlayerVolume;
  } else {
    return 0;
  }
}

void initSound() {
  musicPlayer.setReleaseMode(ReleaseMode.loop);
}

Future playSound(Source sound, [double? volume]) async {
  if (inBruteForce) return;
  if (volume == 0) return;
  await sfxPlayer.play(sound, volume: (volume ?? (storage.getDouble("sfx_volume") ?? 1)));
}

Future playOnLoop(Source sound, double volume) async {
  if (_isMusicPlaying) musicPlayer.stop();
  _isMusicPlaying = false;
  if (volume > 0) {
    await musicPlayer.play(sound, volume: volume, mode: PlayerMode.lowLatency);
    _isMusicPlaying = true;
    _musicPlayerVolume = volume;
  }
}

Future setLoopSoundVolume(Source sound, double volume) async {
  if (volume == 0) {
    if (_isMusicPlaying) {
      await musicPlayer.stop();
      _isMusicPlaying = false;
    }
  } else {
    if (_isMusicPlaying) {
      await musicPlayer.setVolume(volume);
      _musicPlayerVolume = volume;
    } else {
      await playOnLoop(sound, volume);
    }
  }
}
