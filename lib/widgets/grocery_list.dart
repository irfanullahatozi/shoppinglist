import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
// import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:shoppinglist/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItem = [];
  var isLoading = true;
  String? isError;
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    try {
      final url = Uri.https(
          'flutterprac-40ede-default-rtdb.firebaseio.com', 'shoping-list.json');
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          isError = 'Failed to fetch data, Please try again later';
        });
      }

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
      }

      final Map<String, dynamic> dataList = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in dataList.entries) {
        final categoryMatch = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categoryMatch,
          ),
        );
      }
      setState(() {
        groceryItem = loadedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isError = 'Something went wrong!, Please try again later';
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItem.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    final index = groceryItem.indexOf(item);

    setState(() {
      groceryItem.remove(item);
    });

    final url = Uri.https('flutterprac-40ede-default-rtdb.firebaseio.com',
        'shoping-list/${item.id}.json');
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      setState(() {
        groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItem.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(groceryItem[index].id),
          onDismissed: (direction) {
            removeItem(groceryItem[index]);
          },
          child: ListTile(
            title: Text(groceryItem[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: groceryItem[index].category.color,
            ),
            trailing: Text(groceryItem[index].quantity.toString()),
          ),
        ),
      );
    }

    if (isError != null) {
      content = Center(
        child: Text(isError!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [
          IconButton(
            onPressed: addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }
}
