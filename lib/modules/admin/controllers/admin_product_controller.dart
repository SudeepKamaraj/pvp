import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pvp_traders/core/utils/image_helper.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../customer/controllers/home_controller.dart';

class AdminProductController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  HomeController get _homeController {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    return Get.find<HomeController>();
  }
  final ImageHelper _imageHelper = ImageHelper();

  List<ProductModel> get products => _homeController.trendingProducts;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final buyingPriceController = TextEditingController(); // Cost price
  final imageUrlController = TextEditingController();
  final offerPriceController = TextEditingController();
  final stockController = TextEditingController();
  final categoryController = TextEditingController();

  var isLoading = false.obs;
  var isEditing = false.obs;
  var isImagePicking = false.obs;
  var isVideoPicking = false.obs;
  var selectedProductId = "".obs;
  var selectedCategory = "Men".obs;
  var selectedSizes = <String>[].obs;
  var selectedColors = <String>[].obs;
  var uploadedImages = <String>[].obs;
  var uploadedVideos = <String>[].obs;

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
  }

  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }

  Future<void> pickImages() async {
    if (isImagePicking.value) return;
    isImagePicking.value = true;
    try {
      final List<String> base64Images = await _imageHelper.pickMultiImageAndConvertToBase64();
      if (base64Images.isNotEmpty) {
        uploadedImages.addAll(base64Images);
      }
    } finally {
      isImagePicking.value = false;
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages.removeAt(index);
    }
  }

  Future<void> pickVideos() async {
    if (isVideoPicking.value) return;
    isVideoPicking.value = true;
    try {
      final videoFile = await _imageHelper.pickVideo();
      if (videoFile != null) {
        // Show loading indicator
        Get.snackbar(
          "Uploading",
          "Uploading video to Firebase Storage...",
          showProgressIndicator: true,
          duration: const Duration(seconds: 60),
          isDismissible: false,
        );
        
        // Upload to Firebase Storage
        final videoUrl = await _storageService.uploadVideo(videoFile, 'products/videos');
        
        Get.back(); // Close the snackbar
        
        if (videoUrl != null) {
          uploadedVideos.add(videoUrl);
          Get.snackbar(
            "Success", 
            "Video uploaded successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.primaryColor,
            colorText: Get.theme.colorScheme.onPrimary,
          );
        } else {
          Get.snackbar(
            "Upload Failed", 
            "Could not upload video. Please ensure Firebase Storage is enabled in your Firebase Console.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      Get.back(); // Close loading snackbar if still showing
      Get.snackbar(
        "Error", 
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isVideoPicking.value = false;
    }
  }

  void removeVideo(int index) async {
    if (index >= 0 && index < uploadedVideos.length) {
      final videoUrl = uploadedVideos[index];
      
      // If it's a Firebase Storage URL, delete it
      if (videoUrl.contains('firebase')) {
        await _storageService.deleteFileByUrl(videoUrl);
      }
      
      uploadedVideos.removeAt(index);
    }
  }

  void setProductForEdit(ProductModel product) {
    isEditing.value = true;
    selectedProductId.value = product.id;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    buyingPriceController.text = product.buyingPrice?.toString() ?? "";
    selectedCategory.value = product.category;
    imageUrlController.text = product.imageUrl;
    offerPriceController.text = product.offerPrice?.toString() ?? "";
    stockController.text = product.stockQuantity.toString();
    selectedSizes.value = List<String>.from(product.sizes);
    selectedColors.value = List<String>.from(product.colors);
    uploadedImages.value = product.images.where((img) => img.startsWith('data:image')).toList();
    if (uploadedImages.isEmpty && product.imageUrl.isNotEmpty) {
        uploadedImages.add(product.imageUrl);
    }
    // Also include network images if stored in 'images'
    if (product.images.isNotEmpty) {
         for(var img in product.images) {
            if (!uploadedImages.contains(img)) {
                uploadedImages.add(img);
            }
         }
    }
    // Load videos
    uploadedVideos.value = product.videos.toList();
  }

  Future<void> saveProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar("Error", "Name and Price are required");
      return;
    }

    // Warn if buying price is not set
    if (buyingPriceController.text.isEmpty) {
      final shouldContinue = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Missing Buying Price"),
          content: const Text("You haven't set a buying price for this product. This means profit analysis won't include this product.\n\nDo you want to continue without setting a buying price?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("CONTINUE ANYWAY"),
            ),
          ],
        ),
      ) ?? false;
      
      if (!shouldContinue) return;
    }

    isLoading.value = true;
    try {
      print("DEBUG: Saving product with buying price: ${buyingPriceController.text}");
      
      final product = ProductModel(
        id: isEditing.value ? selectedProductId.value : '', // Empty ID for new, will be ignored by addProduct?
        name: nameController.text,
        category: selectedCategory.value,
        price: double.tryParse(priceController.text) ?? 0.0,
        buyingPrice: double.tryParse(buyingPriceController.text),
        imageUrl: uploadedImages.isNotEmpty ? uploadedImages.first : imageUrlController.text,
        rating: 0.0,
        offerPrice: double.tryParse(offerPriceController.text),
        stockQuantity: int.tryParse(stockController.text) ?? 0,
        sizes: selectedSizes.toList(),
        colors: selectedColors.toList(),
        images: uploadedImages.toList(),
        videos: uploadedVideos.toList(),
      );
      
      print("DEBUG: Product model created with buyingPrice: ${product.buyingPrice}");
      print("DEBUG: Product toFirestore: ${product.toFirestore()}");

      if (isEditing.value) {
        await _databaseService.updateProduct(product);
        Get.snackbar("Success", "Product updated successfully");
      } else {
        await _databaseService.addProduct(product);
        Get.snackbar("Success", "Product added successfully");
      }

      await _homeController.fetchProducts();
      Get.back();
      clearControllers();
    } catch (e) {
      Get.snackbar("Error", "Failed to save product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _databaseService.deleteProduct(productId);
      await _homeController.fetchProducts();
      Get.snackbar("Success", "Product deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete product: $e");
    }
  }

  void clearControllers() {
    isEditing.value = false;
    selectedProductId.value = "";
    nameController.clear();
    priceController.clear();
    buyingPriceController.clear();
    imageUrlController.clear();
    offerPriceController.clear();
    stockController.clear();
    selectedSizes.clear();
    selectedColors.clear();
    uploadedImages.clear();
    uploadedVideos.clear();
    selectedCategory.value = "Men";
  }
}
