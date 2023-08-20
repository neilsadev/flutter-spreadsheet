class FormulaEvaluator {
  final Map<String, Function> _formulas = {
    'SUM': (List<double> numbers) => numbers.reduce((a, b) => a + b),
    'AVERAGE': (List<double> numbers) =>
        numbers.reduce((a, b) => a + b) / numbers.length,
    'COUNT': (List<double> numbers) => numbers.length.toDouble(),
    'MAX': (List<double> numbers) => numbers.reduce((a, b) => a > b ? a : b),
    'MIN': (List<double> numbers) => numbers.reduce((a, b) => a < b ? a : b),
    // You might need to define more functions here
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
