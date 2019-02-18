import 'package:flutter/material.dart';
import '../lib/relay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        title: 'Relay Example',
        home: Example(),
      ),
    );
  }
}

enum ExampleUpdate { counter, name, message }

class ExampleStation extends Station<ExampleUpdate> {
  int counter = 0;
  String name = '';
  String snackBarMessage;

  void increment() {
    if (counter < 10) {
      counter++;
      relay(ExampleUpdate.counter);
    } else {
      snackBarMessage = 'Maximum Limit Reached';
      relay(ExampleUpdate.message);
    }
  }

  void updateName(String text) {
    name = text;
    relay(ExampleUpdate.name);
  }
}

class Example extends ProviderWidget<ExampleStation> {
  ExampleState createState() => ExampleState();

  @override
  ExampleStation get station => ExampleStation();
}

class ExampleState
    extends ProviderState<Example, ExampleStation, ExampleUpdate> {
  @override
  void onUpdate(ExampleUpdate update) {
    super.onUpdate(update);
    if (update == ExampleUpdate.message)
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(station.snackBarMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              RelayBuilder<ExampleStation, ExampleUpdate>(
                station: station,
                observers: [ExampleUpdate.counter],
                builder: (context, station) => Text('${station.counter}'),
              ),
              RelayBuilder<ExampleStation, ExampleUpdate>(
                station: station,
                observers: [ExampleUpdate.name, ExampleUpdate.counter],
                builder: (context, station) =>
                    Text('${station.name} : ${station.counter}'),
              ),
              TextField(
                onChanged: station.updateName,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: station.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
