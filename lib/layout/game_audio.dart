part of layout;

final destroySound = Player.asset('assets/audio/destroy.wav', autoPlay: false);
final flightMusic = Player.asset('assets/audio/Flight.ogg', autoPlay: false);
// late ReceivePort _audioComPort;
// late SendPort _audioSendPort;
// late Isolate _audioIso;

void initSound() {
  destroySound.callback = (e) {};
  flightMusic.callback = (e) {};
  // destroySound.open(
  //   Media.asset(
  //     'assets/audio/destroy.wav',
  //   ),
  //   autoStart: false,
  // );
  // destroySound.setVolume(0.5);

  // flightMusic.open(
  //   Media.asset(
  //     'assets/audio/Flight.ogg',
  //   ),
  //   autoStart: false,
  // );
  // _audioComPort = ReceivePort();
  // Isolate.spawn(
  //   _playSound,
  //   _audioComPort.sendPort,
  // ).then(
  //   (iso) {
  //     _audioIso = iso;
  //   },
  // );
  // _audioComPort.listen(
  //   (message) {
  //     if (message is SendPort) {
  //       _audioSendPort = message;
  //     }
  //   },
  // );
}

// void _playSound(SendPort port) {
//   final mainToIsolateStream = ReceivePort();
//   port.send(mainToIsolateStream.sendPort);

//   mainToIsolateStream.listen(
//     (audio) {
//       if (audio is Player) {
//         DartVLC.initialize();
//         audio.stop();
//         audio.play();
//       }
//     },
//   );
// }

void playSound(PlayerController sound) {
  if (inBruteForce) return;
  if (sound.playing) sound.position = Duration.zero;
  sound.play();
}

void playOnLoop(PlayerController sound, double volume) {
  sound.volume = volume;
  sound.loop = true;
  sound.play();
}

void setLoopSoundVolume(PlayerController sound, double volume) {
  if (volume == 0) {
    sound.stop();
  } else {
    if (sound.playing) {
      sound.volume = volume;
    } else {
      playOnLoop(sound, volume);
    }
  }
}
