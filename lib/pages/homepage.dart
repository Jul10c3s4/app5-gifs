import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HhomePageState();
}

class HhomePageState extends State<HomePage> {
  String _search = "";
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.asset("images/title.gif"),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Pesquise aqui!',
                      labelStyle: TextStyle(color: Colors.white),
                      // enabledBorder habilita algumas configurações da borda
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      )),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                    //s
                    onSubmitted: (text) {
                      _search = text;
                      _offset = 0;
                    },
                  )
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder(
                    future: _getGifs(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5,
                            ),
                          );
                        default:
                          if (snapshot.hasError) {
                            return Container(
                              child: Text('ERRO'),
                            );
                          } else {
                            return _createGifTable(context, snapshot);
                          }
                      }
                    })),
          ],
        ));
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search.isEmpty) {
      //na uri abaixo foi acessado o site developers.giphy.com(um site que fornece uma api de gifs) e foi pego uma apikey criada no site, a url abaixo é formada pelo endereço do site junto com a apikey e alguns atributos encontrados no site
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=ADLW6jk07vn3S9QrBWlneu4C8zZUDB7U&limit=20&rating=G"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=ADLW6jk07vn3S9QrBWlneu4C8zZUDB7U&q=$_search&limit=19&offset=$_offset&rating=G&lang=en"));
    }
    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search.isEmpty || index < snapshot.data["Data"].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]['fixed_heigth']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {},
            onLongPress: () {},
          );
        } else {
          return SizedBox(
            child: GestureDetector(
              child: Column(
                children: [
                  Icon(
                    Icons.add,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
