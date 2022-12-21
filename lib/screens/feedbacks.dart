import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

import '../standards.dart';

class Feedbacks extends StatefulWidget {
  List<Reference> feedbackFiles;
  Feedbacks({Key? key, required this.feedbackFiles}) : super(key: key);

  @override
  State<Feedbacks> createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Standards.colors["blackColor"],
          ),
          // TODO: Implement Back Button
          // Tapping Back Button will return to the ROUTES TESTER (temporary)
          onPressed: () {
            setState(
              () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "Upload",
                        style: Standards.fontStyles["smallerMain"],
                      ),
                      const Spacer(),
                      Text(
                        "Feedback",
                        style: Standards.fontStyles["smallerMain"],
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.black),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.feedbackFiles.length,
                  itemBuilder: (context, index) {
                    var feedback = widget.feedbackFiles[index];

                    return FutureBuilder(
                      future: feedback.getMetadata(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var dateCreated = snapshot.data?.timeCreated;
                          var filetype = snapshot.data?.contentType;
                          var fullPath = snapshot.data?.fullPath;

                          return Column(
                            children: [
                              ListTile(
                                title: Text("$dateCreated"),
                                leading: Text("${index + 1}"),
                                horizontalTitleGap: 0,
                                visualDensity: VisualDensity.compact,
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    final dir = await getTemporaryDirectory();

                                    showDialog<void>(
                                      useSafeArea: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25)),
                                          insetPadding: const EdgeInsets.all(15),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: 15,
                                                left: 15,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Icon(
                                                    Icons.arrow_back,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    height: deviceHeight * .60,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child:  PhotoView(
                                                      backgroundDecoration:
                                                      const BoxDecoration(
                                                        color: Colors.grey,
                                                      ),
                                                      minScale: PhotoViewComputedScale
                                                          .contained *
                                                          1,
                                                      imageProvider: FileImage(
                                                        File(
                                                            '${dir.path}/$fullPath'),
                                                      ),
                                                    )
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text("$filetype"),
                                ),
                              ),
                              const Divider(color: Colors.black),
                            ],
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
