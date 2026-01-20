import 'package:budgetapp/widgets/category_list.dart';
import 'package:budgetapp/widgets/tab_var_view.dart';
import 'package:budgetapp/widgets/time_line_month.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  TransactionScreen({
    super.key,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  var category = "All";
  var monthYear = "";
  @override
    void initState() {
      super.initState();
      DateTime now = DateTime.now();
      setState(() {
        monthYear = DateFormat('MM-yyyy').format(now); // Changement ici : 'MMM y' -> 'MM-yyyy'
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expansive")),
      body: Column(
        children: [
          TimeLineMonth(onChanged: (String? value) {
            if (value != null) {
              setState(() {
                monthYear = value;
              });
            }
          }),
          CategoryList(
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  category = value;
                });
              }
            },
          ),
          TabVarView(category: category, monthYear: monthYear),
        ],
      ),
    );
  }
}
