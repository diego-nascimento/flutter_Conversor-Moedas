import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


const request = "https://api.hgbrasil.com/finance?key=67bc8452";

void main(){
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));

}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<Map> getData() async{
    http.Response  response = await http.get(request);
    return json.decode(response.body);
  }
  double dolar;
  double euro;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void realChanged(String text){
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void dolarChanged(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }

  void euroChanged(String text){
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  void reset(){
    realController.text = dolarController.text = euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: reset,
          )
        ],
      ),
      body:
      FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando Dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 30.0
                    )
                  ),
                );
              default:
                if(snapshot.hasError){
                  return Center(
                    child: Text("Erro ao carregar Dados",
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 30.0
                        )
                    ),
                  );
                }else{
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber
                        ),
                        buildTextField("Reais", "R\$ ", realController, realChanged),
                        Divider(),
                       buildTextField("Dolares", "US\$", dolarController, dolarChanged ),
                        Divider(),
                        buildTextField("Euros", "EU\$ ", euroController, euroChanged)
                      ],
                    ),
                  );
                }
            }
          }
      )
    );
  }
}

buildTextField(String label, String Prefix, TextEditingController c, Function f ){
  return TextField(
    onChanged: f,
    controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: Prefix,
          prefixStyle: TextStyle(color: Colors.amber)
      ),
      style: TextStyle(
          color: Colors.amber
      )
  );
}
