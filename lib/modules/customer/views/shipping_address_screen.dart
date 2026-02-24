import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';
import 'package:pvp_traders/data/services/database_service.dart';

class ShippingAddressController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var addresses = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isLocating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    isLoading.value = true;
    try {
      final fetched = await _databaseService.getShippingAddresses(user.uid);
      addresses.assignAll(fetched);
    } catch (e) {
      Get.snackbar("error".tr, "Failed to load addresses");
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String>?> getCurrentLocation() async {
    isLocating.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("info".tr, "Please enable GPS to use this feature.");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("error".tr, "Location permission is required.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("error".tr, "Location permissions are permanently denied.");
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'address': "${place.name}, ${place.street}, ${place.subLocality}",
          'city': place.locality ?? "",
          'state': place.administrativeArea ?? "",
          'zip': place.postalCode ?? "",
        };
      }
    } catch (e) {
      Get.snackbar("error".tr, "Could not fetch live location: $e");
    } finally {
      isLocating.value = false;
    }
    return null;
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // If setting as default, remove default from others
      if (address['isDefault'] == true) {
        for (var addr in addresses) {
          addr['isDefault'] = false;
        }
      }

      await _databaseService.addShippingAddress(user.uid, address);
      addresses.add(address);
      Get.snackbar("success".tr, "Address added successfully");
    } catch (e) {
      Get.snackbar("error".tr, "Failed to add address");
    }
  }

  Future<void> deleteAddress(Map<String, dynamic> address) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _databaseService.deleteShippingAddress(user.uid, address);
      addresses.remove(address);
      Get.snackbar("success".tr, "Address deleted");
    } catch (e) {
      Get.snackbar("error".tr, "Failed to delete address");
    }
  }

  Future<void> setAsDefault(Map<String, dynamic> address) async {
    // Backend implementation would need updateShippingAddress or similar
    // for now we just show a toggle in UI logic
    Get.snackbar("info".tr, "Default address feature is being synced with backend.");
  }
}

class ShippingAddressScreen extends StatelessWidget {
  const ShippingAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingAddressController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("shipping_addresses".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "no_addresses".tr,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final addr = controller.addresses[index];
            final type = addr['type'] ?? 'Home';
            final isDefault = addr['isDefault'] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: isDefault ? Border.all(color: AppColors.primary, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type == 'Home' ? Icons.home_rounded : (type == 'Work' ? Icons.work_rounded : Icons.location_on_rounded),
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr['label'] ?? type,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text("default_tag".tr, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                            Text(
                              type,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () => _confirmDelete(context, controller, addr),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    "${addr['address']}, ${addr['city']}, ${addr['state']} - ${addr['zip']}",
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.5),
                  ),
                  if (addr['phone'] != null && addr['phone'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          addr['phone'],
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(context, controller),
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text("add_new_address".tr, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ShippingAddressController controller, Map<String, dynamic> addr) {
    Get.defaultDialog(
      title: "delete_address".tr,
      middleText: "delete_address_q".tr,
      textConfirm: "delete".tr,
      textCancel: "keep".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteAddress(addr);
        Get.back();
      }
    );
  }

  void _showAddAddressDialog(BuildContext context, ShippingAddressController controller) {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final zipCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final RxString selectedType = "Home".obs;
    final RxBool setAsDefault = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("add_shipping_address".tr, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Live Location Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isLocating.value ? null : () async {
                    final loc = await controller.getCurrentLocation();
                    if (loc != null) {
                      addressCtrl.text = loc['address'] ?? "";
                      cityCtrl.text = loc['city'] ?? "";
                      stateCtrl.text = loc['state'] ?? "";
                      zipCtrl.text = loc['zip'] ?? "";
                    }
                  },
                  icon: controller.isLocating.value 
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    controller.isLocating.value ? "locating".tr.toUpperCase() : "use_current_location".tr.toUpperCase(),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              _buildField(labelCtrl, "address_label_hint".tr, Icons.label_important_outline),
              const SizedBox(height: 16),
               _buildField(addressCtrl, "street_address_hint".tr, Icons.map_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(cityCtrl, "city".tr, Icons.location_city_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(zipCtrl, "zip_code".tr, Icons.pin_drop_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(stateCtrl, "state_province".tr, Icons.explore_outlined),
              const SizedBox(height: 16),
              _buildField(phoneCtrl, "Phone Number", Icons.phone_android_rounded, keyboardType: TextInputType.phone),
              
              const SizedBox(height: 24),
              Text("address_type".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Obx(() => Row(
                children: ["Home", "Work", "Other"].map((type) {
                  bool isSelected = selectedType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(type == "Home" ? "home_tag".tr : (type == "Work" ? "work_tag".tr : "other_tag".tr)),
                      selected: isSelected,
                      onSelected: (val) => selectedType.value = type,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 16),
              Obx(() => CheckboxListTile(
                value: setAsDefault.value,
                onChanged: (val) => setAsDefault.value = val ?? false,
                title: Text("set_as_default".tr, style: GoogleFonts.poppins(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
              )),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (addressCtrl.text.isNotEmpty && cityCtrl.text.isNotEmpty) {
                      controller.addAddress({
                        'label': labelCtrl.text.trim().isEmpty ? selectedType.value : labelCtrl.text.trim(),
                        'address': addressCtrl.text.trim(),
                        'city': cityCtrl.text.trim(),
                        'state': stateCtrl.text.trim(),
                        'zip': zipCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'type': selectedType.value,
                        'isDefault': setAsDefault.value,
                        'createdAt': DateTime.now().toIso8601String(),
                      });
                      Get.back();
                    } else {
                      Get.snackbar("missing_info".tr, "fill_all_fields".tr);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text("save_address".tr, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40), // Keyboard spacing
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}
