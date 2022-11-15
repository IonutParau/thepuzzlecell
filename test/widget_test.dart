// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart' show TPCML;
import 'package:the_puzzle_cell/logic/logic.dart';

void main() {
  test('Test TPCML decoding', () {
    expect(TPCML.decodeValue('ni0'), 0);
    expect(TPCML.decodeValue('"Test"'), 'Test');
    expect(TPCML.decodeValue('true'), true);
    expect(TPCML.decodeValue('false'), false);
    expect(TPCML.decodeValue('nd1.5'), 1.5);
    expect(TPCML.decodeValue('l(true:false:nd1.5:ni0)'), [true, false, 1.5, 0]);
    expect(TPCML.decodeValue('m(key="value":test=l(this:is:a:list):someMap=m(someKey="someValue":someNumber=ni0:someDouble=nd5.3:someBoolean=false))'), {
      'key': 'value',
      'test': ['this', 'is', 'a', 'list'],
      'someMap': {'someKey': 'someValue', 'someNumber': 0, 'someDouble': 5.3, 'someBoolean': false}
    });
  });

  test('Test P4 encoding', () {
    expect(TPCML.encodeValue(0), 'ni0');
    expect(TPCML.encodeValue(2.5), 'nd2.5');
    expect(
      TPCML.encodeValue([
        'help',
        {'test': 'thing'},
        ['hlep', 'test']
      ]),
      'l("help":m("test"="thing"):l("hlep":"test"))',
    );
    expect(
      TPCML.encodeValue(<String, dynamic>{
        'someList': [
          'help',
          {'test': 'thing'},
          ['hlep', 'test'],
        ],
        'someMap': {
          'key': 'value',
        },
      }),
      'm("someList"=l("help":m("test"="thing"):l("hlep":"test")):"someMap"=m("key"="value"))',
    );
  });

  test('Version checking', () {
    expect(higherVersion('2.1', '2.2'), false);
    expect(higherVersion('2.1', '2.1'), false);
    expect(higherVersion('2.1.0.0', '2.1.0.0'), false);
    expect(higherVersion('2.2.0.0', '2.2.0.0'), false);
    expect(higherVersion('2.1.0.1', '2.1.0.1'), false);
    expect(higherVersion('2.2', '2.1'), true);
    expect(higherVersion('2.2.0.0', '2.1.2.2'), true);
    expect(higherVersion('2.1.2.2', '2.2.0.0'), false);
  });
}
