import 'package:budgetapp/widgets/transactions_list.dart';
import 'package:flutter/material.dart';

class TabVarView extends StatelessWidget {
  TabVarView({super.key, required this.category, required this.monthYear});
  final String category;
  final String monthYear;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'credit'),
                Tab(text: 'debut'),
              ],
            ),
            Expanded(child: TabBarView(children: [
              TransactionsList(category: category, monthYear: monthYear, type: "credit"),
              TransactionsList(category: category, monthYear: monthYear, type: "debit"),
            ]))
          ],
        ),
      ),
    );
  }
}
