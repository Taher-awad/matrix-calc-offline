import 'package:flutter/material.dart';
import 'tabs/system_solver_tab.dart';
import 'tabs/matrix_ops_tab.dart';
import 'tabs/determinant_tab.dart';
import 'tabs/eigen_tab.dart';

import 'tabs/history_tab.dart';
import '../../logic/matrix.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class MatrixEvent {
  final Matrix matrix;
  final DateTime timestamp;
  MatrixEvent(this.matrix) : timestamp = DateTime.now();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<SystemSolverTabState> _systemKey = GlobalKey();
  final GlobalKey<MatrixOpsTabState> _opsKey = GlobalKey();
  final GlobalKey<DeterminantTabState> _detKey = GlobalKey();
  final GlobalKey<EigenTabState> _eigenKey = GlobalKey();

  MatrixEvent? _opsAEvent;
  MatrixEvent? _opsBEvent;
  MatrixEvent? _detEvent;
  MatrixEvent? _eigenEvent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 tabs now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onUseMatrix(Matrix matrix, String target) {
    setState(() {
      switch (target) {
        case "Ops A":
          _opsAEvent = MatrixEvent(matrix);
          _tabController.animateTo(1);
          break;
        case "Ops B":
          _opsBEvent = MatrixEvent(matrix);
          _tabController.animateTo(1);
          break;
        case "Det":
          _detEvent = MatrixEvent(matrix);
          _tabController.animateTo(2);
          break;
        case "Eigen":
          _eigenEvent = MatrixEvent(matrix);
          _tabController.animateTo(3);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'System of Equations'),
            Tab(text: 'Matrix Operations'),
            Tab(text: 'Determinant'),
            Tab(text: 'Eigenvalues'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SystemSolverTab(key: _systemKey),
          MatrixOpsTab(
            key: _opsKey,
            matrixAEvent: _opsAEvent,
            matrixBEvent: _opsBEvent,
          ),
          DeterminantTab(
            key: _detKey,
            matrixEvent: _detEvent,
          ),
          EigenTab(
            key: _eigenKey,
            matrixEvent: _eigenEvent,
          ),
          HistoryTab(onUseMatrix: _onUseMatrix),
        ],
      ),
    );
  }
}
