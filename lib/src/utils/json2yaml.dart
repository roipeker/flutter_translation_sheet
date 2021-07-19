/*
 * MIT License
 *
 * Copyright (c) 2019 Alexei Sintotski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/// Yaml formatting control options
enum YamlStyle {
  /// Default formatting style applicable in most cases
  generic,

  /// YAML formatting style following pubspec.yaml formatting conventions
  pubspecYaml,

  /// YAML formatting style following pubspec.lock formatting conventions
  pubspecLock,
}

/// Converts JSON to YAML representation
String json2yaml(
  Map<String, dynamic> json, {
  YamlStyle yamlStyle = YamlStyle.generic,
}) =>
    _renderToYaml(json, 0, yamlStyle);

String _renderToYaml(
  Map<String, dynamic> json,
  int nestingLevel,
  YamlStyle style,
) =>
    json.entries
        .map((entry) => _formatEntry(
              entry,
              nestingLevel,
              style,
            ))
        .join('\n');

String _formatEntry(
        MapEntry<String, dynamic> entry, int nesting, YamlStyle style) =>
    '${_indentation(nesting)}${entry.key}:${_formatValue(
      entry.value,
      nesting,
      style,
    )}';

String _formatValue(dynamic value, int nesting, YamlStyle style) {
  if (value is Map<String, dynamic>) {
    return '\n${_renderToYaml(value, nesting + 1, style)}';
  }
  if (value is List<dynamic>) {
    return '\n${_formatList(value, nesting + 1, style)}';
  }
  if (value is String) {
    if (_isMultilineString(value)) {
      return ' |\n${value.split('\n').map(
            (s) => '${_indentation(nesting + 1)}$s',
          ).join('\n')}';
    }
    if (_containsSpecialCharacters(value) ||
        (_containsFloatingPointPattern(value) &&
            style != YamlStyle.pubspecYaml)) {
      return ' "$value"';
    }
  }
  if (value == null) {
    return '';
  }
  return ' $value';
}

String _formatList(List<dynamic> list, int nesting, YamlStyle style) => list
    .map((dynamic value) =>
        '${_indentation(nesting)}-${_formatValue(value, nesting + 2, style)}')
    .join('\n');

String _indentation(int nesting) => _spaces(nesting * 2);

String _spaces(int n) => ''.padRight(n);

bool _isMultilineString(String s) => s.contains('\n');

bool _containsFloatingPointPattern(String s) =>
    s.contains(RegExp(r'[0-9]\.[0-9]'));

bool _containsSpecialCharacters(String s) =>
    _specialCharacters.any((c) => s.contains(c));
final _specialCharacters = r':{}[],&*#?|-<>=!%@\'.split('');
