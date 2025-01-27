import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transits').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var transits = snapshot.data!.docs;
          return ListView.builder(
            itemCount: transits.length,
            itemBuilder: (context, index) {
              var transit = transits[index];
              return ListTile(
                title: Text('Status: ${transit['status']}'),
                subtitle: Text(
                  'Current: ${transit['currentLocation']['lat']}, ${transit['currentLocation']['lng']}\n'
                      'Destination: ${transit['destinationLocation']['lat']}, ${transit['destinationLocation']['lng']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
