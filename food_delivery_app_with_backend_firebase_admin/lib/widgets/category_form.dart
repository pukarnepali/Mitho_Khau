import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class CategoryForm extends StatefulWidget {
  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Category Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a category name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text;
              await Provider.of<MenuProvider>(context, listen: false)
                  .addCategory(name);

              // Show success message after adding the category
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "$name" successfully added!'),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.pop(context); // Close the dialog
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
