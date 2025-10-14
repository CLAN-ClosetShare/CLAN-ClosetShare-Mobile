import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClosetShare'),
        automaticallyImplyLeading: false, // Ẩn nút back
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Có thể navigate tới settings page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Chào mừng đến với Flutter App!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đây là template cơ bản với cấu trúc clean architecture',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Counter: $_counter',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          text: 'Tăng',
                          onPressed: _incrementCounter,
                        ),
                        CustomButton(
                          text: 'Reset',
                          onPressed: () {
                            setState(() {
                              _counter = 0;
                            });
                          },
                          isOutlined: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features có sẵn:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• State Management (BLoC/Cubit)'),
                    const Text('• HTTP Client (Dio)'),
                    const Text('• Local Storage (SharedPreferences & Hive)'),
                    const Text('• Dependency Injection (GetIt)'),
                    const Text('• Custom Widgets'),
                    const Text('• Theme Management'),
                    const Text('• Clean Architecture'),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Test API Call',
                      onPressed: () {
                        _showApiTestDialog(context);
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApiTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test API'),
        content: const Text(
          'Chức năng test API sẽ được implement khi bạn thêm endpoint thực tế. '
          'Hiện tại project đã setup sẵn Dio client và API client.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
