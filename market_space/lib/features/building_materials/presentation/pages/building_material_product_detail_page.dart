import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/material_product_model.dart';
import '../../data/models/unit_of_measurement.dart';
import '../../data/repositories/building_materials_repository.dart';

class BuildingMaterialProductDetailPage extends StatefulWidget {
  final String productId;
  final BuildingMaterialsRepository? repository;

  const BuildingMaterialProductDetailPage({
    super.key,
    required this.productId,
    this.repository,
  });

  @override
  State<BuildingMaterialProductDetailPage> createState() =>
      _BuildingMaterialProductDetailPageState();
}

class _BuildingMaterialProductDetailPageState
    extends State<BuildingMaterialProductDetailPage> {
  late final BuildingMaterialsRepository _repository;
  bool _isLoading = true;
  String? _errorMessage;
  MaterialProductModel? _product;
  List<MaterialProductModel> _similarProducts = [];

  late MaterialUnit _selectedUnit;
  double _selectedQuantity = 1.0;
  String? _quantityValidationError;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const BuildingMaterialsRepositoryImpl();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final product = await _repository.getMaterialProductById(widget.productId);
      if (product == null) {
        setState(() {
          _errorMessage = 'المنتج غير موجود.';
          _isLoading = false;
        });
        return;
      }
      final similar = await _repository.getMaterialProducts(
        categoryId: product.categoryId,
      );

      setState(() {
        _product = product;
        _selectedUnit = product.baseUnit;
        _selectedQuantity = product.minOrderQuantity;
        _similarProducts =
            similar.where((p) => p.id != product.id).take(4).toList();
        _isLoading = false;
      });
      _validateQuantity();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onUnitChanged(MaterialUnit? newUnit) {
    if (newUnit == null || _product == null) return;
    setState(() {
      _selectedUnit = newUnit;
      // إعادة ضبط الكمية لتلائم الوحدة المختارة بما يوافق الحد الأدنى
      final minInSelected = UnitConverter.convertQuantity(
        quantity: _product!.minOrderQuantity,
        from: _product!.baseUnit,
        to: newUnit,
      );
      _selectedQuantity = minInSelected;
    });
    _validateQuantity();
  }

  void _validateQuantity() {
    if (_product == null) return;
    final qtyInBase = UnitConverter.convertQuantity(
      quantity: _selectedQuantity,
      from: _selectedUnit,
      to: _product!.baseUnit,
    );

    if (qtyInBase < _product!.minOrderQuantity) {
      _quantityValidationError =
          'الحد الأدنى للطلب هو ${_product!.formattedMinOrder}';
    } else if (qtyInBase > _product!.stockQuantity) {
      _quantityValidationError =
          'الكمية تتجاوز المخزون المتاح (${_product!.stockQuantity} ${_product!.baseUnit.label})';
    } else {
      _quantityValidationError = null;
    }
  }

  void _incrementQuantity() {
    setState(() {
      _selectedQuantity += 1.0;
      _validateQuantity();
    });
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1.0) {
      setState(() {
        _selectedQuantity -= 1.0;
        _validateQuantity();
      });
    }
  }

  double get _currentUnitPrice {
    if (_product == null) return 0.0;
    return UnitConverter.convertUnitPrice(
      priceInFromUnit: _product!.unitPrice,
      from: _product!.baseUnit,
      to: _selectedUnit,
    );
  }

  double get _totalPrice {
    if (_product == null) return 0.0;
    return UnitConverter.roundCurrency(_selectedQuantity * _currentUnitPrice);
  }

  void _handleAddToCart() async {
    if (_product == null || _quantityValidationError != null) return;
    final dependencies = AppDependencies.maybeOf(context);
    if (dependencies == null) return;

    final success = await dependencies.buildingMaterialsCartController.addToCart(
      product: _product!,
      quantity: _selectedQuantity,
      unit: _selectedUnit,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة $_selectedQuantity ${_selectedUnit.label} من ${_product!.name} إلى السلة'),
          backgroundColor: AppColors.emerald700,
          action: SnackBarAction(
            label: 'عرض السلة',
            textColor: Colors.white,
            onPressed: () => context.push(RouteNames.buildingMaterialsCart),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dependencies.buildingMaterialsCartController.errorMessage ??
                'تعذر إضافة المنتج إلى السلة',
          ),
          backgroundColor: AppColors.rose600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            _product?.brand ?? 'تفاصيل المنتج',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push(RouteNames.buildingMaterialsCart),
            ),
          ],
        ),
        bottomNavigationBar: _product != null ? _buildBottomBar() : null,
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final product = _product!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          AppNetworkImage(
            imageUrl: product.primaryImageUrl,
            aspectRatio: 16 / 9,
            borderRadius: AppRadii.lg,
            fit: BoxFit.cover,
            fallbackIcon: Icons.broken_image_rounded,
          ),
          const SizedBox(height: AppSpacing.md),

          // التصنيف والماركة والتحقق
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: AppRadii.sm,
                ),
                child: Text(
                  product.categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: AppRadii.sm,
                  border: Border.all(color: AppColors.emerald200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.emerald600),
                    SizedBox(width: 4),
                    Text(
                      'منتج معتمد',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '${product.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    ' (${product.reviewsCount})',
                    style: TextStyle(color: AppColors.slate500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // اسم المنتج
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // السعر
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${product.unitPrice.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emerald700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${product.baseUnit.label}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // بطاقة المورد
          _buildSupplierCard(product),
          const SizedBox(height: AppSpacing.md),

          // بطاقة محدد الوحدات والكميات
          _buildMeasurementSelectorCard(product),
          const SizedBox(height: AppSpacing.md),

          // المواصفات الفنية
          _buildTechnicalSpecsCard(product),
          const SizedBox(height: AppSpacing.md),

          // الوصف
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.md,
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الوصف والاستخدامات الإنشائية',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 13, color: AppColors.slate700, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // زر طلب تسعير للمشاريع الكبيرة
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: AppRadii.lg,
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.request_quote_rounded, color: Color(0xFF1D4ED8), size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'هل تحتاج كميات ضخمة لمشروعك؟',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'اطلب عرض سعر تنافسي (RFQ) من كبرى المصانع والموردين مباشرة.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    context.push(RouteNames.buildingMaterialsRfq);
                  },
                  child: const Text('طلب تسعير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // منتجات مشابهة
          if (_similarProducts.isNotEmpty) ...[
            const Text(
              'منتجات وبدائل مشابهة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate900),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _similarProducts.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final sim = _similarProducts[index];
                  return _buildSimilarProductCard(sim);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplierCard(MaterialProductModel product) {
    final supplier = product.supplier;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.slate700, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                    ),
                    Text(
                      '${supplier.companyType} • ${supplier.city}',
                      style: TextStyle(fontSize: 11, color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: AppRadii.sm,
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${supplier.rating}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoSnippet(Icons.local_shipping_outlined, 'مدة التوصيل', '${product.estimatedDeliveryDays} يوم'),
              _buildInfoSnippet(Icons.pin_drop_outlined, 'مكان التوريد', product.supplyOrigin),
              _buildInfoSnippet(Icons.scale_outlined, 'الحد الأدنى', product.formattedMinOrder),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSnippet(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.slate500),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.slate500)),
            Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementSelectorCard(MaterialProductModel product) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'اختر وحدة القياس والكمية',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900),
              ),
              Text(
                'المخزون: ${product.stockQuantity} ${product.baseUnit.label}',
                style: TextStyle(fontSize: 11, color: AppColors.slate500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // أزرار الوحدات المتاحة
          Wrap(
            spacing: 8,
            children: product.supportedUnits.map((u) {
              final isSelected = u == _selectedUnit;
              return ChoiceChip(
                label: Text(u.label),
                selected: isSelected,
                selectedColor: AppColors.emerald100,
                backgroundColor: AppColors.slate100,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.emerald800 : AppColors.slate800,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.emerald600 : Colors.transparent,
                ),
                onSelected: (_) => _onUnitChanged(u),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // عداد الكمية
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.slate300),
                  borderRadius: AppRadii.md,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _decrementQuantity,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _selectedQuantity.toStringAsFixed(
                          _selectedQuantity.truncateToDouble() == _selectedQuantity ? 0 : 2,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سعر الوحدة: ${_currentUnitPrice.toStringAsFixed(0)} ج.م / ${_selectedUnit.label}',
                      style: TextStyle(fontSize: 12, color: AppColors.slate600),
                    ),
                    Text(
                      'الإجمالي: ${_totalPrice.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_quantityValidationError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: AppRadii.sm,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _quantityValidationError!,
                      style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecsCard(MaterialProductModel product) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المواصفات الفنية المعتمدة',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...product.technicalSpecs.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: TextStyle(fontSize: 12, color: AppColors.slate600)),
                  Text(
                    entry.value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate900),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimilarProductCard(MaterialProductModel product) {
    return InkWell(
      onTap: () {
        context.push(
          '${RouteNames.buildingMaterialsProductDetail}?productId=${product.id}',
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.md,
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: product.primaryImageUrl,
              height: 100,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.mdValue)),
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isAddToCartDisabled = _quantityValidationError != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجمالي التوريد', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                Text(
                  '${_totalPrice.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.slate300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.md,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: const Text(
                  'إضافة للسلة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: isAddToCartDisabled ? null : _handleAddToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
