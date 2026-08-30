import 'package:flutter/foundation.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/core/network/api_service.dart';
import 'package:mongez/features/client/address/data/models/address_model.dart';

/// Shared source of truth for the user's saved addresses (mainly the
/// default one). Home and Account screens listen to it so the default
/// address updates live whenever it changes from My Addresses.
class AddressRepository extends ChangeNotifier {
  final ApiService apiService;
  AddressRepository(this.apiService);

  List<AddressModel> _addresses = [];
  AddressModel? _defaultAddress;
  bool _loading = false;
  bool _loaded = false;
  DateTime? _lastLoadedAt;
  String? _error;

  /// Refetch at most this often when consumers call load() on every
  /// screen entry; within the window the cached data is served.
  static const _staleAfter = Duration(seconds: 15);

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get defaultAddress => _defaultAddress;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    // Home, Account and worker header all trigger a load on entry —
    // deduplicate concurrent calls, skip the network while data is
    // still fresh, but otherwise ALWAYS refetch so a default-address
    // change made anywhere shows up everywhere.
    if (_loading) return;
    final isFresh = _lastLoadedAt != null &&
        DateTime.now().difference(_lastLoadedAt!) < _staleAfter;
    if (_loaded && isFresh) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await apiService.get(endPoint: Endpoints.addresses);
      final list = (raw as List)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _addresses = list;
      _defaultAddress = list.isNotEmpty
          ? list.firstWhere((a) => a.isDefault, orElse: () => list.first)
          : null;
      _loaded = true;
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void invalidate() {
    _loaded = false;
    load();
  }
}
