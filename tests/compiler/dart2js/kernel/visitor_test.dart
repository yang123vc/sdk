// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Test that the dart2js copy of [KernelVisitor] generates the expected IR as
/// defined by kernel spec-mode test files.

import 'dart:io';
import 'package:compiler/src/compiler.dart' show Compiler;
import 'package:compiler/src/js_backend/backend.dart' show JavaScriptBackend;
import 'package:compiler/src/commandline_options.dart' show Flags;
import 'package:kernel/text/ast_to_text.dart';
import 'package:path/path.dart' as pathlib;
import 'package:test/test.dart';

import '../memory_compiler.dart';

const String TESTCASE_DIR = 'third_party/pkg/kernel/testcases/';

const List<String> SKIP_TESTS = const <String>[
  'DeltaBlue', // Super calls encoded as `super.{...` and not `this.{...`.
];

main(List<String> arguments) {
  Directory directory = new Directory('${TESTCASE_DIR}/input');
  for (FileSystemEntity file in directory.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      String name = pathlib.basenameWithoutExtension(file.path);
      bool selected = arguments.contains(name);
      if (!selected) {
        if (arguments.isNotEmpty) continue;
        if (SKIP_TESTS.contains(name)) continue;
      }

      test(name, () async {
        var result = await runCompiler(
            entryPoint: file.absolute.uri,
            options: [Flags.analyzeOnly, Flags.useKernel]);
        Compiler compiler = result.compiler;
        JavaScriptBackend backend = compiler.backend;
        StringBuffer buffer = new StringBuffer();
        new Printer(buffer).writeLibraryFile(
            backend.kernelTask.kernel.libraryToIr(compiler.mainApp));
        String actual = buffer.toString();
        String expected =
            new File('${TESTCASE_DIR}/spec-mode/$name.baseline.txt')
                .readAsStringSync();
        if (selected) {
          String input =
              new File('${TESTCASE_DIR}/input/$name.dart').readAsStringSync();
          print('============================================================');
          print(name);
          print('--input-----------------------------------------------------');
          print(input);
          print('--expected--------------------------------------------------');
          print(expected);
          print('--actual----------------------------------------------------');
          print(actual);
        }
        expect(actual, equals(expected));
      });
    }
  }
}
