import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_irrigation_app/data/services/firebase_service.dart';
import 'package:smart_irrigation_app/ui/core/theme.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/view_models/irrigation_view_model.dart';
import 'package:smart_irrigation_app/ui/features/dashboard/views/dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F19),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize service & viewmodel
  final dataService = IrrigationDataService();
  final viewModel = IrrigationViewModel(dataService: dataService);

  runApp(SmartIrrigationApp(viewModel: viewModel));
}

class SmartIrrigationApp extends StatelessWidget {
  final IrrigationViewModel viewModel;

  const SmartIrrigationApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Soil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: DashboardView(viewModel: viewModel),
    );
  }
}
