import 'dart:io';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band>  bands = [
    //Band(id: '1', name: 'Xnor', votes: 5),
    //Band(id: '2', name: 'Mariusal', votes: 1),
    //Band(id: '3', name: 'Marius', votes: 2),
    //Band(id: '4', name: 'Andresilent', votes: 5),
  ];

  @override
  void initState() { 
    final socketService = Provider.of<SocketService>(context,listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }
  
  _handleActiveBands(dynamic payload){
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();

      setState(() {});

  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context,listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.green,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right:10),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.black)
              : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context,i)=>_bandTile(bands[i])
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen:false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => socketService.emit('delete-band',{'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.green,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band',style: TextStyle(color: Colors.white)),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.green[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}',style: TextStyle(fontSize: 20)),
        onTap: ()=>socketService.socket.emit('vote-band',{'id': band.id}),
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if(Platform.isAndroid){
      //platarma android 
    return showDialog(
      context:context,
      builder: (_)=> AlertDialog(
          title: Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.green,
              onPressed: () => addBandToList(textController.text)
            )
          ],
      )
    );
  }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        )
    );
  }

  void addBandToList(String name){
    if(name.length > 1){
      //podemos agregar
      final socketService = Provider.of<SocketService>(context,listen:false);
      socketService.emit('add-band',{'name': name});
    }
    Navigator.pop(context);
  }

  //Mostrar grafica
  Widget _showGraph(){
    Map<String, double> dataMap = new Map();
    bands.forEach((band){
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final colorList = [
      Colors.red[300],
      Colors.black,
      Colors.orange[300],
      Colors.green[300],
      Colors.grey[300],
      Colors.purple[300],
    ];
    return Container(
      padding: EdgeInsets.only(top:10),
      width: double.infinity,
      height: 200,
      child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          centerText: "Conteo",
          legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        //showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
      ),
    )
    );
  }

}