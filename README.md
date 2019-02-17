# Relay

###### Library which uses modified BLoC pattern to listen to multiple updates in single builder widget.

### Example

Through simple implementation you can relay update from station
and subscribe via RelayBuilder.

RelayBuilder Widget can listen to more than one updates you can 
provide observers parameter a list of updates.

Like in below example, 

* first relay builder widget observes only on counter.
* second relay builder widget observes on both counter and name.

```dart
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
    relay(ExampleUpdate.name);
  }
}

class Example extends StatefulWidget {
  ExampleState createState() => ExampleState();
}

class ExampleState extends State<Example> {
  ExampleStation station;

  @override
  void initState() {
    super.initState();
    station = ExampleStation();
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
```

### Example With Use of Provider.

* main.dart
    
    Wrap Material App with Provider
    
```dart
    Provider(
      child : MaterialApp(
          ...
      ) , 
    );
```

* Widget

Extend ProviderWidget and ProviderState then you can access
the station object in deep hierarchies also.