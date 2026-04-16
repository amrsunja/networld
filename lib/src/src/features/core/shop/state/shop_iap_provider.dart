import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:brokies/src/src/features/core/profile/ui/state_management/profile_provider.dart';

import '../data/shop_iap_repository.dart';
import '../domain/shop_product_ids.dart';

final shopIapRepositoryProvider = Provider<ShopIapRepository>(
  (ref) => ShopIapRepository(),
);

final shopIapProvider = NotifierProvider<ShopIapNotifier, ShopIapState>(
  ShopIapNotifier.new,
);

class ShopIapState {
  const ShopIapState({
    this.productsById = const {},
    this.storeAvailable = false,
    this.productsLoading = true,
    this.purchasingProductIds = const {},
    this.lastError,
  });

  final Map<String, ProductDetails> productsById;
  final bool storeAvailable;
  final bool productsLoading;
  final Set<String> purchasingProductIds;
  final String? lastError;

  ProductDetails? product(String id) => productsById[id];

  ShopIapState copyWith({
    Map<String, ProductDetails>? productsById,
    bool? storeAvailable,
    bool? productsLoading,
    Set<String>? purchasingProductIds,
    String? lastError,
    bool clearError = false,
  }) {
    return ShopIapState(
      productsById: productsById ?? this.productsById,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      productsLoading: productsLoading ?? this.productsLoading,
      purchasingProductIds: purchasingProductIds ?? this.purchasingProductIds,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class ShopIapNotifier extends Notifier<ShopIapState> {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Set<String> _handledTransactions = {};

  ShopIapRepository get _repo => ref.read(shopIapRepositoryProvider);

  @override
  ShopIapState build() {
    ref.onDispose(() async {
      await _purchaseSub?.cancel();
    });
    Future.microtask(_bootstrap);
    return const ShopIapState();
  }

  Future<void> _bootstrap() async {
    final available = await InAppPurchase.instance.isAvailable();
    state = state.copyWith(storeAvailable: available, productsLoading: true);
    if (!available) {
      state = state.copyWith(productsLoading: false, lastError: 'store_unavailable');
      return;
    }

    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        state = state.copyWith(lastError: e.toString());
      },
    );

    await _queryProducts();
  }

  Future<void> _queryProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(
      ShopProductIds.all,
    );
    if (response.error != null) {
      state = state.copyWith(
        productsLoading: false,
        lastError: response.error!.message,
      );
      return;
    }
    final map = <String, ProductDetails>{
      for (final p in response.productDetails) p.id: p,
    };
    state = state.copyWith(
      productsById: map,
      productsLoading: false,
      clearError: true,
    );
  }

  Future<void> refreshProducts() => _queryProducts();

  Future<void> buy(String productId) async {
    final pd = state.productsById[productId];
    if (pd == null) {
      state = state.copyWith(lastError: 'product_not_loaded');
      return;
    }

    final subscription = ShopProductIds.isSubscription(productId);
    state = state.copyWith(
      purchasingProductIds: {...state.purchasingProductIds, productId},
      clearError: true,
    );

    final param = PurchaseParam(productDetails: pd);
    try {
      if (subscription) {
        await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      } else {
        await InAppPurchase.instance.buyConsumable(purchaseParam: param);
      }
    } catch (e) {
      state = state.copyWith(
        purchasingProductIds: {...state.purchasingProductIds}..remove(productId),
        lastError: e.toString(),
      );
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(clearError: true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          lastError: purchase.error?.message ?? 'purchase_error',
          purchasingProductIds: {...state.purchasingProductIds}
            ..remove(purchase.productID),
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(
          purchasingProductIds: {...state.purchasingProductIds}
            ..remove(purchase.productID),
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final txKey = '${purchase.productID}_${purchase.purchaseID ?? ""}';
        if (_handledTransactions.contains(txKey)) {
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          continue;
        }

        final isSub = _repo.productIsSubscription(purchase.productID);
        final ok = await _repo.verifyPurchase(purchase, isSubscription: isSub);

        if (ok) {
          _handledTransactions.add(txKey);
          await ref.read(profileProvider.notifier).loadProfile();
        } else {
          state = state.copyWith(lastError: 'server_verify_failed');
        }

        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }

        state = state.copyWith(
          purchasingProductIds: {...state.purchasingProductIds}
            ..remove(purchase.productID),
        );
      }
    }
  }
}
