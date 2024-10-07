import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String results = 'results to be shown here';

  late Interpreter interpreter;

  late TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController();

    Interpreter.fromAsset('assets/linear.tflite').then(
      (value) => setState(
        () => interpreter = value,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    interpreter.close();

    super.dispose();
  }

  void performAction() {
    final double? value = double.tryParse(textController.text);

    if (value != null) {
      final List<double> input = [value];

      final output = List.filled(1 * 1, 0).reshape([1, 1]);

      interpreter.run(input, output);

      setState(() {
        results = 'Result: ${output[0][0]}';
        textController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                onEditingComplete: performAction,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration:
                    const InputDecoration(hintText: ' Insert The value'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: performAction,
                child: const Text('Predict'),
              ),
              const SizedBox(height: 16),
              Text(
                results,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
