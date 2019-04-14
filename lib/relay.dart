library relay;

import 'package:flutter/material.dart';

typedef AsyncRelayBuilder<S extends Store> = Widget Function(
    BuildContext context, S);

abstract class Store<U> {
  final _relay = Relay<U>();

  void relayMultiple(List<U> updates) {
    updates.forEach(relay);
  }

  void relay(U update) {
    _relay.add(update);
  }
}

typedef LazyStoreInitializer = Store Function();

class StoreManager {
  Map<Type, Store> _stores = Map();
  final Map<Type, LazyStoreInitializer> stores;

  Store get(Type type) {
    Store store = _stores[type];
    if (store == null) {
      store = stores[type]();
      _stores[type] = store;
    }
    return store;
  }

  StoreManager({@required this.stores});
}

class RelayBuilder<S extends Store<U>, U> extends StatefulWidget {
  final AsyncRelayBuilder<S> builder;
  final List<U> observers;
  final S store;

  Relay<U> get relay => store._relay;

  const RelayBuilder(
      {@required this.builder, @required this.observers, @required this.store});

  @override
  RelayState<S, U> createState() => RelayState();
}

class RelayState<S extends Store<U>, U> extends State<RelayBuilder<S, U>> {
  RelaySubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.relay.subscribe(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.store);
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
  final StoreManager manager;

  Provider({@required this.manager, Widget child}) : super(child: child);

  Store get(Type type) => manager.get(type);

  factory Provider.of(BuildContext context) =>
      context.ancestorWidgetOfExactType(Provider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}

class _StoreWrapper<S extends Store> {
  S store;
}

mixin ProviderMixin<S extends Store<U>, U> {
  final _wrapper = _StoreWrapper<S>();

  S getStore(BuildContext context) {
    if (_wrapper.store == null) _wrapper.store = Provider.of(context).get(S);
    return _wrapper.store;
  }

  RelaySubscription subscribe(BuildContext context, Function(U) subscriber) =>
      getStore(context)._relay.subscribe(subscriber);
}
