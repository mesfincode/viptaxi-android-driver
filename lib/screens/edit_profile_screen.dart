import 'dart:convert';
import 'dart:io';

import 'package:driver/components/upload_profile.dart';
import 'package:driver/constants.dart';
import 'package:driver/screens/home_screen2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:driver/controllers/request_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  RequestController authController = Get.find();
  File? _profileImage;
  File? _listenceImageFile;
  bool isLoading = false;
  Future<void> _pickProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickListenceImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _listenceImageFile = File(pickedImage.path);
      });
    }
  }

  Future<String> uploadBinaryFileToParse(File file) async {
    var extension = path.extension(file.path);
    var fileType = extension.toLowerCase();
    var filename = '';
    var contentType = 'application/octet-stream';
    if (fileType == '.jpeg') {
      contentType = 'image/jpeg';
      filename = 'filename.jpeg';
    } else if (fileType == '.jpg') {
      contentType = 'image/jpeg';
      filename = 'filename.jpg';
    } else if (fileType == '.png') {
      filename = 'filename.png';

      contentType = 'image/png';
    }

    var url;
    if (PRODUCTION) {
      url = Uri.parse('$PROD_BASE_URL/files/$filename');
    } else {
      url = Uri.parse('$DEV_BASE_URL/files/$filename');
    }
    var request = http.Request('POST', url);
    request.headers['X-Parse-Application-Id'] = APP_NAME;
    request.headers['X-Parse-REST-API-Key'] = APP_REST_API_KEY;
    request.headers['Content-Type'] = contentType;

    // var fileStream = http.ByteStream(file.openRead());
    // var fileLength = await file.length();

    try {
      var bytes = await file.readAsBytes();
      request.bodyBytes = bytes;

      var response = await request.send().timeout(Duration(seconds: 5));;
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        var name = jsonResponse['name'];
        var url = jsonResponse['url'];
        return url;
      } else {
        return '';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print(e);
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set up your profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_profileImage != null) ...[
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickProfileImage(ImageSource.gallery),
                            child: Stack(
                               alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius:
                                      50, // Adjust the radius according to your preference
                                  backgroundImage: FileImage(_profileImage!),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors
                                            .white, // Adjust the border color if needed
                                        width: 2, // Adjust the border width if needed
                                      ),
                                    ),
                                  ),
                                ),
                                 Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      
                              ],
                            ),
                          ),
                          Text("Your Profile Image")
                        ],
                      ),
                      // SizedBox(height: 16),
                      // ElevatedButton(
                      //   onPressed: _uploadImage,
                      //   child: Text('Upload Image'),
                      // ),
                    ] else ...[
                       Column(
                         children: [
                           Center(
        child: GestureDetector(
          onTap: () => _pickProfileImage(ImageSource.gallery),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/default_profile.jpeg'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            
            ],
          ),
        ),
      ),
       Text("Your Profile Image")
                         ],
                       ),
                      
                      // ElevatedButton(
                      //   onPressed: () => _pickProfileImage(ImageSource.gallery),
                      //   child: Text('Upload Your Photo'),
                      // ),
                    ],

                    if (_listenceImageFile != null) ...[
                      Column(
                        children: [
                          GestureDetector(
                              onTap:() =>_pickListenceImage(ImageSource.gallery) ,
                            child: Stack(
                               alignment: Alignment.bottomRight,
                              children: [
                                
                                Image.file(_listenceImageFile!,height: 300,),
                                  Positioned(
                                           right: 8,
                                           bottom: 50,
                                           child: Container(
                                             padding: EdgeInsets.all(4),
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.blue,
                                             ),
                                             child: Icon(
                                               Icons.edit,
                                               color: Colors.white,
                                             ),
                                           ),
                                         ),
                              ],
                            ),
                          ),
                          Text("Your driver licence")
                        ],
                      ),

                      // SizedBox(height: 16),
                      // ElevatedButton(
                      //   onPressed: _uploadImage,
                      //   child: Text('Upload Image'),
                      // ),
                    ] else ...[
                       Column(
                         children: [
                           GestureDetector(
                            onTap:() =>_pickListenceImage(ImageSource.gallery) ,
                             child: Center(
                                   child: Stack(
                                     alignment: Alignment.bottomRight,
                                     children: [
                                       Image.asset(
                                         'assets/images/default_licence_img.png',
                                         height: 200,
                                        //  width: 300,
                                         fit: BoxFit.cover,
                                       ),
                                       Positioned(
                                         right: 8,
                                         bottom: 8,
                                         child: Container(
                                           padding: EdgeInsets.all(4),
                                           decoration: BoxDecoration(
                                             shape: BoxShape.circle,
                                             color: Colors.blue,
                                           ),
                                           child: Icon(
                                             Icons.edit,
                                             color: Colors.white,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                           ),
                            Text("Your driver licence")
                         ],
                       ),
                      // ElevatedButton(
                      //   onPressed: () =>_pickListenceImage(ImageSource.gallery),
                      //   child: Text('Upload your Licence'),
                      // ),
                    ],
                    // SizedBox(height: 16),
                  ],
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Obx(() {
                  if (authController.isLoading || isLoading) {
                    return CircularProgressIndicator();
                  } else {
                    return Container(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 247, 89, 80),
                          padding: EdgeInsets.all(
                              12), // Adjust the padding as needed
                          shadowColor: const Color.fromARGB(255, 19, 16, 16),
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Adjust the border radius as needed
                          ),
                          side: BorderSide(
                            color: const Color.fromARGB(255, 240, 116,
                                107), // Set the color of the button outline
                            width: 2.0, // Set the width of the button outline
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Save changes to user profile
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Profile updated')),
                            // );
                            setState(() {
                              isLoading = true;
                            });
                            String firstName = _firstNameController.text;
                            String lastName = _lastNameController.text;
                            String email = _emailController.text;
                            if (_profileImage == null) {
                              Get.snackbar(
                                "Vip Taxi",
                                "Please select profile image",
                                backgroundColor:
                                    const Color.fromARGB(255, 54, 225, 244),
                                icon: const Icon(Icons.add_alert),
                                snackPosition: SnackPosition.TOP,
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            } else if (_listenceImageFile == null) {
                              Get.snackbar(
                                "Vip Taxi",
                                "Please upload your driver licence",
                                backgroundColor:
                                    const Color.fromARGB(255, 54, 225, 244),
                                icon: const Icon(Icons.add_alert),
                                snackPosition: SnackPosition.TOP,
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            String profileUrl =
                                await uploadBinaryFileToParse(_profileImage!);

                            String lisenceUrl = await uploadBinaryFileToParse(
                                _listenceImageFile!);
                            setState(() {
                              isLoading = false;
                            });

                            if (profileUrl.length > 0 &&
                                lisenceUrl.length > 0) {
                              authController
                                  .createDriver(firstName, lastName, email,
                                      profileUrl, lisenceUrl)
                                  .then((value) => {
                                        if (value)
                                          {Get.offAll(() => HomeScreen2())}
                                        else
                                          {
                                            print("errr-------------"),
                                            setState(() {
                                              isLoading = false;
                                            })
                                          }
                                      });
                            } else {
                              Get.snackbar(
                                "Vip Taxi",
                                "Failed to upload image try again !",
                                backgroundColor: Colors.red,
                                icon: const Icon(Icons.add_alert),
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                            // uploadBinaryFileToParse(_profileImage!)
                            //     .then((profileUrl) => {

                            //         });
                          }
                        },
                        child: Text(
                          'Create Driver Profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize:
                                16, // Set the font size of the button text
                            fontWeight: FontWeight
                                .bold, // Set the font weight of the button text
                            // color: Color.fromARGB(255, 113, 185, 244), // Set the color of the button text
                          ),
                        ),
                      ),
                    );
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
