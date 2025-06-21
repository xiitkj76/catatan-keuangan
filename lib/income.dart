import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:apk_catatan_keuangan/models/transaction.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _amountController.text = _sliderValue.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      try {
        // Clean the amount input
        String amountText = _amountController.text
            .replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ) // Remove non-numeric characters except dot
            .replaceAll(',', '.'); // Replace comma with dot if any

        // Parse to double
        double amount = double.parse(amountText);

        final transactionsProvider = Provider.of<TransactionsProvider>(
          context,
          listen: false,
        );

        transactionsProvider.addTransaction(
          Transaction(
            id: DateTime.now().toString(),
            title: _descriptionController.text.trim(),
            amount: amount,
            date: _selectedDate!,
            isIncome: true,
            isDeleted: false,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            behavior: SnackBarBehavior.floating, // Penting untuk margin bekerja
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12), // Jarak antara icon dan teks
                Expanded(
                  child: Text(
                    'Income saved successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor:
                  Colors.white, // opsional: biar warna teks action kontras
            ),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            behavior: SnackBarBehavior.floating, // Penting untuk margin bekerja
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12), // Jarak antara icon dan teks
                Expanded(
                  child: Text(
                    'Error: Invalid number format. Please enter the correct number',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor:
                  Colors.white, // opsional: biar warna teks action kontras
            ),
          ),
        
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedDate = DateTime.now();
    });
    _descriptionController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Income",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Field
                  const Text(
                    "Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: _inputDecoration(
                      hintText: 'Masukkan jumlah pengeluaran',
                      prefixText: 'Rp ',
                    ),
                    onChanged: (value) {
                      final cleanedValue = value.replaceAll(',', '.');
                      final parsed = double.tryParse(cleanedValue);
                      if (parsed != null) {
                        setState(() {
                          _sliderValue = parsed.clamp(0, 10000000000);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan jumlah';
                      }
                      final cleanedValue = value.replaceAll(',', '.');
                      if (double.tryParse(cleanedValue) == null) {
                        return 'Format angka tidak valid';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    width: 1000,
                    child: Slider(
                      activeColor: Color(0xFF100D40),
                      value: _sliderValue,
                      min: 0,
                      max: 10000000,
                      divisions: 1000,
                      label: 'Rp ${_sliderValue.toStringAsFixed(0)}',
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          _amountController.text = value.toStringAsFixed(0);
                        });
                      },
                    ),
                  ),
                  const SizedBox(),

                  // Date Field
                  const Text(
                    "Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hintText: 'Pilih tanggal',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                          ),
                        ),
                        controller: TextEditingController(
                          text:
                              _selectedDate != null
                                  ? DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(_selectedDate!)
                                  : '',
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Harap pilih tanggal';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Description Field
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration(
                      hintText: 'Masukkan keterangan pengeluaran',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan keterangan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF100D40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }
}
