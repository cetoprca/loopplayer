import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPicker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return AudioPickerState();
  }

}

class AudioPickerState extends State<AudioPicker>{
  final OnAudioQuery onAudioQuery = OnAudioQuery();

  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  void _requestPermission() async {
    bool hasPermission = await onAudioQuery.permissionsStatus();
    if(!hasPermission) {
      hasPermission = await onAudioQuery.permissionsRequest();

      var permissions = await [Permission.audio, Permission.photos, Permission.videos, Permission.storage, Permission.manageExternalStorage].request();

      hasPermission = permissions.values.every((status) => status.isGranted);

      print(hasPermission);
    }

    print(hasPermission);

    if (hasPermission) {
      print("Load");
      _loadSongs();
    }
  }

  void _loadSongs() async{
    List<SongModel> songs = await onAudioQuery.querySongs();
    setState(() {
      print(songs);
      _songs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Picker"), backgroundColor: Colors.orange,),
      body: Column(
        children: [
          Text("Canciones:"),
          ElevatedButton(onPressed: (){
            setState(() {
              print("Click!");
              _requestPermission();
            });
          }, child: Icon(Icons.loop)),
          SizedBox(
            height: 500,
            child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index){
                  SongModel songModel = _songs[index];

                  return ListTile(
                      title: Text("${songModel.title} from ${songModel.album} by ${songModel.artist}")
                  );
                }
            ),
          )
        ],
      )
    );
  }

}