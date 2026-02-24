import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/image_helper.dart';

class AdminCategoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImageHelper _imageHelper = ImageHelper();
  
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isEditing = false.obs;
  var selectedCategoryId = "".obs;

  // Add/Edit Category
  final nameController = TextEditingController();
  var uploadedImageBase64 = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    isLoading.value = true;
    try {
      final snapshot = await _db.collection('categories').get();
      categories.value = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final base64Image = await _imageHelper.pickImageAndConvertToBase64();
    if (base64Image != null) {
      uploadedImageBase64.value = base64Image;
    }
  }

  void setCategoryForEdit(Map<String, dynamic> category) {
    isEditing.value = true;
    selectedCategoryId.value = category['id'];
    nameController.text = category['name'];
    uploadedImageBase64.value = category['image'] ?? "";
  }

  void clearFields() {
    isEditing.value = false;
    selectedCategoryId.value = "";
    nameController.clear();
    uploadedImageBase64.value = "";
  }

  Future<void> saveCategory() async {
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Category Name is required");
      return;
    }
    
    isLoading.value = true;
    try {
      final data = {
        'name': nameController.text,
        'image': uploadedImageBase64.value, // Base64 string
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing.value) {
        await _db.collection('categories').doc(selectedCategoryId.value).update(data);
        Get.snackbar("Success", "Category updated successfully");
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['itemCount'] = 0;
        await _db.collection('categories').add(data);
        Get.snackbar("Success", "Category added successfully");
      }
      
      clearFields();
      fetchCategories();
    } catch (e) {
      Get.snackbar("Error", "Failed to save category");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection('categories').doc(id).delete();
      fetchCategories();
      Get.snackbar("Success", "Category deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete category");
    }
  }
}
