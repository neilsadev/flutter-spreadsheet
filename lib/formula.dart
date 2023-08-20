import 'dart:math';

class FormulaEvaluator {
  final Map<String, Function> _formulas = {
    'SUM': (List<num> numbers) => numbers.reduce((a, b) => a + b),
    'AVERAGE': (List<num> numbers) =>
        numbers.reduce((a, b) => a + b) / numbers.length,
    'COUNT': (List<num> numbers) => numbers.length,
    'MAX': (List<num> numbers) => numbers.reduce((a, b) => a > b ? a : b),
    'MIN': (List<num> numbers) => numbers.reduce((a, b) => a < b ? a : b),
    'PRODUCT': (List<num> numbers) => numbers.reduce((a, b) => a * b),
    'MEDIAN': (List<num> numbers) {
      final sortedNumbers = [...numbers]..sort();
      if (sortedNumbers.length % 2 == 1) {
        return sortedNumbers[sortedNumbers.length ~/ 2];
      } else {
        final mid = sortedNumbers.length ~/ 2;
        return (sortedNumbers[mid - 1] + sortedNumbers[mid]) / 2;
      }
    },
    'POWER': (List<num> numbers) =>
        pow(numbers[0].toDouble(), numbers[1].toDouble()),
    'SQRT': (List<num> numbers) => sqrt(numbers[0].toDouble()),
    'LN': (List<num> numbers) => log(numbers[0].toDouble()),
    'LOG': (List<num> numbers) => log(numbers[0].toDouble()) / ln10,
    'EXP': (List<num> numbers) => exp(numbers[0].toDouble()),
    'ABS': (List<num> numbers) => numbers[0].abs().toDouble(),
    'ROUND': (List<num> numbers) => numbers[0].roundToDouble(),
    'CEILING': (List<num> numbers) => numbers[0].ceilToDouble(),
    'FLOOR': (List<num> numbers) => numbers[0].floorToDouble(),
    'MOD': (List<num> numbers) => numbers[0] % numbers[1],
    'SIN': (List<num> numbers) => sin(numbers[0].toDouble()),
    'COS': (List<num> numbers) => cos(numbers[0].toDouble()),
    'TAN': (List<num> numbers) => tan(numbers[0].toDouble()),
    'ASIN': (List<num> numbers) => asin(numbers[0].toDouble()),
    'ACOS': (List<num> numbers) => acos(numbers[0].toDouble()),
    'ATAN': (List<num> numbers) => atan(numbers[0].toDouble()),
  };

  double evaluate(String formula) {
    var parts = formula.split('(');
    if (parts.length < 2) {
      throw Exception('Invalid formula format');
    }

    var functionName =
        parts[0].toUpperCase().substring(1); // Remove the leading =
    var arguments = parts[1].replaceAll(')', '').split(',');

    if (!_formulas.containsKey(functionName)) {
      throw Exception('Unknown formula: $functionName');
    }

    var argumentsAsNumbers =
        arguments.map((arg) => double.tryParse(arg) ?? 0.0).toList();

    return _formulas[functionName]!(argumentsAsNumbers);
  }
}
