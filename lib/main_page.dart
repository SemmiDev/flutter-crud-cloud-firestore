import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'item_cart.dart';

class MainPage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
    CollectionReference tasksReference = firestoreInstance.collection("tasks");

    getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
      return snapshot.data!.docs
          .map((doc) => GestureDetector(
                onTap: () {
                  titleController.text = doc["title"];
                  descController.text = doc['description'];
                },
                child: ItemCard(
                  title: doc["title"],
                  description: doc["description"],
                  onUpdate: () => tasksReference.doc(doc.id).update({
                    'title': titleController.text,
                    'description': descController.text,
                  }).then((_) => {
                    titleController.text = '',
                    descController.text = '',
                  }),
                  onDelete: () => tasksReference.doc(doc.id).delete().then((_) => {
                    titleController.text = '',
                    descController.text = '',
                  }),
                ),
              ))
          .toList();
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text('Firestore App'),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              children: [
                StreamBuilder(
                    stream: tasksReference.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return Column(children: getExpenseItems(snapshot));
                      } else {
                        return const Center(child: Text('Loading'));
                      }
                    }),
                const SizedBox(
                  height: 150,
                )
              ],
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(-5, 0),
                        blurRadius: 15,
                        spreadRadius: 3)
                  ]),
                  width: double.infinity,
                  height: 130,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              style: GoogleFonts.poppins(),
                              controller: titleController,
                              decoration:
                                  const InputDecoration(hintText: "Title"),
                            ),
                            TextField(
                              style: GoogleFonts.poppins(),
                              controller: descController,
                              decoration:
                                  const InputDecoration(hintText: "Desription"),
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: 130,
                          width: 130,
                          padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                          child: ElevatedButton(
                            onPressed: () {
                              tasksReference.add({
                                'title': titleController.text,
                                'description': descController.text,
                              });

                              titleController.text = '';
                              descController.text = '';
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.purple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: Text('Add Data',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ))
                    ],
                  ),
                )),
          ],
        ));
  }
}
