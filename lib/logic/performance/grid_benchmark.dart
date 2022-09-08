import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_puzzle_cell/layout/layout.dart';
import 'package:the_puzzle_cell/logic/logic.dart';

import '../../layout/tools/tools.dart';

typedef TPSType = num;

class BenchmarkResults {
  TPSType smallLaserTPS = 0;
  TPSType smallNukeTPS = 0;
  TPSType smallSuperNukeTPS = 0;
  TPSType smallRandomTPS = 0;

  TPSType mediumLaserTPS = 0;
  TPSType mediumNukeTPS = 0;
  TPSType mediumSuperNukeTPS = 0;
  TPSType mediumRandomTPS = 0;

  TPSType largeLaserTPS = 0;
  TPSType largeNukeTPS = 0;
  TPSType largeSuperNukeTPS = 0;
  TPSType largeRandomTPS = 0;

  BenchmarkResults small(TPSType laserTPS, TPSType nukeTPS, TPSType superNukeTPS, TPSType randomTPS) {
    smallLaserTPS = laserTPS;
    smallNukeTPS = nukeTPS;
    smallSuperNukeTPS = superNukeTPS;
    smallRandomTPS = randomTPS;
    return this;
  }

  BenchmarkResults medium(TPSType laserTPS, TPSType nukeTPS, TPSType superNukeTPS, TPSType randomTPS) {
    mediumLaserTPS = laserTPS;
    mediumNukeTPS = nukeTPS;
    mediumSuperNukeTPS = superNukeTPS;
    mediumRandomTPS = randomTPS;
    return this;
  }

  BenchmarkResults large(TPSType laserTPS, TPSType nukeTPS, TPSType superNukeTPS, TPSType randomTPS) {
    largeLaserTPS = laserTPS;
    largeNukeTPS = nukeTPS;
    largeSuperNukeTPS = superNukeTPS;
    largeRandomTPS = randomTPS;
    return this;
  }

  String toString() {
    final small = "Small";
    final medium = "Medium";
    final large = "Large";
    return '''
Laser ($small): $smallLaserTPS
Laser ($medium): $mediumLaserTPS
Laser ($large): $largeLaserTPS

Nuke ($small): $smallNukeTPS
Nuke ($medium): $mediumNukeTPS
Nuke ($large): $largeNukeTPS

Super Nuke ($small): $smallSuperNukeTPS
Super Nuke ($medium): $mediumSuperNukeTPS
Super Nuke ($large): $largeSuperNukeTPS

Random ($small): $smallRandomTPS
Random ($medium): $mediumRandomTPS
Random ($large): $largeRandomTPS
''';
  }
}

class BenchmarkSettings {
  int tickCount;
  SharedPreferences storage;
  BenchmarkSettings(this.tickCount, this.storage);
}

