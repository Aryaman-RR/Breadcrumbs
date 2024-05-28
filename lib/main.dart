import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbsProvider(),
      child: MaterialApp(
        title: 'Project 1',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    );
  }
}

class BreadCrumb {
  final String uuid;
  bool isActive;
  final String name;

  BreadCrumb({required this.isActive, required this.name})
      : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) {
    return other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbsProvider extends ChangeNotifier {
  final List<BreadCrumb> _crumbs = [];
  UnmodifiableListView<BreadCrumb> get crumbs => UnmodifiableListView(_crumbs);

  void add(BreadCrumb crumb) {
    for (final item in crumbs) {
      item.activate();
    }
    _crumbs.add(crumb);
    notifyListeners();
  }

  void reset() {
    _crumbs.clear();
    notifyListeners();
  }
}

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({Key? key, required this.breadCrumbs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...breadCrumbs.map((item) {
          return Text(
            item.title,
            style: TextStyle(color: item.isActive ? Colors.blue : Colors.black),
          );
        })
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.select((BreadCrumbsProvider provider) => provider.crumbs);
    return Scaffold(
      appBar: AppBar(title: const Text('Project 1')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<BreadCrumbsProvider>(
              builder: (context, value, child) {
                return BreadCrumbsWidget(breadCrumbs: value.crumbs);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/new');
              },
              child: const Text('Add new breadcrumb'),
            ),
            TextButton(
              onPressed: () {
                context.read<BreadCrumbsProvider>().reset();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  _NewBreadCrumbWidgetState createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new breadcrumb')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(labelText: 'Enter a new breadcrumb'),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context
                    .read<BreadCrumbsProvider>()
                    .add(BreadCrumb(isActive: false, name: _controller.text));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
