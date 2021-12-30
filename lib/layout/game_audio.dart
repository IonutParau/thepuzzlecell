part of layout;

final destroySound = Player(id: 1);
// late ReceivePort _audioComPort;
// late SendPort _audioSendPort;
// late Isolate _audioIso;

void initSound() {
  destroySound.open(
    Media.asset(
      'assets/audio/destroy.wav',
    ),
    autoStart: false,
  );
  destroySound.setVolume(0.5);
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

void playSound(Player sound) {
  sound.seek(Duration.zero);
  sound.play();
}
