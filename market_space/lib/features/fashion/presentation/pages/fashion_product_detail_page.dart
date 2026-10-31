import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_network_image.dart';

import '../../data/models/fashion_product_model.dart';
import '../../data/repositories/fashion_repository.dart';
import '../controllers/fashion_cart_controller.dart';
import '../widgets/fashion_product_card.dart';

class FashionProductDetailPage extends StatefulWidget {
  final FashionProductModel product;
  final FashionRepository? repository;
  final FashionCartController? cartController;

  const FashionProductDetailPage({
    super.key,
    required this.product,
    this.repository,
    this.cartController,
  });

  @override
  State<FashionProductDetailPage> createState() => _FashionProductDetailPageState();
}

class _FashionProductDetailPageState extends State<FashionProductDetailPage> {
  late FashionProductModel _product;
  late final FashionRepository _repository;
  late final PageController _imagePageController;
  int _currentImageIndex = 0;

  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  List<FashionProductModel> _similarProducts = [];
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _repository = widget.repository ?? MockFashionRepository();
    _imagePageController = PageController();

    if (_product.availableSizes.isNotEmpty) {
      _selectedSize = _product.availableSizes.first;
    }
    if (_product.availableColors.isNotEmpty) {
      _selectedColor = _product.availableColors.first;
    }

    _loadSimilarProducts();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadSimilarProducts() async {
    final list = await _repository.getSimilarProducts(_product.id);
    if (mounted) {
      setState(() {
        _similarProducts = list;
        _isLoadingSimilar = false;
      });
    }
  }

  void _showSizeChartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.straighten_rounded, color: Colors.blue),
            SizedBox(width: 8),
            Text('دليل المقاسات التقريبي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('المقاس', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('الصدر (سم)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('الخصر (سم)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('S', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('92 - 96', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('76 - 80', textAlign: TextAlign.center)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('M', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('97 - 102', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('81 - 86', textAlign: TextAlign.center)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('L', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('103 - 108', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('87 - 92', textAlign: TextAlign.center)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('XL', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('109 - 114', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('93 - 98', textAlign: TextAlign.center)),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('XXL', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('115 - 120', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(8), child: Text('99 - 104', textAlign: TextAlign.center)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'ملاحظة: القياسات تقريبية وقد تختلف قليلاً بحسب الماركة وقصة التصميم.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد المقاس واللون أولاً')),
      );
      return;
    }

    // Variant-specific stock validation
    final selectedVariant =
        _product.variants.cast<FashionVariantModel?>().firstWhere(
              (v) => v?.size == _selectedSize && v?.colorName == _selectedColor,
              orElse: () => null,
            );

    if (selectedVariant == null || selectedVariant.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('عذراً، هذا المقاس واللون غير متوفرين حالياً في المخزون'),
        ),
      );
      return;
    }

    if (selectedVariant.stockQuantity < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، الكمية المتوفرة من هذا الخيار هي ${selectedVariant.stockQuantity} فقط',
          ),
        ),
      );
      return;
    }

    widget.cartController?.addItem(
      _product,
      _selectedSize!,
      _selectedColor!,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade800,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تمت إضافة $_quantity قطعة من ${_product.name} إلى حقيبة التسوق',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: Colors.amber,
          onPressed: () {
            Navigator.of(context).pushNamed('/fashion/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _product.brand,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _product.isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              final newFav = await _repository.toggleFavorite(_product.id);
              setState(() {
                _product = _product.copyWith(isFavorite: newFav);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط المنتج للمشاركة')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 380,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: _product.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return AppNetworkImage(
                        imageUrl: _product.images[index],
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.checkroom,
                      );
                    },
                  ),
                  // Page Indicators
                  if (_product.images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _product.images.length,
                          (idx) => Container(
                            width: _currentImageIndex == idx ? 20 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _currentImageIndex == idx ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Badges
                  PositionedDirectional(
                    top: 16,
                    start: 16,
                    child: Row(
                      children: [
                        if (_product.hasDiscount)
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsetsDirectional.only(end: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'خصم %${_product.discountPercentage}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _product.department.titleAr,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Rating
                  Row(
                    children: [
                      Text(
                        _product.brand.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_product.reviewsCount} تقييم)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    _product.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _product.nameEn,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_product.price.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (_product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${_product.oldPrice!.toStringAsFixed(0)} ج.م',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'وفر ${(_product.oldPrice! - _product.price).toStringAsFixed(0)} ج.م',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Size Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اختر المقاس:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _showSizeChartDialog,
                        icon: const Icon(Icons.straighten_rounded, size: 16),
                        label: const Text('دليل المقاسات', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _product.availableSizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSize = size);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Color Selection
                  const Text(
                    'اختر اللون:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: _product.variants.map((v) {
                      final isSelected = _selectedColor == v.colorName;
                      return InkWell(
                        onTap: () => setState(() => _selectedColor = v.colorName),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(v.colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                v.colorName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Specs Card (Material, Season, Instructions)
                  Container(
                    padding: const EdgeInsetsDirectional.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow(Icons.texture_rounded, 'الخامة والقماش', _product.material),
                        const Divider(height: 16),
                        _buildSpecRow(Icons.sunny_snowing, 'الموسم المناسب', _product.season),
                        const Divider(height: 16),
                        _buildSpecRow(Icons.local_laundry_service_outlined, 'تعليمات العناية والغسيل', _product.washingInstructions),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'تفاصيل المنتج:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Assurance Banner
                  Container(
                    padding: const EdgeInsetsDirectional.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.blue.shade800, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تسوق بأمان مع ماركت سبيس',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'إمكانية الاسترجاع أو الاستبدال مجاناً خلال 14 يوماً مع المعاينة عند الاستلام.',
                                style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Similar Products
                  if (_isLoadingSimilar)
                    const Center(child: CircularProgressIndicator())
                  else if (_similarProducts.isNotEmpty) ...[
                    const Text(
                      'منتجات مشابهة قد تعجبك:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarProducts.length,
                        separatorBuilder: (context, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = _similarProducts[index];
                          return SizedBox(
                            width: 170,
                            child: FashionProductCard(
                              product: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FashionProductDetailPage(
                                      product: item,
                                      repository: _repository,
                                      cartController: widget.cartController,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Counter
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add To Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    'أضف للسلة • ${(_product.price * _quantity).toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
