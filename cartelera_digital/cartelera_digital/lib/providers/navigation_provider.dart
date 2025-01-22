import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationExpandedProvider = StateProvider<bool>((ref) => true);
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);