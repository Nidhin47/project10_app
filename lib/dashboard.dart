import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart'; // Import the package

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic> updatedData = {};
  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://script.google.com/macros/s/AKfycbwEOhnyA2XCDO-LdKRy2q8kfBC-VFASSHtSAQ72e_-Di0YUriZaXU3bbKi0sGTZV9S1/exec',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final farmData = List<Map<String, dynamic>>.from(jsonData['allData']);
        // Assuming the last entry is the updated data
        updatedData = farmData.isNotEmpty ? farmData.last : {};
      } else {
        throw Exception('Failed to load data from Google Sheets');
      }
    } catch (e) {
      print('Error fetching farm data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final CO2 = updatedData['Co2'];
    final TEMP = updatedData['Temp'];
    final HUMID = updatedData['Humid'];
    final CO = updatedData['Co'];

    return LiquidPullToRefresh(
        onRefresh: fetchData,
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orangeAccent.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'D A S H B O A R D',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              const SizedBox(height: 35.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            buildInfoUpdatedButton(
                              const Icon(Icons.co2, size: 45),
                              '$CO2 ppm',
                              () {},
                              'Carbon Dioxide',
                            ),
                            const SizedBox(height: 25.0),
                            buildInfoUpdatedButton(
                              const Icon(Icons.device_thermostat, size: 45),
                              '$TEMP °C',
                              () {},
                              'Temperature',
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            buildInfoUpdatedButton(
                              const Icon(Icons.water_drop_outlined, size: 45),
                              '$HUMID %',
                              () {},
                              'Humidity',
                            ),
                            const SizedBox(height: 25.0),
                            buildInfoUpdatedButton(
                              const Icon(Icons.grain, size: 45),
                              '$CO ppm',
                              () {},
                              'Carbon Monoxide',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllValuesScreen(latestData: updatedData),
                  ));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoUpdatedButton(
    Widget icon, String value, VoidCallback onTap, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: icon,
        ),
        const SizedBox(height: 7.0),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 7.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ALLVALUES SCREEN SECTION CODES SHOWING THE TABLEVIEW OF ALL SENSOR READINGS

class AllValuesScreen extends StatelessWidget {
  final Map<String, dynamic> latestData; // Use latestData instead of farmData

  AllValuesScreen({required this.latestData});

  @override
  Widget build(BuildContext context) {
    // Define the table columns
    final columns = ['Datetime', 'Co2', 'Temp', 'Humid', 'Co'];

    // Create a list of DataColumn based on the columns
    final dataColumns = columns.map((column) {
      return DataColumn(
        label: Text(
          column,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }).toList();

    // Create a list of DataRow with the latest data
    final dataRows = [
      DataRow(
        color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          return Colors.yellow.shade400; // You can customize the color
        }),
        cells: [
          DataCell(Text(latestData['datetime'].toString())),
          DataCell(Text(latestData['Co2'].toString())),
          DataCell(Text(latestData['Temp'].toString())),
          DataCell(Text(latestData['Humid'].toString())),
          DataCell(Text(latestData['Co'].toString()),
           ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Sensor Readings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orangeAccent.shade200,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              icon: const Icon(Icons.more_vert),
              onSelected: (String value) {
                if (value == 'google_sheet') {
                  launch('https://docs.google.com/spreadsheets/d/1bzajHj7za6Midg-NCh677zRwZhygrAr6ohAc35XPZKs/edit#gid=0');
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'google_sheet',
                    child: Text('Google Sheet'),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: const BoxDecoration(
                ),
                child: DataTable(
                  columns: dataColumns,
                  rows: dataRows,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
