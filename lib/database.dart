import 'package:sqflite/sqflite.dart';


abstract class TableElement{
  int id;
  final String tableName;
  TableElement(this.id, this.tableName);
  void createTable(Database db);
  Map<String, dynamic> toMap();
}

//Creacion tabla y clase Educacion

//Tablas Alumno, Maestro, Grado, Seccion, Inscripccion es-es

class Student extends TableElement{
  static final String TABLE_NAME = "alumno";
  String names, surnames, birthday;

  Student({this.names, this.surnames, this.birthday, id}):super(id, TABLE_NAME);
  factory Student.fromMap(Map<String, dynamic> map){
    return Student(names: map["names"], surnames: map['surnames'], birthday: map['birthday'], id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    db.rawUpdate("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, names varchar(50), surnames varchar(50), birthday date)");
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"names":this.names, "surnames":this.surnames, "birthday":this.birthday};
    if(this.id != null){
      map["_id"] = id;
    }
    return map;
  }

}

//Class Teachers Table
class Teacher extends TableElement{
  static final String TABLE_NAME = "teacher";
  String names, surnames, birthday, dpi;

  Teacher({this.names, this.surnames, this.birthday, this.dpi, id}):super(id, TABLE_NAME);
  factory Teacher.fromMap(Map<String, dynamic> map){
    return Teacher(names: map["names"], surnames: map['surnames'], birthday: map['birthday'], dpi: map['dpi'], id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    db.rawUpdate("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, names varchar(50), surnames varchar(50), birthday date, dpi varchar(20))");
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"names":this.names, "surnames":this.surnames, "birthday":this.birthday};
    if(this.id != null){
      map["_id"] = id;
    }
    return map;
  }

}

class Grade extends TableElement{
  static final String TABLE_NAME = "grade";
  String description;

  Grade({this.description, id}):super(id, TABLE_NAME);
  factory Grade.fromMap(Map<String, dynamic> map){
    return Grade(description: map["description"],  id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    db.rawUpdate("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, description varchar(20))");
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"description":this.description};
    if(this.id != null){
      map["_id"] = id;
    }
    return map;
  }

}


final String DB_FILE_NAME = "crub.db";

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database _database;


  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await open();

    return _database;
  }

  Future<Database> open() async {
    try{
      String databasesPath = await getDatabasesPath();
      String path = "$databasesPath/$DB_FILE_NAME";
      var db  = await openDatabase(path,
          version: 1,
          onCreate: (Database database, int version) {
            new Student().createTable(database);
          });
      return db;
    }catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<List<Student>> getList() async{
    Database dbClient = await db;

    List<Map> maps = await dbClient.query(Student.TABLE_NAME,
        columns: ["_id", "names", "surnames", "birthday"]);

    return maps.map((i)=> Student.fromMap(i)).toList();
  }
  Future<TableElement> insert(TableElement element) async {
    var dbClient = await db;

    element.id = await dbClient.insert(element.tableName, element.toMap());
    print("new Id ${element.id}");
    return element;
  }
  Future<int> delete(TableElement element) async {
    var dbClient = await db;
    return await dbClient.delete(element.tableName, where: '_id = ?', whereArgs: [element.id]);

  }
  Future<int> update(TableElement element) async {
    var dbClient = await db;

    return await dbClient.update(element.tableName, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}









