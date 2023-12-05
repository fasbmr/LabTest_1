import 'package:flutter/material.dart';
import 'Model/bmical.dart';
import 'controller/sqlite_db.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();

}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmivalueController = TextEditingController();
  final TextEditingController bmistatusController = TextEditingController();
  String genderMF = " ";

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    List<Map<String, dynamic>> data = await SQLiteDB().queryAll(BMIcal.SQLiteTable);
    if (data.isNotEmpty) {
      Map<String, dynamic> lastEntry = data.last;
      nameController.text = lastEntry['username'];
      heightController.text = lastEntry['height'].toString();
      weightController.text = lastEntry['weight'].toString();
      genderMF = lastEntry['gender'];
      calculateBMI();
    }
  }

  void _addbmi() async {
    String username = nameController.text.trim();
    String weight = weightController.text.trim();
    String height = heightController.text.trim();
    String gender = genderMF.trim();

    if (username.isNotEmpty && weight.isNotEmpty && height.isNotEmpty && gender.isNotEmpty) {
      try {
        double parsedWeight = double.parse(weight);
        double parsedHeight = double.parse(height);

        setState(() {
          calculateBMI();
        });
        String bmiStatus = bmistatusController.text.trim();
        BMIcal bmical = BMIcal(username, parsedWeight, parsedHeight, gender, bmiStatus);
        await bmical.save();
        setState(() {
          nameController.clear();
          heightController.clear();
          weightController.clear();
        });

      } catch (e) {
        print("Error parsing double: $e");
      }
    } else {
      print("Invalid input data");
    }
    }

  void calculateBMI() {

    setState(() {
      double _height = double.parse(heightController.text) / 100;
      double _weight = double.parse(weightController.text);
      double bmi = _weight / (_height * _height);
      bmivalueController.text = bmi.toStringAsFixed(2);

      if (genderMF == 'Male') {
        if (bmi < 18.5)
          bmistatusController.text = 'Underweight. Careful during strong wind!';
        else if (bmi >= 18.5 && bmi <= 24.9)
          bmistatusController.text = 'That’s ideal! Please maintain';
        else if (bmi >= 25.0 && bmi <= 29.9)
          bmistatusController.text = 'Overweight! Work out please';
        else
          bmistatusController.text = 'Whoa Obese! Dangerous mate!';
      } else if (genderMF == 'Female') {
        if (bmi < 16)
          bmistatusController.text = 'Underweight. Careful during strong wind!';
        else if (bmi >= 16 && bmi <= 22)
          bmistatusController.text = 'That’s ideal! Please maintain';
        else if (bmi >= 22 && bmi <= 27)
          bmistatusController.text = 'Overweight! Work out please';
        else
          bmistatusController.text = 'Whoa Obese! Dangerous mate!';
      }
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('BMI Calculator'),
        ),
        body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Fullname',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText: 'Height in cm; 170',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight in KG',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: bmivalueController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Bmi Value',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Male'),
                        leading: Radio(
                          value: 'Male',
                          groupValue: genderMF,
                          onChanged: (String? value) {
                            setState(() {
                              genderMF = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Female'),
                        leading: Radio(
                          value: 'Female',
                          groupValue: genderMF,
                          onChanged: (String? value) {
                            setState(() {
                              genderMF = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: _addbmi,
                  child: Text('Calculate BMI and save'),
                ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text( bmistatusController.text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
          )
                )
              ],
            )
        )
    );
  }
}