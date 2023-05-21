import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

final ValueNotifier<List> props = ValueNotifier([]);
final ValueNotifier<bool> isLoading = ValueNotifier(false);
final ValueNotifier<int> itemsQuantity = ValueNotifier(5);
final ValueNotifier<int> currentData = ValueNotifier(0);

List<VoidCallback> dataValues = [
  carregarCafes,
  carregarCervejas,
  carregarPaises
];

Future<void> carregarCervejas() async {
  isLoading.value = true;
  var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': "${itemsQuantity.value} "});

  var jsonString = http.read(beersUri);
  var json = await jsonString;

  props.value = jsonDecode(json);
  currentData.value = 1;
  isLoading.value = false;
}

Future<void> carregarPaises() async {
  isLoading.value = true;
  var nationsUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': "${itemsQuantity.value} "});

  var jsonString = http.read(nationsUri);

  var json = await jsonString;

  props.value = jsonDecode(json);
  currentData.value = 2;
  isLoading.value = false;
}

Future<void> carregarCafes() async {
  isLoading.value = true;
  var coffesUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': "${itemsQuantity.value} "});

  var jsonString = http.read(coffesUri);

  var json = await jsonString;

  props.value = jsonDecode(json);
  currentData.value = 0;
  isLoading.value = false;
}

enum SampleItem { itemOne, itemTwo, itemThree }

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    dataValues[currentData.value]();

    return Scaffold(
      appBar: AppBar(
        title: Text("App"),
        actions: [
          PopupMenuButton(
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('5 itens'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('10 itens'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      child: Text('15 itens'),
                    ),
                  ],
              onSelected: (e) {
                switch (e) {
                  case SampleItem.itemOne:
                    itemsQuantity.value = 5;
                    dataValues[currentData.value]();
                    break;
                  case SampleItem.itemTwo:
                    itemsQuantity.value = 10;
                    dataValues[currentData.value]();
                    break;
                  case SampleItem.itemThree:
                    itemsQuantity.value = 15;
                    dataValues[currentData.value]();
                    break;
                }
              }),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: props,
          builder: (_, value, __) {
            return isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.purple,
                  ))
                : GenericItem(objects: [...value]);
          }),
      bottomNavigationBar: NavbarCustom(),
    );
  }
}

class NavbarCustom extends HookWidget {
  NavbarCustom();

  @override
  Widget build(BuildContext context) {
    final buttontapped = useState(0);
    print("NavbarCustom");

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
            label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
        BottomNavigationBarItem(
            label: "Nações", icon: Icon(Icons.flag_outlined))
      ],
      onTap: (index) {
        buttontapped.value = index;
        dataValues[index]();
      },
      currentIndex: buttontapped.value,
    );
  }
}

class GenericItem extends StatelessWidget {
  List<Map<String, dynamic>> objects;

  GenericItem({this.objects = const []});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(30),
      itemCount: objects.length,
      itemBuilder: (context, index) {
        final titles = objects[index].keys.toList();
        final values = objects[index].values.toList();

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: titles
                .map((e) => Text(
                      "$e: ${values[titles.indexOf(e)]}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                    ))
                .toList(),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

// Usar apenas na receita 5
class NewNavbar extends StatefulWidget {
  const NewNavbar({super.key});
  @override
  _NewNavbarState createState() => _NewNavbarState();
}

class _NewNavbarState extends State<NewNavbar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
            label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
        BottomNavigationBarItem(
            label: "Nações", icon: Icon(Icons.flag_outlined))
      ],
      onTap: (value) => setState(() {
        _selectedIndex = value;
      }),
      currentIndex: _selectedIndex,
    );
  }
}
