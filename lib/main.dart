import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=15030a3e";

void main() async {
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
          ))));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();
  double dolar;
  double euro;
  double bitcoin;
  double ibovespa;
  double nasdaq;
  double variationDolar;
  double variationEuro;
  double variationBitcoin;
  double variationIbovespa;
  double variationNasdaq;

  void _realChanged(String text) {
            if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(8);
  }

  void _dolarChanged(String text) {
        if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    bitcoinController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(8);
  }

  void _euroChanged(String text) {
        if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(8);
  }

  void _bitcoinChanged(String text) {
        if(text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dollarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
    bitcoinController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center),
                );
              } else {
                print(snapshot.data);
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                variationDolar =
                    snapshot.data["results"]["currencies"]["USD"]["variation"];
                variationEuro =
                    snapshot.data["results"]["currencies"]["EUR"]["variation"];
                variationBitcoin =
                    snapshot.data["results"]["currencies"]["BTC"]["variation"];
                ibovespa =
                    snapshot.data["results"]["stocks"]["IBOVESPA"]["points"];
                nasdaq = snapshot.data["results"]["stocks"]["NASDAQ"]["points"];
                variationIbovespa =
                    snapshot.data["results"]["stocks"]["IBOVESPA"]["variation"];
                variationNasdaq =
                    snapshot.data["results"]["stocks"]["NASDAQ"]["variation"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildtextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildtextField(
                          "Dolares", "US\$ ", dollarController, _dolarChanged),
                      Divider(),
                      buildtextField(
                          "Euros", "€ ", euroController, _euroChanged),
                      Divider(),
                      buildtextField("Bitcoin", "BTC ", bitcoinController,
                          _bitcoinChanged),
                      Divider(),
                      buildField("Valor Dolar", dolar.toStringAsFixed(2),
                          variationDolar.toString()),
                      Divider(),
                      buildField("Valor Euro", euro.toStringAsFixed(2),
                          variationEuro.toString()),
                      Divider(),
                      buildField("Valor Bitcoin", bitcoin.toString(),
                          variationBitcoin.toString()),
                      Divider(),
                      buildFieldStocks("Ibovespa", ibovespa.toStringAsFixed(2),
                          variationIbovespa.toString()),
                      Divider(),
                      buildFieldStocks("Nasdaq", nasdaq.toStringAsFixed(2),
                          variationNasdaq.toString())
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildtextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Widget buildField(String label, String value, String variation) {
  return Text(
    "$label : $value ($variation %)",
    style: TextStyle(
        color: returnColor(variation),
        fontStyle: FontStyle.italic,
        fontSize: 15.0),
  );
}

Widget buildFieldStocks(String label, String value, String variation) {
  return Text(
    "$label : $value ($variation %)",
    style: TextStyle(
        color: returnColor(variation),
        fontStyle: FontStyle.italic,
        fontSize: 15.0),
  );
}

Color returnColor(String value) {
  if (double.parse(value) > 0) {
    return Colors.green;
  } else {
    return Colors.red;
  }
}
