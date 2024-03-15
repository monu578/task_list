import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:task_app/todo_model.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late ScrollController _scrollController;
  late List<Todo> _todos;
  late bool _isLoading;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _todos = [];
    _isLoading = false;
    _loadTodos();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      // Reach the bottom of the list
      _loadTodos();
    }
  }

  Future<void> _loadTodos() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos?_page=$_page&_limit=50'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _todos.addAll(jsonData.map((e) => Todo.fromJson(e)).toList());
          _page++;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load todos');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _buildTodoList(),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _todos.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _todos.length) {
          return _buildProgressIndicator();
        } else {
          final todo = _todos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Card(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${todo.id}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      todo.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(
                  'User ID: ${todo.userId}, Completed: ${todo.completed.toString()}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildProgressIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
