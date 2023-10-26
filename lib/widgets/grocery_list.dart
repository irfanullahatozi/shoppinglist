import 'package:flutter/material.dart';
// import 'package:shoppinglist/data/dummy_items.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:shoppinglist/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> groceryItem = [];

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

  void removeItem(GroceryItem item) {
    setState(() {
      groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

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
