import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/Widgets/new_item.dart';
import 'package:shopping_list/models/grocery_items.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});
  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];

  @override
  //we want to send our first request when screen is open for the first time
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
        'fast-sign-398618-default-rtdb.europe-west1.firebasedatabase.app',
        'shopping-list.json');
    final response = await http.get(url);
    // print(response.body);
    //now we want to load the database data on to our screen
    //its a nested map first map is a String 'Category' inner map
    //is string values ie 'category,name,quantity'
    final Map<String, dynamic> listData = json.decode(response.body);
    //create a temporary list to hold put the database values before loading them
    final List<GroceryItem> loadedItems = [];

    //go through every item in the database
    for (final item in listData.entries) {
      //checking if the 'item's category is the same as that in the database'
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;

      loadedItems.add(GroceryItem(
          //id is autogenerated by firebase
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    //now we move the overwrite our local list with database values.
    setState(() {
      groceryItems = loadedItems;
    });
  }

//'async holds the date and
// helps you retrieve the new item
//when you go to add it to the screen

  void addItem() async {
    /* final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));
   if (newItem == null) {
      return;
   
//if we do have a new item then add it to the screen and display the updated
//ui
    setState(() {
      _groceryItems.add(newItem);
    });
  }*/
    //use this code if adding item to the database.
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    loadItems();
  }

  void removeItem(
    GroceryItem item,
  ) {
    //saves the position of grocery item before it's deleted.
    final groceryIndex = groceryItems.indexOf(item);
    // print(expenseIndex);
    // print(groceryIndex);
    setState(() {
      groceryItems.remove(item);
    });
    //ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Groceries deleted'),
        duration: const Duration(seconds: 60),
        action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                //here we retrieve the deleted data from the list
                //by accessing the position it was using 'expenseIndex'
                groceryItems.insert(groceryIndex, item);
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'Please add some Items',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    );

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: groceryItems
              .length, // How much item you want to create using ListView...
          itemBuilder: (context, index) => Dismissible(
                //dismiss needs a unique indentifier so it knows what its dismissing

                onDismissed: (direction) {
                  //remove item by its index
                  removeItem(groceryItems[index]);
                },

                key: ValueKey(groceryItems[index].id),

                child: ListTile(
                  // this index means each value...
                  title: Text(groceryItems[index].name),
                  leading: Container(
                      width: 24,
                      height: 24,
                      color: groceryItems[index].category.color),
                  trailing: Text(groceryItems[index].quantity.toString()),
                ),
              ));
    }
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  addItem();
                },
                icon: const Icon(Icons.add))
          ],
          title: const Text('Groceries List'),
        ),
        body: content);
  }
}
