library relay;

import 'package:flutter/material.dart';

typedef AsyncRelayBuilder<S extends Station> = Widget Function(
    BuildContext context, S);

abstract class Station<U> {
  final _relay = Relay<U>();

  void relay(U update) {
    _relay.add(update);
  }
}

class RelayBuilder<S extends Station<U>, U> extends StatefulWidget {
  final AsyncRelayBuilder<S> builder;
  final List<U> observers;
  final S station;

  Relay<U> get relay => station._relay;

  const RelayBuilder(
      {@required this.builder,
      @required this.observers,
      @required this.station});

  @override
  RelayState<S, U> createState() => RelayState();
}

class RelayState<S extends Station<U>, U> extends State<RelayBuilder<S, U>> {
  RelaySubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.relay.subscribe(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.station);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _onUpdate(U update) {
    print(update.toString());
    if (widget.observers.contains(update)) setState(() {});
  }
}

class Relay<E> {
  final List<Function(E)> _listeners = [];

  void add(E event) {
    _listeners.forEach((callback) => callback(event));
  }

  RelaySubscription subscribe(Function(E) subscriber) {
    _listeners.add(subscriber);
    return RelaySubscription(() {
      _listeners.remove(subscriber);
    });
  }
}

class RelaySubscription {
  final Function _cancellation;

  RelaySubscription(this._cancellation);

  void cancel() {
    _cancellation();
  }
}

class Provider extends InheritedWidget {
  final Map<Type, Station> _objects = Map();

  Provider({Widget child}) : super(child: child);

  Station operator [](Type type) => _objects[type];

  void register(Type type, Station value) => _objects[type] = value;

  void unregister(Type type) => _objects[type] = null;

  factory Provider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(Provider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

abstract class ProviderWidget<S extends Station> extends StatefulWidget {
  S get station;
}

abstract class ProviderState<T extends ProviderWidget, S extends Station<U>, U>
    extends State<T> {
  S get station => widget.station;
  RelaySubscription _subscription;

  void onUpdate(U update) {}

  @override
  void initState() {
    super.initState();
    register(context);
    station._relay.subscribe(onUpdate);
  }

  void register(BuildContext context) {
    Provider.of(context).register(station.runtimeType, station);
  }

  void unRegister(BuildContext context) {
    Provider.of(context).unregister(station.runtimeType);
  }

  @override
  void dispose() {
    super.dispose();
    unRegister(context);
    _subscription.cancel();
  }
}
