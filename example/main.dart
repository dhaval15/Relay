import 'dart:math';

import 'package:flutter/material.dart' hide Action;
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

class IncrementAction extends Action{
  IncrementAction() : super(null);
}

class NameAction extends Action{
  NameAction(String name) : super(name);
}

class CounterUpdate extends Update{
  CounterUpdate() : super(null);
}

class NameUpdate extends Update {
  NameUpdate(String name) : super(name);
}

class MessageUpdate extends Update{
  MessageUpdate(String message) : super(message);
}

class ExampleStore extends Store {
  int counter = 0;

  @override
  Stream<Update> onAction(Action action) async*{
    if(action is IncrementAction) {
      if (counter < 10) {
        counter++;
        yield CounterUpdate();
      } else {
        final snackBarMessage = 'Maximum Limit Reached';
        yield MessageUpdate(snackBarMessage);
      }
    }
    else if(action is NameAction){
      yield NameUpdate(action.params);
    }
  }
}

class Example extends StatefulWidget {
  @override
  ExampleState createState() => ExampleState();
}

class ExampleState extends State<Example>
    with ProviderMixin<ExampleStore> {
  void onUpdate(Update update) {
    if (update is MessageUpdate)
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(update.data)));
  }

  @override
  Widget build(BuildContext context) {
    final store = getStore(context);
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              RelayBuilder<ExampleStore>(
                store: getStore(context),
                observers: [CounterUpdate],
                builder: (context, data) => Text('${data[CounterUpdate]}'),
              ),
              RelayBuilder<ExampleStore>(
                store: getStore(context),
                observers: [NameUpdate,CounterUpdate],
                builder: (context, data) =>
                    Text('${data[NameUpdate]} : ${data[CounterUpdate]}'),
              ),
              TextField(
                onChanged: (name) => store.dispatchAction(NameAction(name)),
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => store.dispatchAction(IncrementAction()),
        child: Icon(Icons.add),
      ),
    );
  }
}
