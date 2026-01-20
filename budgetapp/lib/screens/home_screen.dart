import 'package:budgetapp/screens/login_screen.dart';
import 'package:budgetapp/widgets/add_transaction_form.dart';
import 'package:budgetapp/widgets/hero_card.dart';
import 'package:budgetapp/widgets/transaction_cards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isLogoutLoading = false;
  logOut() async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    setState(() {
      isLogoutLoading = false;
    });
  }
final userId = FirebaseAuth.instance.currentUser!.uid;
  _dialoBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Transaction"),
          content: AddTransactionForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: (() {
          _dialoBuilder(context);
        }),
        child: Icon(
          Icons.add,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text("Dev", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () async {
              // Implement logout functionality
              logOut();
            },
            icon: isLogoutLoading
                ? CircularProgressIndicator()
                : Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            HeroCard(userId: userId),
            Expanded(child: TransactionCards()),
          ],
        ),
      ),
    );
  }
}

/* 46:03 */
