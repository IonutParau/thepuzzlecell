// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_puzzle_cell/layout/tools/tools.dart' show P4;

void main() {
  test('Test P4 decoding', () {
    expect(P4.decodeValue('0'), 0);
    expect(P4.decodeValue('Test'), 'Test');
    expect(P4.decodeValue('true'), true);
    expect(P4.decodeValue('false'), false);
    expect(P4.decodeValue('1.5'), 1.5);
    expect(P4.decodeValue('(true:false:1.5:0)'), [true, false, 1.5, 0]);
    expect(P4.decodeValue('(key=value:test=(this:is:a:list):someMap=(someKey=someValue:someNumber=0:someDouble=5.3:someBoolean=false))'), {
      'key': 'value',
      'test': ['this', 'is', 'a', 'list'],
      'someMap': {'someKey': 'someValue', 'someNumber': 0, 'someDouble': 5.3, 'someBoolean': false}
    });
  });

  test('Test P4 encoding', () {
    expect(P4.encodeValue(0), '0');
    expect(P4.encodeValue(2.5), '2.5');
    expect(
      P4.encodeValue([
        'help',
        {'test': 'thing'},
        ['hlep', 'test']
      ]),
      '(help:(test=thing):(hlep:test))',
    );
    expect(
      P4.encodeValue(<String, dynamic>{
        'someList': [
          'help',
          {'test': 'thing'},
          ['hlep', 'test'],
        ],
        'someMap': {
          'key': 'value',
        },
      }),
      '(someList=(help:(test=thing):(hlep:test)):someMap=(key=value))',
    );
  });
}
