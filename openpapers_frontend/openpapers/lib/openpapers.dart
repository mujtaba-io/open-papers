import 'dart:js_interop';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backyard.dart';
import 'theme.dart'; // Import the theme file

import 'dart:html'; // for web only
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'clickable_card_widget.dart';

import 'custom_snackbar.dart';

class OpenPapers extends StatefulWidget {
  final String currentDirectoryPath;
  final List<String> currentDirectoryContents;

  OpenPapers({
    Key? key,
    required this.currentDirectoryPath,
    required this.currentDirectoryContents,
  }) : super(key: key);

  @override
  _OpenPapersState createState() => _OpenPapersState();
}

class _OpenPapersState extends State<OpenPapers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RosePineDawnColors.base,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'COMSATS Open Papers',
                    style: GoogleFonts.courierPrime(
                      fontSize:
                          MediaQuery.of(context).size.width < 764 ? 16 : 26,
                      letterSpacing:
                          -2.0, // Add this line to reduce character spacing
                      color: RosePineDawnColors.text,
                    ),
                  ),
                  const Spacer(),
                  // Add a small search bar
                  Container(
                    width: MediaQuery.of(context).size.width < 764 ? 128 : 256,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: RosePineDawnColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: RosePineDawnColors.overlay),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: RosePineDawnColors.text),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search papers, assignments...',
                              hintStyle: TextStyle(
                                color: RosePineDawnColors.muted,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Contribute',
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: user must navigate to relevant page where they can upload a file
                        // this reduces need to ask course, year etc otherise show alert box error

                        /* 
                        protocol of path:
                        /<course>/<type>/<file>
                        type=assignmetns/quizes/lab manuals...
                        */
                        if (countFolders(widget.currentDirectoryPath) < 2) {
                          // show snackbar

                          showCustomSnackBar(
                            context,
                            'Please navigate to the relevant course folders to upload. Cannot find course folder?',
                            countFolders(widget.currentDirectoryPath) == 0
                                ? SnackBarAction(
                                    label: 'Add Course',
                                    textColor: Colors.white,
                                    backgroundColor: RosePineDawnColors.rose,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();

                                      // show alertbox with name of course

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Enter course name',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // add course to the path
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Add'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                : SnackBarAction(
                                    label: 'Dismiss',
                                    textColor: Colors.white,
                                    backgroundColor: RosePineDawnColors.rose,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                    },
                                  ),
                          );
                          return;
                        }

                        uploadNewFile();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: RosePineDawnColors.iris,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: RosePineDawnColors.base),
                          Text(
                            (MediaQuery.of(context).size.width < 764)
                                ? 'Upload'
                                : 'Upload New Paper',
                            style:
                                const TextStyle(color: RosePineDawnColors.base),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      232.0, // Adjust minimum width per card here
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: widget.currentDirectoryContents.length,
                itemBuilder: (context, index) {
                  //return _buildItemCard(index);
                  return ClickableCard(
                    text: widget.currentDirectoryContents[index],
                    onTap: () {
                      // atempt to download the file. if it fails, open the folder
                      final filePath = (widget.currentDirectoryPath +
                              '/' +
                              widget.currentDirectoryContents[index])
                          .replaceAll(RegExp(r'/+'), '/');
                      final url = makeUrl(filePath);

                      getDirectoryContents(filePath).then((value) {
                        if (value != null) {
                          updateCurrentDirectory(
                              widget.currentDirectoryContents[index]);
                        } else {
                          window.open(url, '_blank');
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Text('This is a non-profit project for COMSATS students.',
                  style: TextStyle(color: RosePineDawnColors.muted)),
              const SizedBox(height: 8),
              Text(
                'Made with ❤️ by Mujtaba',
                style: TextStyle(color: RosePineDawnColors.love),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void uploadNewFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<PlatformFile> files = result.files;

      for (PlatformFile file in files) {
        // Check the file's size using the bytes property
        int fileSizeInBytes = file.size;

        if (fileSizeInBytes > (8 * 1024 * 1024)) {
          // File exceeds limit, handle error
          print('Error: File "${file.name}" exceeds the 8MB size limit.');
          continue; // Skip uploading this file and continue with others
        }

        // Prepare and upload the file
        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
        });

        try {
          Response response = await Dio().post(
            makeUrl(widget.currentDirectoryPath),
            data: formData,
          );
          print(response.data);
        } catch (e) {
          print('Error uploading file: $e');
        }
      }
    }
  }

  Future<void> updateCurrentDirectory(String nextFolder) async {
    final nextDirectoryPath = widget.currentDirectoryPath + '/' + nextFolder;
    final directoryContents = await getDirectoryContents(nextDirectoryPath);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return OpenPapers(
          currentDirectoryPath: (widget.currentDirectoryPath + '/' + nextFolder)
              .replaceAll(RegExp(r'/+'), '/'),
          currentDirectoryContents: directoryContents ?? [],
        );
      }),
    );
  }
}
