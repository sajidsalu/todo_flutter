import 'package:flutter/material.dart';
import 'package:todo_flutter/db/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String,dynamic>> _journals =[];

  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
  }

  void _showForm(int? id) async{
    if(id != null){
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(context: context, builder: (_)=> Container(
      padding: EdgeInsets.only(top: 15,
      left: 15,
      right: 15,
      bottom: MediaQuery.of(context).viewInsets.bottom+20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 10,),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(onPressed: () async{
              if(id == null){
                await _addItem();
              }
              if(id != null){
                await _updateItem(id);
              }

              _titleController.text ='';
              _descriptionController.text = '';
              Navigator.of(context).pop();
          }, child: Text(id == null ? 'Create New':'Update'))
        ],
      ),

    ));
  }

  Future<void> _addItem() async{
    await SQLHelper.createItem(_titleController.text, _descriptionController.text);
    _refreshJournals();
  }
  
  Future<void> _updateItem(int id) async{
    await SQLHelper.updateItem(id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }
  
  void _deleteItem(int id) async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted a journal'),));
    _refreshJournals();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          _showForm(null);
        },
      ),
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: _isLoading?
      const Center(
        child: CircularProgressIndicator(),
      ):
      ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index)=> Card(
            color: Colors.orange.shade200,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                     _showForm(_journals[index]['id']);
                    }, icon: Icon(Icons.edit)),
                    IconButton(onPressed: (){
                      _deleteItem(_journals[index]['id']);
                    }, icon: Icon(Icons.delete)),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
