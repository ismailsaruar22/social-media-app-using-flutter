import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: Form(
            child: TextFormField(
              style: TextStyle(color: Colors.black),
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a user...',
                hintStyle: TextStyle(color: Colors.black),
                labelStyle: TextStyle(color: secondaryColor),
              ),
              onFieldSubmitted: (String _) {
                setState(() {
                  isShowUsers = true;
                });
                print(_);
              },
            ),
          ),
        ),
        body: isShowUsers
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'bio',
                      isGreaterThanOrEqualTo: searchController.text,
                    )
                    // .where(
                    //   'bio',
                    //   isGreaterThanOrEqualTo: searchController.text,
                    // )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                        backgroundColor: Colors.grey,
                        strokeWidth: 10,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: (snapshot.data! as dynamic).docs[index]
                                  ['uid'],
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            tileColor: Colors.teal,
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                (snapshot.data! as dynamic).docs[index]
                                    ['photoUrl'],
                              ),
                              radius: 16,
                            ),
                            title: Text(
                              (snapshot.data! as dynamic).docs[index]
                                  ['username'],
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              (snapshot.data! as dynamic).docs[index]['bio'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : const Scaffold(
                body: Center(child: Text('')),
              )
        // : FutureBuilder(
        //     future: FirebaseFirestore.instance
        //         .collection('posts')
        //         .orderBy('datePublished')
        //         .get(),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return const Center(
        //           child: CircularProgressIndicator(
        //             color: Colors.green,
        //             backgroundColor: Colors.grey,
        //             strokeWidth: 10,
        //           ),
        //         );
        //       }

        //       return StaggeredGridView.countBuilder(
        //         crossAxisCount: 3,
        //         itemCount: (snapshot.data! as dynamic).docs.length,
        //         itemBuilder: (context, index) => Image.network(
        //           (snapshot.data! as dynamic).docs[index]['postUrl'],
        //           fit: BoxFit.cover,
        //         ),
        //         staggeredTileBuilder: (index) => MediaQuery.of(context)
        //                     .size
        //                     .width >
        //                 webScreenSize
        //             ? StaggeredTile.count(
        //                 (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
        //             : StaggeredTile.count(
        //                 (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
        //         mainAxisSpacing: 8.0,
        //         crossAxisSpacing: 8.0,
        //       );
        //     },
        //   ),
        );
  }
}
