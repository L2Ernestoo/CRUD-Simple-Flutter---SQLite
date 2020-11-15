import 'package:flutter/material.dart';
import 'package:crud_calidad/database.dart';

final String DB_NAME = "school";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD - Ernesto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  List<Student> _list;
  DatabaseHelper _databaseHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Proyecto 1 - Escuela"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              insert(context);
            },
          )
        ],
      ),
      body: _getBody(),
    );
  }



  void insert(BuildContext context) {
    Student student = new Student();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Ingreso Alumnos"),
            content: Center(
            child: Column(
              children: <Widget>[
                Container(
                  child: TextField(
                    onChanged: (names) {
                      student.names = names;
                    },
                    decoration: InputDecoration(labelText: "Nombres:"),
                  ),
          ),
                  Container(
                  child: TextField(
                    onChanged: (surnames) {
                      student.surnames = surnames;
                    },
                    decoration: InputDecoration(labelText: "Apellidos:"),
                  ),
          ),
                  Container(
                  child: TextField(
                    onChanged: (birthday) {
                      student.birthday = birthday;
                    },
                    decoration: InputDecoration(labelText: "Fecha Nacimiento:"),
                    keyboardType: TextInputType.datetime,
                  ),
                )
              ],
            ),
          ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Guardar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.insert(student).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  void onDeletedRequest(int index) {
    Student student = _list[index];
    _databaseHelper.delete(student).then((value) {
      setState(() {
        _list.removeAt(index);
      });
    });
  }

  void onUpdateRequest(int index) {
    Student nNombre = _list[index];
    final controller = TextEditingController(text: nNombre.names);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Modificar"),
            content: TextField(
              controller: controller,
              onChanged: (value) {
                nNombre.names = value;
              },
              decoration: InputDecoration(labelText: "Título:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Actualizar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.update(nNombre).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  Widget _getBody() {
    if (_list == null) {
      return CircularProgressIndicator();
    } else if (_list.length == 0) {
      return Center(
        child: Text("No hay registros",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35)),
      );
    } else {
      return ListView.builder(
          itemCount: _list.length,
          itemBuilder: (BuildContext context, index) {
            Student student = _list[index];
            return StudentWidget(
                student, onDeletedRequest, index, onUpdateRequest);
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
    updateList();
  }

  void updateList() {
    _databaseHelper.getList().then((resultList) {
      setState(() {
        _list = resultList;
      });
    });
  }
}

typedef OnDeleted = void Function(int index);
typedef OnUpdate = void Function(int index);

class StudentWidget extends StatelessWidget {
  final Student student;
  final OnDeleted onDeleted;
  final OnUpdate onUpdate;
  final int index;
  StudentWidget(this.student, this.onDeleted, this.index, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${student.id}"),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(student.names + '' + student.surnames + ' | ' + student.birthday),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 30,
              ),
              onPressed: () {
                this.onUpdate(index);
              },
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        onDeleted(this.index);
      },
    );
  }
}
