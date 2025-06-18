import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Lista de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add_edit_todo': (context) => const AddEditTodoScreen(),
        '/about': (context) => const AboutScreen(),
      },
      debugShowCheckedModeBanner: false, // Remove o banner de "Debug"
    );
  }
}

// Model para a Tarefa
class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });

  // Converte um objeto Todo para um Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  // Cria um objeto Todo a partir de um Mapa
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
    );
  }
}

// home_screen.dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de tarefas (simulando um banco de dados simples)
  final List<Todo> _todos = [
    Todo(id: '1', title: 'Comprar Leite', description: 'Leite integral'),
    Todo(id: '2', title: 'Pagar Contas', isCompleted: true),
    Todo(id: '3', title: 'Estudar Flutter', description: 'Revisar navegação e estado'),
  ];

  // Função para adicionar ou editar uma tarefa
  void _addOrEditTodo({Todo? todo}) async {
    final result = await Navigator.pushNamed(
      context,
      '/add_edit_todo',
      arguments: todo, // Passa a tarefa se for edição
    );

    if (result != null && result is Todo) {
      setState(() {
        if (todo == null) {
          // Adiciona nova tarefa
          _todos.add(result);
        } else {
          // Edita tarefa existente
          final index = _todos.indexWhere((element) => element.id == result.id);
          if (index != -1) {
            _todos[index] = result;
          }
        }
        // Ordena a lista para que as tarefas não concluídas apareçam primeiro
        _todos.sort((a, b) {
          if (a.isCompleted == b.isCompleted) return 0;
          if (a.isCompleted) return 1; // b é não concluída, a é concluída (a vai para o final)
          return -1; // a é não concluída, b é concluída (a vai para o início)
        });
      });
    }
  }

  // Função para marcar/desmarcar tarefa como concluída
  void _toggleTodoCompletion(Todo todo) {
    setState(() {
      todo.isCompleted = !todo.isCompleted;
      // Reordena a lista
      _todos.sort((a, b) {
        if (a.isCompleted == b.isCompleted) return 0;
        if (a.isCompleted) return 1;
        return -1;
      });
    });
  }

  // Função para remover uma tarefa
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
      body: _todos.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma tarefa adicionada ainda!\nUse o botão "+" para adicionar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (bool? value) {
                  _toggleTodoCompletion(todo);
                },
                activeColor: Colors.green,
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.isCompleted ? Colors.grey : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: todo.description.isNotEmpty
                  ? Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.isCompleted
                      ? Colors.grey[600]
                      : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: () {
                      _addOrEditTodo(todo: todo);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _showDeleteConfirmationDialog(todo.id);
                    },
                  ),
                ],
              ),
              onTap: () {
                _addOrEditTodo(todo: todo);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTodo(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Diálogo de confirmação de exclusão
  void _showDeleteConfirmationDialog(String todoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta tarefa?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _deleteTodo(todoId);
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

// add_edit_todo_screen.dart
class AddEditTodoScreen extends StatefulWidget {
  const AddEditTodoScreen({super.key});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _todoId;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Todo? todo = ModalRoute.of(context)?.settings.arguments as Todo?;
    if (todo != null) {
      _isEditing = true;
      _todoId = todo.id;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description;
    } else {
      _todoId = DateTime.now().millisecondsSinceEpoch.toString(); // ID único para nova tarefa
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final newTodo = Todo(
        id: _todoId!,
        title: _titleController.text,
        description: _descriptionController.text,
        isCompleted: false, // Nova tarefa começa como não concluída
      );
      // Se for edição, mantém o status de conclusão original
      if (_isEditing && ModalRoute.of(context)?.settings.arguments != null) {
        final originalTodo = ModalRoute.of(context)?.settings.arguments as Todo;
        newTodo.isCompleted = originalTodo.isCompleted;
      }

      Navigator.pop(context, newTodo); // Retorna a nova tarefa para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Adicionar Nova Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título da Tarefa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título para a tarefa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// about_screen.dart
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Aplicativo'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minha Lista de Tarefas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Versão: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Este é um aplicativo de exemplo simples para gerenciar suas tarefas diárias.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Funcionalidades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('- Adicionar novas tarefas'),
            Text('- Editar tarefas existentes'),
            Text('- Marcar tarefas como concluídas/incompletas'),
            Text('- Excluir tarefas'),
            Text('- Navegação entre 3 telas: Home, Adicionar/Editar e Sobre.'),
            SizedBox(height: 20),
            Text(
              'Desenvolvido com Flutter.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}