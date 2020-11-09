import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:core';

const request = "https://api.hgbrasil.com/finance?format=json&key=a463ecb1";

void main() async{

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
  ),
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      accentColor: Colors.white,
  ),
  ),
  );
}

Future<Map> pegarInformacoes() async {
  http.Response resposta = await http.get(request);
  return json.decode(resposta.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final ControladorReal = TextEditingController();
  final ControladorDolar = TextEditingController();
  final ControladorEuro = TextEditingController();

  double dollar;
  double euro;

  void _clearAll(){
    ControladorReal.text = "";
    ControladorDolar.text = "";
    ControladorEuro.text = "";
  }

  void MudarReal(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    ControladorDolar.text = (real/dollar).toStringAsFixed(2);
    ControladorEuro.text = (real/euro).toStringAsFixed(2);
  }

  void MudarDolar(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    ControladorReal.text = (dolar * dollar).toStringAsFixed(2);
    ControladorEuro.text = (dolar * dollar / euro).toStringAsFixed(2);
  }

  void MudarEuro(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    ControladorReal.text = (euro * this.euro).toStringAsFixed(2);
    ControladorDolar.text = (euro * this.euro / dollar).toStringAsPrecision(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title:Text("Conversor de Moedas"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: pegarInformacoes(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError) {
                return Center(
                  child: Text("Erro ao Carregar Dados!",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 15),
                          child: Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                        ),
                        CriarTextField("Reais", "R\$", ControladorReal, MudarReal),
                        Divider(),
                        CriarTextField("Dólares", "US\$", ControladorDolar, MudarDolar),
                        Divider(),
                        CriarTextField("Euros", "EUR", ControladorEuro, MudarEuro),
                      ],
                    ),
                  ),
                );
              }
          } //Switch
        } // FutureBuilder(Builder)
      ),
    );
  }
}

Widget CriarTextField(String label, String prefix, TextEditingController Controlador, Function Funcao) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.amber,
          fontSize: 20),
      border: OutlineInputBorder(),
      prefix: Text("$prefix  ", style: TextStyle(
        color: Colors.amber,
        fontSize: 20,
      ),
      ),
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 20,
    ),
    controller: Controlador,
    onChanged: Funcao,
    keyboardType: TextInputType.number,
  );
}
