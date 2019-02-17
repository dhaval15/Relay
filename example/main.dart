import 'package:flutter/material.dart';
import 'lib/relay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: OKToast(
        child: MaterialApp(
          title: 'Relay Example',
          body:Example()
        ),
      ),
    );
  }
}

enum ExampleUpdate { counter, name }

class ExampleStation extends Station<ExampleUpdate> {
  int counter = 0;
  String name = '';
  
  void increment() {
    counter++;
    relay(ExampleUpdate.counter);
  }
  
  void updateName(String text) {
    name = text;
  }
}

class Example extends ProviderWidget<ExampleStation> {
  ExampleState createState() => ExampleState();

  @override
  ExampleStation get station => ExampleStation();
}

class ExampleState extends ProviderState<Example,ExampleStation> {
  
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