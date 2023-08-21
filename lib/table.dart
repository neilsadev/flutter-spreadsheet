import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'formula.dart';

class CustomSpreadSheetWidget extends StatefulWidget {
  const CustomSpreadSheetWidget({super.key});

  @override
  State<CustomSpreadSheetWidget> createState() =>
      _CustomSpreadSheetWidgetState();
}

class _CustomSpreadSheetWidgetState extends State<CustomSpreadSheetWidget> {
  var evaluator = FormulaEvaluator();
  dynamic tableJson;
  double tableWidth = 120.0;
  double tableHeight = 60.0;
  int maxChars = 1;
  bool dragHorizontally = true;

  String convertToCSV(List<List<String>> data) {
    StringBuffer csvBuffer = StringBuffer();

    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].length; j++) {
        csvBuffer.write(data[i][j]);
        if (j < data[i].length - 1) {
          csvBuffer.write(',');
        }
      }
      csvBuffer.writeln();
    }
    return csvBuffer.toString();
  }

  Map<String, Map<String, String>> convertToCustomJson(
      List<List<String>> data) {
    Map<String, Map<String, String>> result = {};

    List<String> columnLabels = data[0];

    for (int columnIndex = 0;
        columnIndex < columnLabels.length;
        columnIndex++) {
      String columnLabel =
          String.fromCharCode(65 + columnIndex); // Convert to A, B, C...
      Map<String, String> columnValues = {};

      for (int rowIndex = 1; rowIndex < data.length; rowIndex++) {
        String cellValue = data[rowIndex][columnIndex];
        columnValues[rowIndex.toString()] = cellValue;
      }

      result[columnLabel] = columnValues;
    }

    return result;
  }

  List<List<String>> data = [];

  void _incrementCounter() {
    String csv = convertToCSV(data);
    Map<String, Map<String, String>> convertedJson = convertToCustomJson(data);
    String jsonString = json.encode(convertedJson);
    if (kDebugMode) {
      print(csv);
      print(jsonString);
    }
  }

  int getRowCount() {
    return data.length;
  }

  int getColumnCount() {
    if (data.isEmpty) {
      return 0;
    }
    return data[0].length;
  }

  addRow() {
    List<String> newValueList = List.filled(data[0].length, "value");
    data.add(newValueList);
    setState(() {});
    tableJson = convertToCustomJson(data);
  }

  removeRow() {
    List<List<String>> updatedData = List.from(data);
    if (updatedData.isNotEmpty) {
      updatedData.removeLast();
    }
    setState(() {
      data = updatedData;
      tableJson = convertToCustomJson(data);
    });
  }

  addColumn() {
    int numColumns = data[0].length; // Get the number of existing columns

    List<List<String>> updatedData = [];
    for (int i = 0; i < data.length; i++) {
      List<String> sublist = List.from(data[i]);
      if (i == 0) {
        sublist.add("Cell${numColumns + 1}");
      } else {
        sublist.add("value");
      }
      updatedData.add(sublist);
    }

    setState(() {
      data = updatedData;
      tableJson = convertToCustomJson(data);
    });
  }

  removeColumn() {
    List<List<String>> updatedData = [];

    for (List<String> sublist in data) {
      if (sublist.isNotEmpty) {
        List<String> updatedSublist = List.from(sublist);
        updatedSublist.removeLast();
        updatedData.add(updatedSublist);
      }
    }

    setState(() {
      data = updatedData;
      tableJson = convertToCustomJson(data);
    });
  }

  generateTable() {
    List<List<String>> genTable = [
      ['Cell1', 'Cell2'],
      ['1', '2'],
    ];
    setState(() {
      data = genTable;
      tableJson = convertToCustomJson(data);
    });
  }

  List<String> extractCellReferencesFromFormula(String formula) {
    var cellReferences = <String>[];

    var start = formula.indexOf('(');
    var end = formula.lastIndexOf(')');

    if (start != -1 && end != -1 && end > start) {
      var references = formula.substring(start + 1, end);
      var referenceStrings = references.split(',');

      for (var referenceString in referenceStrings) {
        var trimmedReference = referenceString.trim();
        if (trimmedReference.isNotEmpty) {
          cellReferences.add(trimmedReference);
        }
      }
    }

    return cellReferences;
  }

  String updateFormulaWithJsonValues(String formula, dynamic convertedJson) {
    var params = extractCellReferencesFromFormula(formula);

    var updatedFormula = formula;
    for (var param in params) {
      var key = param[0];
      var subKey = param.substring(1);
      if (convertedJson.containsKey(key) &&
          convertedJson[key].containsKey(subKey)) {
        var value = convertedJson[key][subKey];
        updatedFormula = updatedFormula.replaceFirst(param, value);
      }
    }

    return updatedFormula;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateTable();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              dragHorizontally = !dragHorizontally;
            });
          },
          child: Container(
            width: 30.0,
            height: 15.0,
            decoration: BoxDecoration(
              color: dragHorizontally ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: dragHorizontally ? 15.0 : 0.0,
                  child: Container(
                    width: 15.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width + 75 * getColumnCount(),
                  child: Center(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, rowIndex) {
                        return Row(
                          children:
                              List.generate(data[rowIndex].length, (colIndex) {
                            return Container(
                              width: tableWidth,
                              height: tableHeight,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Draggable(
                                axis: dragHorizontally
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                feedback:
                                    Container(), // Empty container during drag
                                onDragUpdate: (details) {
                                  if (dragHorizontally) {
                                    setState(() {
                                      tableWidth += details.delta.dx;
                                    });
                                  } else {
                                    setState(() {
                                      tableHeight += details.delta.dy;
                                    });
                                  }
                                },
                                onDragEnd: (details) {
                                  if (dragHorizontally) {
                                    if (tableWidth < 50.0) {
                                      setState(() {
                                        tableWidth =
                                            50.0; // Set a minimum width
                                      });
                                    }
                                  } else {
                                    if (tableHeight < 50.0) {
                                      setState(() {
                                        tableHeight =
                                            50.0; // Set a minimum height
                                      });
                                    }
                                  }
                                },
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  key: Key(data[rowIndex][colIndex]),
                                  initialValue: data[rowIndex][colIndex],
                                  onFieldSubmitted: (newValue) {
                                    if (newValue.startsWith("=")) {
                                      newValue = newValue.toUpperCase();
                                      var evaluatedValue = evaluator
                                          .evaluate(updateFormulaWithJsonValues(
                                              newValue, tableJson))
                                          .toString();

                                      setState(() {
                                        data[rowIndex][colIndex] =
                                            evaluatedValue;
                                        tableJson = convertToCustomJson(data);
                                      });
                                    } else {
                                      if (newValue.length > maxChars &&
                                          newValue.length > 13) {
                                        setState(() {
                                          tableWidth +=
                                              5 * (newValue.length - 13);
                                        });
                                      }
                                      setState(() {
                                        data[rowIndex][colIndex] = newValue;
                                        tableJson = convertToCustomJson(data);
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: getRowCount() * tableHeight,
                  left: -15,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          addRow();
                        },
                        icon: const Icon(
                          Icons.add_box,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeRow();
                        },
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -15,
                  left: getColumnCount() * tableWidth,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          addColumn();
                        },
                        icon: const Icon(
                          Icons.add_box,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeColumn();
                        },
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
