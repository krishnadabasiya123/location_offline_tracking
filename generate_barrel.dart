import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  final outputFile = File('lib/core/app/all_import_file.dart');

  final packageExports = <String>{};
  final dartExports = <String>{};

  if (!libDir.existsSync()) {
    print("❌ Error: 'lib' directory not found. Run this from your project root.");
    return;
  }

  print('🔎 Scanning all files in lib/ for imports...');

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('all_import_file.dart')) continue;

    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('import ')) {
        // Clean line: remove 'import', remove ';', remove 'as prefix', remove 'show/hide'
        final cleanLine = trimmed.replaceFirst('import ', '').split(' as ')[0].split(' show ')[0].split(' hide ')[0].replaceAll(';', '').trim();

        // Only add package: or dart: imports (Relative imports like '../' won't work in a barrel)
        if (cleanLine.contains('dart:')) {
          dartExports.add('export $cleanLine;');
        } else if (cleanLine.contains('package:')) {
          packageExports.add('export $cleanLine;');
        }
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('// 🔥 GENERATED BARREL FILE - DO NOT EDIT MANUALLY 🔥');
  buffer.writeln("// Run 'dart generate_barrel.dart' to update this file.");
  buffer.writeln();

  buffer.writeln('// 🎯 Dart Imports');
  final sortedDart = dartExports.toList()..sort();
  for (final e in sortedDart) buffer.writeln(e);

  buffer.writeln('\n// 📦 Package & Project Imports');
  final sortedPkg = packageExports.toList()..sort();
  for (final e in sortedPkg) buffer.writeln(e);

  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(buffer.toString());

  print('✅ Success! File created at: ${outputFile.path}');
}
