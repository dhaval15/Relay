import 'package:flutter/material.dart';
import 'package:relay/relay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      manager: StoreManager(
        stores: {
          ExampleStore: () => ExampleStore(),
        },
      ),
      child: MaterialApp(
        title: 'Relay Example',
        home: Example(),
      ),
    );
  }
}

enum ExampleUpdate { counter, name, message }

class ExampleStore extends Store<ExampleUpdate> {
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

class Example extends StatefulWidget {
  @override
  ExampleState createState() => ExampleState();
}

class ExampleState extends State<Example>
    with ProviderMixin<ExampleStore, ExampleUpdate> {
  void onUpdate(ExampleUpdate update) {
    if (update == ExampleUpdate.message)
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(getStore(context).snackBarMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              RelayBuilder<ExampleStore, ExampleUpdate>(
                store: getStore(context),
                observers: [ExampleUpdate.counter],
                builder: (context, store) => Text('${store.counter}'),
              ),
              RelayBuilder<ExampleStore, ExampleUpdate>(
                store: getStore(context),
                observers: [ExampleUpdate.name, ExampleUpdate.counter],
                builder: (context, store) =>
                    Text('${store.name} : ${store.counter}'),
              ),
              TextField(
                onChanged: getStore(context).updateName,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getStore(context).increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
