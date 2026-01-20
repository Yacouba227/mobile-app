import 'package:budgetapp/utils/icons_list.dart';
import 'package:budgetapp/widgets/transaction_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionCards extends StatefulWidget {
  TransactionCards({super.key});

  @override
  State<TransactionCards> createState() => _TransactionCardsState();
}

class _TransactionCardsState extends State<TransactionCards> {
  //final appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // 1. Le titre (fixe)
          Row(
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10), // Petit espace entre titre et liste
          // 2. La liste (scrollable)
          Expanded(
            // <-- Crucial : dit à la liste de prendre tout l'espace restant
            child: RecentTransactionList(),
          ),
        ],
      ),
    );
  }
}

class RecentTransactionList extends StatelessWidget {
  RecentTransactionList({super.key});
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("transactions")
          .orderBy('timestamp', descending: true).limit(20) /* 1:36:18 */
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No transactions found."),
          );
        }
        var data = snapshot.data!.docs;
        return ListView.builder(
          // On retire shrinkWrap et NeverScrollableScrollPhysics
          itemCount: data.length,
          itemBuilder: (context, index) {
            var cardData = data[index];
            return TransactionCard(data: cardData);
          },
        );
      },
    );
  }
}


/* 1:00:18 */
