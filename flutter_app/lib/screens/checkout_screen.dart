import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../state/cart_provider.dart';
import '../widgets/page_container.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _api = ApiService();

  String _fulfillment = 'delivery';
  String _payment = 'cod';
  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();

    setState(() => _submitting = true);
    try {
      final result = await _api.placeOrder(
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        fulfillment: _fulfillment,
        deliveryAddress: _fulfillment == 'delivery' ? _addressController.text : null,
        paymentMethod: _payment,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        items: cart.lines
            .map((l) => {'productId': l.product.id, 'quantity': l.quantity})
            .toList(),
      );
      cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed! ID: ${result['orderId']}')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        child: PageContainer(
          maxWidth: 800,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact number'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                const Text('How would you like your order?', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Delivery'),
                      selected: _fulfillment == 'delivery',
                      onSelected: (_) => setState(() => _fulfillment = 'delivery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Market pickup'),
                      selected: _fulfillment == 'pickup',
                      onSelected: (_) => setState(() => _fulfillment = 'pickup'),
                    ),
                  ),
                ]),
                if (_fulfillment == 'delivery') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Delivery address'),
                    validator: (v) => (_fulfillment == 'delivery' && (v == null || v.isEmpty)) ? 'Required' : null,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Special instructions'),
                ),
                const SizedBox(height: 20),
                const Text('Payment method', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    ['cod', 'Cash on Delivery'],
                    ['cash_pickup', 'Cash on Pickup'],
                    ['gcash', 'GCash'],
                    ['digital', 'Other digital payment'],
                  ].map((entry) => _PaymentChip(value: entry[0], label: entry[1])).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Place Order'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatefulWidget {
  final String value;
  final String label;
  const _PaymentChip({required this.value, required this.label});

  @override
  State<_PaymentChip> createState() => _PaymentChipState();
}

class _PaymentChipState extends State<_PaymentChip> {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_CheckoutScreenState>()!;
    return ChoiceChip(
      label: Text(widget.label),
      selected: state._payment == widget.value,
      onSelected: (_) => state.setState(() => state._payment = widget.value),
    );
  }
}
