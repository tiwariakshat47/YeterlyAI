import 'package:flutter/material.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 56.0,
            left: 24.0,
            bottom: 24.0,
            right: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "Here is where the sign prediction result will be...",
                  style: Theme.of(context).textTheme.headlineSmall
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  border: Border.all(
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                width: 400.0,
                height: 400.0,
                child: Center(
                  child: Text("image here"),
                ),
              ),
              SizedBox(height: 10.0),
              Text("Prediction: ___", style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 10.0),
              PredictionSurvey()
            ],
          ),
        ),
      ),
    );
  }
}

class PredictionSurvey extends StatelessWidget {
  const PredictionSurvey({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      width: 400.0,
      height: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "How is our prediction?",
              style: Theme.of(context).textTheme.headlineSmall,
          ),
          PredictionRadio(),
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
              padding: WidgetStatePropertyAll(EdgeInsets.only(
                left: 15.0,
                top: 10.0,
                right: 15.0,
                bottom: 10.0,
              )),
            ),
            child: Text("Submit", style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}

class PredictionRadio extends StatefulWidget {
  const PredictionRadio({super.key});

  @override
  State<PredictionRadio> createState() => _PredictionRadioState();
}

class _PredictionRadioState extends State<PredictionRadio> {
  String? result = "Incorrect";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 160),
            child: ListTile(
              title: Text(
                'Correct',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              leading: Radio(
                value: "Correct",
                groupValue: result,
                onChanged: (String? value) {
                  setState(() {
                    result = value;
                  });
                },
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 170),
            child: ListTile(
              title: Text(
                'Incorrect',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              leading: Radio(
                value: "Incorrect",
                groupValue: result,
                onChanged: (String? value) {
                  setState(() {
                    result = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


