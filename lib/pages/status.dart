import 'package:band_name/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    //socketService.socket.emit(event)

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ServerStatus: ${socketService.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed:(){
          //tarea
          socketService.emit('emitir-mensaje', {'nombre':'Flutter','mensaje':'Hola desde flutter'});
        }
      ),
    );
  }
}