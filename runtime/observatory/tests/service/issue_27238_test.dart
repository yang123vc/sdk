// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// VMOptions=--error_on_bad_type --error_on_bad_override  --verbose_debug

import 'package:observatory/service_io.dart';
import 'service_test_common.dart';
import 'dart:async';
import 'test_helper.dart';
import 'dart:developer';

const int LINE_A = 20;
const int LINE_B = 23;
const int LINE_C = 24;
const int LINE_D = 26;
const int LINE_E = 27;

testMain() async {
  debugger();
  Future future1 = new Future.value();  // LINE_A.
  Future future2 = new Future.value();

  await future1;  // LINE_B.
  await future2;  // LINE_C.

  print('foo1'); // LINE_D.
  print('foo2'); // LINE_E.
}

var tests = [
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  smartNext,
  hasStoppedAtBreakpoint,
  smartNext,
  stoppedAtLine(LINE_B),
  smartNext,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_C),
  smartNext,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_D),
  resumeIsolate,
];

main(args) => runIsolateTests(args, tests, testeeConcurrent: testMain);
