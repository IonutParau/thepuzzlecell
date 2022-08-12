part of layout;

late Player destroySound;
late Player flightMusic;
late Player floatMusic;
late Player driftMusic;

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

Player get music {
  final m = storage.getString("music") ?? (musics.first.id);

  if (m == "flight") return flightMusic;
  if (m == "float") return floatMusic;
  if (m == "drift") return driftMusic;

  return flightMusic;
}

void changeMusic(String newMusic) {
  final old = music;
  storage.setString("music", newMusic);
  old.stop();
  setLoopSoundVolume(music, old.general.volume);
}

double getMusicVolume() {
  if (music.playback.isPlaying) {
    return music.general.volume;
  } else {
    return 0;
  }
}

void initSound() {
  flightMusic = Player(id: 69420, commandlineArguments: ['--no-video'])..add(Media.asset('assets/audio/Flight.ogg'));
  destroySound = Player(id: 69421, commandlineArguments: ['--no-video'])..add(Media.asset('assets/audio/destroy.wav'));
  floatMusic = Player(id: 69422, commandlineArguments: ['--no-video'])..add(Media.asset('assets/audio/Float.ogg'));
  driftMusic = Player(id: 69423, commandlineArguments: ['--no-video'])..add(Media.asset('assets/audio/Drift.ogg'));
}

void playSound(Player sound, [double? volume]) {
  if (inBruteForce) return;
  sound.setVolume(volume ?? (storage.getDouble("sfx_volume") ?? 1));
  sound.setPlaylistMode(PlaylistMode.single);
  sound.play();
}

void playOnLoop(Player sound, double volume) {
  sound.setPlaylistMode(PlaylistMode.loop);
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
