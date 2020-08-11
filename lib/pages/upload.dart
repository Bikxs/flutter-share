import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  const Upload({Key key, this.currentUser}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool _isUploading = false;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _captionController = TextEditingController();
  String postId = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }

  Widget buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                'Upload image',
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  Widget buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: [
          _isUploading ? linearProgress() : Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35),
            title: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none),
            ),
            subtitle: Container(
              alignment: Alignment.topLeft,
              child: RaisedButton.icon(
                onPressed: () => getUserLocation(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  'Use current location',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future selectImage(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Image from gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cance;'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleTakePhoto() async {
    Navigator.pop(context);
    File takenFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960.0);
    setState(() {
      this.file = takenFile;
    });
  }

  Future<void> handleChooseFromGallery() async {
    Navigator.pop(context);
    File takenFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = takenFile;
    });
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  Future<void> compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    im.Image imagefile = im.decodeImage(file.readAsBytesSync());
    final compressedFile = File('$path/img_$postId,jpg')
      ..writeAsBytesSync(im.encodeJpg(imagefile, quality: 85));

    setState(() {
      file = compressedFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> handleSubmit() async {
    setState(() {
      _isUploading = true;
    });

    await compressImage();
    String mediaUrl = await uploadImage(file);
    await createPostInFirestore(
      description: _captionController.text,
      location: _locationController.text,
      mediaUrl: mediaUrl,
    );
  }

  Future<void> createPostInFirestore({
    @required String mediaUrl,
    @required String location,
    @required String description,
  }) async {
    await postRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timeStamp': timeStamp,
      'likes': {}
    });
    _locationController.clear();
    _captionController.clear();
    setState(() {
      file = null;
      _isUploading = false;
      postId = Uuid().v4();
    });
  }

  Future<void> getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      String formatedAddress = '${placemark.locality}, ${placemark.country}';
    }
  }
}
