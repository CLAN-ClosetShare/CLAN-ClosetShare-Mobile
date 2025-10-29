import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/closet_bloc.dart';
import '../bloc/closet_item_bloc.dart';
import 'closet_list_page.dart';

class ClosetMainPage extends StatelessWidget {
  const ClosetMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<ClosetBloc>()),
        BlocProvider(create: (context) => di.sl<ClosetItemBloc>()),
      ],
      child: const ClosetListPage(),
    );
  }
}
