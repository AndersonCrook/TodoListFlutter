import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Models/Item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
    // items.add(Item(title: 'Item 1', done: true));
    // items.add(Item(title: 'Item 2', done: false));
    // items.add(Item(title: 'Item 3', done: true));
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController newTaskCtrl = TextEditingController();
  _HomePageState(){
    load();
  }

  void addItem(){
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.text = "";
      save();
    });
  }

  void removeItem(int index){
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async{
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    
    if(data != null){
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: TextFormField(
          keyboardType: TextInputType.text,
          controller: newTaskCtrl,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16
          ),
          decoration: InputDecoration(
            labelText: 'Adicionar tarefa',
            labelStyle: TextStyle(
              color: Colors.white
            )
          ),
        ),
      ),

      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index){
          final item = widget.items[index];
          return Dismissible(
            direction: DismissDirection.endToStart,
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value){
                setState(() {
                  item.done = value;
                  save();
                });
              }
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.9),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Excluir   ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ), 
                ),
              )
            ),
            onDismissed: (diriction){
              removeItem(index);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        
        onPressed: addItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
