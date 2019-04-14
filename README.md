# Relay

###### Library which uses modified BLoC pattern to listen to multiple updates in single builder widget.

#### Import

```dart
import 'package:relay/relay.dart';
```

### Example

Through simple implementation you can relay update from station
and subscribe via RelayBuilder.

RelayBuilder Widget can listen to more than one updates you can 
provide observers parameter a list of updates.

Like in below example, 

* first relay builder widget observes only on counter.
* second relay builder widget observes on both counter and name.

```dart
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
                builder: (context, station) => Text('${station.counter}'),
              ),
              RelayBuilder<ExampleStore, ExampleUpdate>(
                store: getStore(context),
                observers: [ExampleUpdate.name, ExampleUpdate.counter],
                builder: (context, station) =>
                    Text('${station.name} : ${station.counter}'),
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
```

### Example With Use of Provider.

* main.dart
    
    Wrap Material App with Provider
    
```dart
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
```

* Widget

Extend ProviderWidget and ProviderState then you can access
the station object in deep hierarchies also.