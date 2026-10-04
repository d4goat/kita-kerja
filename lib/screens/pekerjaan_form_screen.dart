import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:toastification/toastification.dart';

class PekerjaanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? taskToEdit;

  const PekerjaanFormScreen({super.key, this.taskToEdit});

  @override
  State<PekerjaanFormScreen> createState() => _PekerjaanFormScreenState();
}

class _PekerjaanFormScreenState extends State<PekerjaanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MySQLHelper _dbHelper = MySQLHelper();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedHoursController;
  late TextEditingController _actualHoursController;
  late TextEditingController _startDateController;
  late TextEditingController _deadlineController;

  int? _selectedCategoryId;
  int? _selectedAssignedTo;
  String _priority = 'medium';
  String _status = 'not_started';

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _employees = [];

  bool _isLoadingDropdowns = true;
  bool _isSaving = false;

  bool get isEdit => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.taskToEdit;

    _titleController = TextEditingController(
      text: isEdit ? item!['title'].toString() : '',
    );
    _descriptionController = TextEditingController(
      text: isEdit ? (item!['description'] ?? '').toString() : '',
    );
    _estimatedHoursController = TextEditingController(
      text: isEdit
          ? (item!['estimated_hours'] != null
                ? item['estimated_hours'].toString()
                : '8.0')
          : '8.0',
    );
    _actualHoursController = TextEditingController(
      text: isEdit
          ? (item!['actual_hours'] != null
                ? item['actual_hours'].toString()
                : '0.0')
          : '0.0',
    );

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final next3Days = now.add(const Duration(days: 3));
    final defaultDeadlineStr =
        '${next3Days.year}-${next3Days.month.toString().padLeft(2, '0')}-${next3Days.day.toString().padLeft(2, '0')}';

    _startDateController = TextEditingController(
      text: isEdit ? (item!['start_date'] ?? todayStr).toString() : todayStr,
    );
    _deadlineController = TextEditingController(
      text: isEdit ? item!['deadline'].toString() : defaultDeadlineStr,
    );

    if (isEdit) {
      _selectedCategoryId = item!['category_id'] as int?;
      _selectedAssignedTo = item['assigned_to'] as int?;
      _priority = (item['priority'] ?? 'medium').toString();
      _status = (item['status'] ?? 'not_started').toString();
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final categories = await _dbHelper.getJobCategories();
    final employeesRes = await _dbHelper.getEmployees(
      status: 'active',
      pageSize: 100,
    );
    final employeesList = List<Map<String, dynamic>>.from(
      employeesRes['data'] ?? [],
    );

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _employees = employeesList;

      if (!isEdit) {
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first['id'] as int;
        }
        if (_employees.isNotEmpty) {
          _selectedAssignedTo = _employees.first['id'] as int;
        }
      } else {
        // Handle case where category_id or assigned_to was not explicitly passed
        if (_selectedCategoryId == null && _categories.isNotEmpty) {
          final found = _categories.firstWhere(
            (c) => c['name'] == widget.taskToEdit?['category_name'],
            orElse: () => _categories.first,
          );
          _selectedCategoryId = found['id'] as int;
        }
        if (_selectedAssignedTo == null && _employees.isNotEmpty) {
          final found = _employees.firstWhere(
            (e) => e['full_name'] == widget.taskToEdit?['assigned_to_name'],
            orElse: () => _employees.first,
          );
          _selectedAssignedTo = found['id'] as int;
        }
      }
      _isLoadingDropdowns = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    _actualHoursController.dispose();
    _startDateController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Utils.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Utils.border,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null) {
        Utils.toast(
          context,
          'Pilih kategori pekerjaan terlebih dahulu',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
        return;
      }

      if (_selectedAssignedTo == null) {
        Utils.toast(
          context,
          'Pilih penanggung jawab (karyawan aktif) terlebih dahulu',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
        return;
      }

      final estimated =
          double.tryParse(_estimatedHoursController.text.trim()) ?? 0.0;
      final actual = double.tryParse(_actualHoursController.text.trim()) ?? 0.0;

      setState(() => _isSaving = true);

      if (isEdit) {
        await _dbHelper.updateTask(
          id: widget.taskToEdit!['id'] as int,
          categoryId: _selectedCategoryId!,
          assignedTo: _selectedAssignedTo!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          estimatedHours: estimated,
          actualHours: actual,
          startDate: _startDateController.text.trim().isNotEmpty
              ? _startDateController.text.trim()
              : null,
          deadline: _deadlineController.text.trim(),
        );
      } else {
        await _dbHelper.addTask(
          categoryId: _selectedCategoryId!,
          createdBy: 1, // Admin / user saat ini
          assignedTo: _selectedAssignedTo!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          status: _status,
          estimatedHours: estimated,
          actualHours: actual,
          startDate: _startDateController.text.trim().isNotEmpty
              ? _startDateController.text.trim()
              : null,
          deadline: _deadlineController.text.trim(),
        );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      Utils.toast(
        context,
        isEdit
            ? 'Pekerjaan berhasil diperbarui!'
            : 'Pekerjaan baru berhasil dibuat & ditugaskan!',
        ToastificationType.success,
        Icons.check,
        Utils.success,
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: isEdit ? 'Edit Pekerjaan' : 'Tambah Pekerjaan Baru',
      activeMenu: 'pekerjaan',
      child: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: Utils.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Utils.border, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Utils.border,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Navigation Row
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Utils.border,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Utils.border,
                              ),
                              label: const Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Utils.border,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isEdit
                                  ? 'Form Sunting Pekerjaan / Tugas'
                                  : 'Form Buat Pekerjaan Baru',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Utils.border,
                              ),
                            ),
                          ],
                        ),
                        Utils.smallSpace,
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 24),

                        // Section 1: Informasi Tugas
                        const Text(
                          'RINCIAN TUGAS & PENUGASAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        NeoTextField(
                          label: 'Judul Pekerjaan / Tugas',
                          placeholder: 'misal: Input data penjualan harian',
                          controller: _titleController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Judul pekerjaan wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Kategori & Penanggung Jawab
                        Row(
                          children: [
                            // Kategori Pekerjaan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KATEGORI PEKERJAAN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedCategoryId,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: _categories.map((c) {
                                      return DropdownMenuItem<int>(
                                        value: c['id'] as int,
                                        child: Text(
                                          c['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedCategoryId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Penanggung Jawab (Karyawan)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PENANGGUNG JAWAB (KARYAWAN)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedAssignedTo,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: _employees.map((e) {
                                      return DropdownMenuItem<int>(
                                        value: e['id'] as int,
                                        child: Text(
                                          '${e['full_name']} (${e['employee_code'] ?? 'Karyawan'})',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedAssignedTo = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Prioritas & Status
                        Row(
                          children: [
                            // Prioritas
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PRIORITAS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _priority,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'low',
                                        child: Text(
                                          'Rendah (Low)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'medium',
                                        child: Text(
                                          'Sedang (Medium)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'high',
                                        child: Text(
                                          'Tinggi (High)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'urgent',
                                        child: Text(
                                          'Mendesak (Urgent)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Utils.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(() => _priority = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Status Pekerjaan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STATUS PEKERJAAN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _status,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'not_started',
                                        child: Text(
                                          'Belum Mulai',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'in_progress',
                                        child: Text(
                                          'Sedang Dikerjakan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'review',
                                        child: Text(
                                          'Ditinjau (Review)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'completed',
                                        child: Text(
                                          'Selesai (Completed)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Utils.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(() => _status = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 24),

                        // Section 2: Estimasi Jam & Jadwal
                        const Text(
                          'ESTIMASI BEBAN & WAKTU PELAKSANAAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Estimasi Jam Kerja',
                                placeholder: 'misal: 8.0',
                                controller: _estimatedHoursController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Estimasi jam wajib diisi';
                                  }
                                  if (double.tryParse(val.trim()) == null) {
                                    return 'Gunakan angka (misal: 8.0)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoTextField(
                                label: 'Realisasi Jam Kerja (Actual)',
                                placeholder: 'misal: 4.0',
                                controller: _actualHoursController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Start Date Picker
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TANGGAL MULAI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _startDateController,
                                    readOnly: true,
                                    onTap: () =>
                                        _selectDate(_startDateController),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Utils.border,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Utils.border,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Deadline Date Picker
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DEADLINE / TENGGAT WAKTU',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _deadlineController,
                                    readOnly: true,
                                    onTap: () =>
                                        _selectDate(_deadlineController),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Deadline wajib diisi';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.event_busy,
                                        size: 18,
                                        color: Utils.danger,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Utils.border,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Utils.border,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 24),

                        // Section 3: Deskripsi & Instruksi
                        const Text(
                          'DESKRIPSI & INSTRUKSI TUGAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        NeoTextField(
                          label: 'Deskripsi Rincian Tugas (Opsional)',
                          placeholder: 'Jelaskan instruksi atau catatan khusus untuk karyawan...',
                          controller: _descriptionController,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 28),
                        // Submit & Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Utils.border,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: Utils.border,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 220,
                              height: 48,
                              child: NeoButton(
                                text: isEdit
                                    ? 'Simpan Perubahan'
                                    : 'Buat Pekerjaan',
                                isLoading: _isSaving,
                                onPressed: _handleSave,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
