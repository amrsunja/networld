import 'dart:convert';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../domain/shop_product_ids.dart';

/// Calls Edge Function `verify-iap` after a native purchase completes.
class ShopIapRepository {
  static const _fn = 'verify-iap';

  Future<bool> verifyPurchase(
    PurchaseDetails purchase, {
    required bool isSubscription,
  }) async {
    final receiptData = await _buildReceiptPayload(purchase);
    final platform = Platform.isIOS ? 'ios' : 'android';
    final kind = isSubscription ? 'subscription' : 'consumable';

    try {
      final res = await supabase.functions.invoke(
        _fn,
        body: <String, dynamic>{
          'platform': platform,
          'kind': kind,
          'product_id': purchase.productID,
          'transaction_id': purchase.purchaseID ?? '',
          'receipt_data': receiptData,
        },
      );

      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data['success'] == true;
      }
      return false;
    } on FunctionException catch (e) {
      // Non-2xx responses (e.g. 400 receipt_validation_failed) land here.
      final details = e.details;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        return m['success'] == true;
      }
      return false;
    }
  }

  Future<String> _buildReceiptPayload(PurchaseDetails purchase) async {
    if (Platform.isIOS) {
      // Legacy Apple `verifyReceipt` expects the PKCS#7 app receipt (base64 from the bundle).
      // StoreKit 2 often puts a JWS in `serverVerificationData`, which Apple rejects (~21002).
      var receipt = await SKReceiptManager.retrieveReceiptData();
      if (receipt.isEmpty) {
        final addition = InAppPurchase.instance
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        final refreshed = await addition.refreshPurchaseVerificationData();
        receipt = refreshed?.serverVerificationData ?? '';
      }
      if (receipt.isNotEmpty) {
        return receipt;
      }
      return purchase.verificationData.serverVerificationData;
    }
    final info = await PackageInfo.fromPlatform();
    return jsonEncode({
      'packageName': info.packageName,
      'purchaseToken': purchase.verificationData.serverVerificationData,
    });
  }

  bool productIsSubscription(String productId) =>
    ShopProductIds.isSubscription(productId);
}
