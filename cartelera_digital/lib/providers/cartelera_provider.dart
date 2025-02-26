import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cartelera.dart';
import '../services/cartelera_service.dart';

final carteleraProvider = FutureProvider<List<Cartelera>>((ref) async {
  final carteleraService = ref.watch(carteleraServiceProvider);
  return await carteleraService.getCarteleras();
});
