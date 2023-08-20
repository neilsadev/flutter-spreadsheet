import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'formula.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var evaluator = FormulaEvaluator();
  Map<String, Map<String, String>>? tableJson;

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
    List<List<String>> updatedData = [];
    for (List<String> sublist in data) {
      List<String> updatedSublist = List.from(sublist);
      updatedSublist.add("value");
      updatedData.add(updatedSublist);
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
      ['Column1', 'Column2'],
      ['Cell1', 'Cell2'],
    ];
    setState(() {
      data = genTable;
      tableJson = convertToCustomJson(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: data.isEmpty
            ? MaterialButton(
                onPressed: () {
                  generateTable();
                },
                color: Colors.blue,
                child: const Text(
                  "Generate Table",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width +
                          75 * getColumnCount(),
                      child: Center(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (context, rowIndex) {
                            return Row(
                              children: List.generate(data[rowIndex].length,
                                  (colIndex) {
                                return Container(
                                  width: 100,
                                  height: 50,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    initialValue: data[rowIndex][colIndex],
                                    onSaved: (newValue) {
                                      if (newValue == null) {
                                        return;
                                      }
                                      if (newValue.startsWith("=")) {
                                        setState(() {
                                          data[rowIndex][colIndex] = evaluator
                                              .evaluate(newValue)
                                              .toString();
                                          tableJson = convertToCustomJson(data);
                                        });
                                      } else {
                                        setState(() {
                                          data[rowIndex][colIndex] = newValue;
                                          tableJson = convertToCustomJson(data);
                                        });
                                      }
                                    },
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: getRowCount() * 50,
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
                      left: getColumnCount() * 100,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.download),
      ),
    );
  }
}
