library relay;

import 'package:flutter/material.dart';
import 'dart:async';

typedef AsyncRelayBuilder = Widget Function(
    BuildContext context, dynamic data);

typedef AsyncMultiRelayBuilder = Widget Function(
    BuildContext context, Map<Type, dynamic>);

class Update {
  final data;

  Update(this.data);
}

class Action {
  final params;

  Action(this.params);
}

abstract class Store {
  final _relay = Relay<Update>();

  void dispatchAction(Action action) {
    onAction(action).listen(_relay.add);
  }

  Stream<Update> onAction(Action action);
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

class RelayBuilder<S extends Store> extends StatefulWidget {
  final AsyncRelayBuilder builder;
  final Type observer;
  final dynamic initialData;
  final S store;

  RelayBuilder(
      {@required this.builder,
      @required this.observer,
      this.store,
      this.initialData});

  @override
  RelayState<S> createState() => RelayState();
}

class RelayState<S extends Store> extends State<RelayBuilder<S>> {
  RelaySubscription _subscription;
  S store;
  dynamic data;

  Relay<Update> get relay => store._relay;

  @override
  void initState() {
    super.initState();
    data = widget.initialData;
    store = widget.store ?? Provider.of(context).get(S);
    _subscription = relay.subscribe(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, data);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _onUpdate(Update update) {
    final type = update.runtimeType;
    if (widget.observer == type)
      setState(() {
        data = update.data;
      });
  }
}

class MultiRelayBuilder<S extends Store> extends StatefulWidget {
  final AsyncMultiRelayBuilder builder;
  final List<Type> observers;
  final Map<Type, dynamic> _data = {};
  final S store;

  MultiRelayBuilder(
      {@required this.builder, @required this.observers, this.store});

  @override
  MultiRelayState<S> createState() => MultiRelayState();
}

class MultiRelayState<S extends Store> extends State<MultiRelayBuilder<S>> {
  RelaySubscription _subscription;
  S store;

  Relay<Update> get relay => store._relay;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? Provider.of(context).get(S);
    _subscription = relay.subscribe(_onUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget._data);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  void _onUpdate(Update update) {
    //print(update.toString());
    final type = update.runtimeType;
    final data = update.data;
    if (widget.observers.contains(type))
      setState(() {
        widget._data[type] = data;
      });
  }
}

class Dispatcher<S extends Store> extends StatelessWidget {
  final Function(BuildContext, S store) builder;

  const Dispatcher({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    S store = Provider.of(context).get(S);
    return builder(context, store);
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

mixin ProviderMixin<S extends Store> {
  final _wrapper = _StoreWrapper<S>();

  S getStore(BuildContext context) {
    if (_wrapper.store == null) _wrapper.store = Provider.of(context).get(S);
    return _wrapper.store;
  }

  RelaySubscription subscribe(
          BuildContext context, Function(Update) subscriber) =>
      getStore(context)._relay.subscribe(subscriber);
}
