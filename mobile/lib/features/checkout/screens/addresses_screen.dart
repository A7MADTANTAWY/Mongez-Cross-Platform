import 'package:flutter/material.dart';
import 'package:mongez/core/app_colors.dart';
import 'package:mongez/core/constants/endpoints.dart';
import 'package:mongez/features/checkout/data/models/address_model.dart';
import 'package:mongez/features/checkout/widgets/address_card.dart';
import 'package:mongez/features/checkout/screens/add_address_screen.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/services/api_service.dart';
import 'package:mongez/services/services_locator.dart';
import 'package:mongez/widgets/custom_app_bar.dart';
import 'package:mongez/widgets/custom_button.dart';

class SavedAddressPage extends StatefulWidget {
  const SavedAddressPage({super.key});

  @override
  State<SavedAddressPage> createState() => _SavedAddressPageState();
}

class _SavedAddressPageState extends State<SavedAddressPage> {
  List<AddressModel> _addresses = [];
  bool _loading = true;
  String? _error;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = getIt<ApiService>();
      final data = await api.get(endPoint: Endpoints.addresses);
      final list = (data as List<dynamic>)
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _addresses = list;
        _loading = false;
        if (_selectedId == null && list.isNotEmpty) {
          _selectedId = list.firstWhere(
            (a) => a.isDefault,
            orElse: () => list.first,
          ).id;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _deleteAddress(int id) async {
    try {
      await getIt<ApiService>().delete(endPoint: Endpoints.addressById(id));
      _fetchAddresses();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: lang.addressesPageTitle),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Divider(thickness: 1, color: AppColors.gray3),
                  Row(
                    children: [
                      Text(
                        lang.deliveryAddress,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load addresses', style: TextStyle(color: Colors.red[700])),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _fetchAddresses, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _addresses[index];
                final bool isSelected = _selectedId == item.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Stack(
                    children: [
                      SelectableCard(
                        title: item.label.isNotEmpty ? item.label : null,
                        subtitle: item.address,
                        isDefault: item.isDefault,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() { _selectedId = item.id; });
                        },
                      ),
                      if (item.id != null)
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => _deleteAddress(item.id!),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }, childCount: _addresses.length),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  CustomButton(
                    text: lang.addNewAddress,
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressScreen(),
                        ),
                      );
                      if (result == true) _fetchAddresses();
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: lang.apply,
                    onPressed: () {},
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    hasBorder: true,
                    borderColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
