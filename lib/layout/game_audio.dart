part of layout;

late Source destroySound;
late Source flightMusic;
late Source floatMusic;
late Source driftMusic;

// This will play multiple sounds concurrently
final sfxPlayer = AudioPlayer();

// This should ONLY play one
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

void changeMusic(String newMusic) {
  final volume = getMusicVolume();
  storage.setString("music", newMusic).then((v) => musicPlayer.stop().then((v) => _isMusicPlaying = false).then((v) => setLoopSoundVolume(music, volume))); // Callback hell
}

double getMusicVolume() {
  if (_isMusicPlaying) {
    return _musicPlayerVolume;
  } else {
    return 0;
  }
}

void initSound() {
  flightMusic = AssetSource("assets/audio/Flight.ogg");
  destroySound = AssetSource("assets/audio/destroy.wav");
  floatMusic = AssetSource("assets/audio/Float.ogg");
  driftMusic = AssetSource("assets/audio/Drift.ogg");

  musicPlayer.onPlayerComplete.listen((v) {
    if (_musicPlayerVolume > 0) {
      musicPlayer.resume();
    }
  });
}

void playSound(Source sound, [double? volume]) {
  if (inBruteForce) return;
  if (volume == 0) return;
  sfxPlayer.setVolume(volume ?? (storage.getDouble("sfx_volume") ?? 1));
  sfxPlayer.play(sound);
}

void playOnLoop(Source sound, double volume) {
  musicPlayer.stop().then((v) => _isMusicPlaying = false);
  if (volume > 0) {
    musicPlayer.setVolume(volume).then((v) => _musicPlayerVolume = volume);
    musicPlayer.play(sound).then((v) => _isMusicPlaying = true);
  }
}

void setLoopSoundVolume(Source sound, double volume) {
  if (volume == 0) {
    musicPlayer.stop().then((v) => _isMusicPlaying = false);
  } else {
    if (_isMusicPlaying) {
      musicPlayer.setVolume(volume).then((v) => _musicPlayerVolume = volume);
    } else {
      playOnLoop(sound, volume);
    }
  }
}
