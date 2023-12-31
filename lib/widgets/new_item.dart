import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final formKey = GlobalKey<FormState>();
  var enteredName = '';
  var quantity = 1;
  var selectedCategory = categories[Categories.vegetables]!;
  var isSending = false;
  void saveItem() async {
    formKey.currentState!.validate();
    formKey.currentState!.save();
    setState(() {
      isSending = true;
    });
    try {
      final url = Uri.https(
          'flutterprac-40ede-default-rtdb.firebaseio.com', 'shoping-list.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            "name": enteredName,
            "quantity": quantity,
            "category": selectedCategory.title,
          },
        ),
      );
      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> resData = json.decode(response.body);
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: enteredName,
          quantity: quantity,
          category: selectedCategory,
        ),
      );
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                initialValue: enteredName,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  enteredName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: quantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be valid positive number";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        quantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title.toString()),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: isSending
                        ? null
                        : () {
                            formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : saveItem,
                    child: isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