Future<BenchmarkResults> benchmark(BenchmarkSettings settings) async {
  final results = BenchmarkResults();
  game = PuzzleGame();
  game.initial = Grid(1, 1);
  storage = settings.storage;

  TPSType getTPS(Grid g) {
    final gc = grid;
    grid = g;
    final stopwatch = Stopwatch()..start();

    for (var i = 0; i < settings.tickCount; i++) {
      grid.update();
    }

    stopwatch.stop();

    grid = gc;
    return settings.tickCount / (stopwatch.elapsedMilliseconds / 1000);
  }

  final smallLaser = loadStr(r"P4;;;O;O;B,zZ=bp)?t{EoEU#v%N_s=PcTmjt_I=iNYGVTVBF'QSl6|'#0v&l@9=-wh4Qm(2a%[mROzQW%0A~&=Ih7]n#N#M0fJLF^Mkw/Jg?ttl52x5dOTndZS7.kZILX%=Am2$rh1gzM}4oM{p'!;(=);", false);
  final smallNuke = loadStr(
    r"P4;;;O;O;E.XJt~/oD5T]P(QiRqx|Rrm!/!claL=S6(y,Cx7156311DvnZYP/BAnyy6'Maijz]/h/sF^}MDJSwHo=qXP7JFP2f)LFDLBe'U&rf(z2w.j=t@{WdHAs}N]9Sq}e:p@vF#XWA!Z4{VwO9LylTLD;(=);",
    false,
  );
  final smallSuperNuke = loadStr(
    r"P4;;;O;O;v1lTkr0aB,j$h,k&k=]B)Z]e5f-|Z[jc{E+CN|@[2cay__#B,ONgtNQSr(eQY2al/|C1%b.P[has2Cs&]K_@J0K_hk~#}TGBNk'cq(L=v#.|dLi:K96Xytda%=M]C-jHN:V-lVY7z{R%jKU3;(=);",
    false,
  );
  final smallRandom = loadStr(
    r"P4;;;O;O;k/5gEsF#g&[=nLGO9Pbx+2g]KoR#,Jhj%B#?'TXk)i9gyDJzW?'WmQBOZn%mlC7C%,haj{66'.7GZYaq4KUHF,1cv#sH@,BwyBl&LS685fClR0:+zMyzBXFGc?6y(Z78D5|cs.]W_$P6JsZ5z9!lgZGH=jA9O9Zi&G(con{@^=(NQv+q_9%2t3$ZkdIU+kI_vpfqPBFiKI.|iA=lI4o[_($:r%P8,vHnmqza8j0ddo+7#K5qULYMDYNOahc/%l9E@GjyHV=Mo1aK6h^-IolUa6tB?iLo9^Iy&BS|e{K{Wr#zUwHdmq@[/lWdtP.)QW)=WCl#d@vg$b?8MXAMEt!DGRL0Ql2P&p5pB:lrkN{q=!ZZ.C{0ZN,{-yk4cN'OPxbicPrk40F]u.0DP^[s8/D'6q-gjn/XKhqM4uz+OpC]QUD^&kI9,z#rebC'w4Yy7)F|s/G1OBEFPol2W%nY)C~|w?+9eStM_PPLhx-2IP?x;(=);",
    false,
  );

  results.small(getTPS(smallLaser), getTPS(smallNuke), getTPS(smallSuperNuke), getTPS(smallRandom));

  final mediumLaser = loadStr(
    r"P4;;;1q;1q;B,zZ=b~{gp,CP!'cB|?qNe7~Ewno,R}UXyO!c-q5--28dwMY-RLF)&Ixm[X?.f1IkD40+o8%EwzJ)0g{$/LsxQJ(B3,?3DI%K%r]12DnPx%Q@Qa.E^'Q}nN@Ni]k7iLN0J~!@e&BNY]$T;(=);",
    false,
  );
  final mediumNuke = loadStr(
    r"P4;;;1q;1q;E.XJt/r,QV3VANrya,@d}7-0W#OYKnr]g%LRdW.5ahAZ|H0z0/Rp65}!Ar!|qq,XNw0D.+513C@/Z93E]cCshQaJPZBjRMVb^i-X3e4aZp.I}.{CD5f5JTWBo9xj:Nf4fOxZcBHaYcwim4~w=Wt;(=);",
    false,
  );
  final mediumSuperNuke = loadStr(
    r"P4;;;1q;1q;QP/9bfLbus5hmBr//VGO]}fB-,[=(/%4N!On/|0kg:0&wZV=T]_@fki%WoU6^|rw|4r}ho1w#KJi:z0fN:d7wFe1WKb7^)T^f]hZQ1ZGw&d&Y9SY6l=_,^lBowdN-encY,J^{26PHk@1N8a;(=);",
    false,
  );
  final mediumRandom = loadStr(
    r"P4;;;1q;1q;B,zZ=b~{gp,CP!'cB|?qNe7~Ewno,R}UXyO!c-q5--28dwMY-RLF)&Ixm[X?.f1IkD40+o8%EwzJ)0g{$/LsxQJ(B3,?3DI%K%r]12DnPx%Q@Qa.E^'Q}nN@Ni]k7iLN0J~!@e&BNY]$T;(=);",
    false,
  );

  results.medium(getTPS(mediumLaser), getTPS(mediumNuke), getTPS(mediumSuperNuke), getTPS(mediumRandom));

  final largeLaser = loadStr(
    r"P4;;;44;44;QP/9bfLbus5hmBr//RiBGq4bV|$+,~Yn5OK8Z[mLrI7[K83K%A')m+g[khwmP2uyAd.@T7U^J~G+no@zBMMa%OvLn+zD@8t2_c'.%mfOG_)JLH,MTV9sw5LUh=1?9pC6omd?U4SRuI.4&g&;(=);",
    false,
  );

  final largeNuke = loadStr(
    r"P4;;;44;44;Bh_2q$exG&ROW6|RB|9cXP-{9dVD]}61TP14cFcTyb-6WU~]?y%W41a]DSf)[{cgvdq|^tpx1v#jSz|c[n)wws5SC~bj50]v0,pyE+t9(X(,aA)uWH:0ywt|]0evMPIb04Y=43]7OrX&}t=.5DbvMw^;(=);",
    false,
  );

  final largeSuperNuke = loadStr(
    r"P4;;;44;44;N}JAC83GU@5v:n_UDE&Di]s8MNzu_,^qx{7O.'cs:MwSW_},LQx7nDeK)-:0kf3nN%!!S$}h=onG/UZmQzHYkT}ESMth6Hr)@1aZYvKUPIG=MY])6_^C:vIuuiSoE~w2NwMP9ux7qL/YAqJwHMtP;(=);",
    false,
  );

  final largeRandom = loadStr(
    r"P4;;;44;44;B6.fNtu)uv)/TfBPzZ]BZ~)VFW{nZt22ZK~M[uO~h1^wufd|MdC'nxX|L]4bd~,9eu,1VN#dKNLURMfJvf_NPy-G[mS:t$9~|E]2t'q&?[j3[y$|gwhhC%H6Widm!Zn/X'u0U4dy9)ffaW7$G~msILb&Lv/7hPz,iN~^?1'LSp@uGsz@WXO[.ep~+J&)k!H6Jk]5T@Q[pK9tdze}'DIgEFZ{dJquNjSXR#XE%~BvIo2l-!).j[E|h_|4]I72_hyCOyjobSHv@N,(Nh|a),'JY13+ML9c:hrgaV8sq+DZdJ'J'ZU?x6m),yP}]=xMlbx(RKs$&x)t^JF.xkn)6LNhy{lGXycy?_J(nuw0z1H+D^{4z#D+yL|4,R(Pih?J?QZtGb(%RgDh~1&iP[MY[04-oBRs^9t2-y~5ZKHeHKL$]@%5p}2sCq,,I4(kTAzCw]6x/tAqUF$,2/B/wj,j{KAZ&&~:v{?0gORa;(=);",
    false,
  );

  results.large(getTPS(largeLaser), getTPS(largeNuke), getTPS(largeSuperNuke), getTPS(largeRandom));

  return results;
}

Future benchmarkOnThread(BenchmarkSettings settings) {
  return compute(benchmark, settings);
}
