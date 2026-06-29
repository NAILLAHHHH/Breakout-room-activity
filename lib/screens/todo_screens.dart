import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:breakout_room_activity/services/todo_service.dart';
 
class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  void _addTodo() async {
    if (_controller.text.trim().isNotEmpty) {
      try {
        await TodoService.addTodo(_controller.text.trim());

        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todo added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding todo: $e')),
        );
      }
    }
  }

  void _toggleTodo(String id, bool currentStatus) async {
    try {
      await TodoService.toggleTodo(id, currentStatus);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  void _deleteTodo(String id) async {
    try {
      await TodoService.deleteTodo(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo deleted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  void _editTodo(DocumentSnapshot todo) {
    _editController.text = todo['task'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Todo'),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(hintText: 'Enter new task'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_editController.text.trim().isNotEmpty) {
                try {
                  await TodoService.updateTodo(
                    todo.id,
                    _editController.text.trim(),
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todo updated!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating todo: $e')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCompletedTodos() async {
    try {
      await TodoService.deleteCompletedTodos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completed todos cleared!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing completed todos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Todo App'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _deleteCompletedTodos,
            tooltip: 'Clear Completed',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: TodoService.getTodosStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data!.docs;

                if (todos.isEmpty) {
                  return Center(
                    child: Text('No todos yet! Add a new todo to get started.'),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: todo['completed'],
                          onChanged: (_) =>
                              _toggleTodo(todo.id, todo['completed']),
                        ),
                        title: Text(
                          todo['task'],
                          style: TextStyle(
                            decoration: todo['completed']
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTodo(todo),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTodo(todo.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
