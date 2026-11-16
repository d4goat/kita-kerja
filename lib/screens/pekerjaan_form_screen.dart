import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/task_controller.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/models/employee_model.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/repositories/employee_repository.dart';
import 'package:kita_kerja/repositories/master_data_repository.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class PekerjaanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? taskToEdit;

  const PekerjaanFormScreen({super.key, this.taskToEdit});

  @override
  State<PekerjaanFormScreen> createState() => _PekerjaanFormScreenState();
}

class _PekerjaanFormScreenState extends State<PekerjaanFormScreen> {
  final _formKey = GlobalKey<FormState>();

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
    final masterRepo = MasterDataRepository();
    final categories = (await masterRepo.getJobCategories()).map((e) => e.toMap()).toList();
    final empRepo = EmployeeRepository();
    final empResult = await empRepo.getEmployees(status: 'active', pageSize: 100);
    final employees = (empResult['data'] as List<EmployeeModel>).map((e) => e.toMap()).toList();

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _employees = employees;

      if (!isEdit) {
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first['id'] as int;
        }
        if (_employees.isNotEmpty) {
          _selectedAssignedTo = _employees.first['id'] as int;
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

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null || _selectedAssignedTo == null) {
        Utils.toast(
          context,
          'Harap pilih kategori dan penanggung jawab pekerjaan.',
          ToastificationType.warning,
          Icons.warning,
          Utils.neoYellow,
        );
        return;
      }

      final estimated =
          double.tryParse(_estimatedHoursController.text.trim()) ?? 0.0;
      final actual = double.tryParse(_actualHoursController.text.trim()) ?? 0.0;

      setState(() => _isSaving = true);

      try {
        final taskCtrl = context.read<TaskController>();
        final currentUser = context.read<AuthController>().currentUser;

        final task = TaskModel(
          id: isEdit ? (widget.taskToEdit!['id'] as int) : 0,
          categoryId: _selectedCategoryId!,
          createdBy: currentUser?.id ?? 1,
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

        if (isEdit) {
          await taskCtrl.updateTask(task, currentUser);
        } else {
          await taskCtrl.addTask(task, currentUser);
        }

        if (!mounted) return;
        setState(() => _isSaving = false);

        Utils.toast(
          context,
          isEdit
              ? 'Pekerjaan berhasil diperbarui!'
              : 'Pekerjaan baru berhasil dibuat!',
          ToastificationType.success,
          Icons.check,
          Utils.neoGreen,
        );

        Navigator.pop(context, true);
      } catch (err) {
        if (!mounted) return;
        setState(() => _isSaving = false);

        Utils.toast(
          context,
          'Gagal menyimpan pekerjaan: $err',
          ToastificationType.error,
          Icons.close,
          Utils.neoRed,
        );
      }
    }
  }

  InputDecoration _dropdownDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Utils.neoCream,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: Utils.borderSideW,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: Utils.borderSideW,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: Utils.borderSideW,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: isEdit ? 'Edit Pekerjaan' : 'Tambah Pekerjaan',
      activeMenu: 'pekerjaan',
      child: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: Utils.neoBlack))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Utils.neoCream,
                    borderRadius: BorderRadius.zero,
                    border: Utils.borderW,
                    boxShadow: Utils.shadowLg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEdit ? 'UBAH PEKERJAAN' : 'BUAT PEKERJAAN BARU',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                              ),
                            ),
                            NeoButton(
                              text: 'Kembali',
                              size: NeoButtonSize.sm,
                              variant: NeoButtonVariant.neutral,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Utils.neoBlack, thickness: 2, height: 2),
                        const SizedBox(height: 24),

                        // Judul & Deskripsi
                        NeoTextField(
                          label: 'Judul Pekerjaan / Tugas*',
                          placeholder: 'Misal: Perbaiki bug halaman login',
                          controller: _titleController,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Judul pekerjaan wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        NeoTextField(
                          label: 'Deskripsi Detail Pekerjaan',
                          placeholder: 'Rincian tugas yang perlu diselesaikan...',
                          controller: _descriptionController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Kategori & Penanggung Jawab
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KATEGORI PEKERJAAN*',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Utils.neoBlack, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedCategoryId,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _categories.map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['name'].toString()))).toList(),
                                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PENANGGUNG JAWAB (KARYAWAN)*',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Utils.neoBlack, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedAssignedTo,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _employees.map((e) => DropdownMenuItem<int>(
                                      value: e['id'] as int,
                                      child: Text('${e['full_name']} (${e['employee_code']})'),
                                    )).toList(),
                                    onChanged: (val) => setState(() => _selectedAssignedTo = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Prioritas Pekerjaan (Radio 4 pilihan)
                        Text(
                          'PRIORITAS TUGAS*',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Utils.neoBlack, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPriorityOption('low', 'RENDAH'),
                            const SizedBox(width: 12),
                            _buildPriorityOption('medium', 'SEDANG'),
                            const SizedBox(width: 12),
                            _buildPriorityOption('high', 'TINGGI'),
                            const SizedBox(width: 12),
                            _buildPriorityOption('urgent', 'URGENT'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Estimasi & Jam Aktual
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Estimasi Jam Kerja*',
                                placeholder: '8.0',
                                controller: _estimatedHoursController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoTextField(
                                label: 'Jam Aktual Terpakai',
                                placeholder: '0.0',
                                controller: _actualHoursController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tanggal Mulai & Deadline
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Tanggal Mulai (YYYY-MM-DD)',
                                placeholder: '2026-11-16',
                                controller: _startDateController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoTextField(
                                label: 'Deadline Selesai (YYYY-MM-DD)*',
                                placeholder: '2026-11-20',
                                controller: _deadlineController,
                                validator: (val) => val == null || val.trim().isEmpty ? 'Deadline wajib diisi' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Footer Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NeoButton(
                              text: 'Batal',
                              variant: NeoButtonVariant.neutral,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 14),
                            NeoButton(
                              text: isEdit ? 'Simpan Perubahan' : 'Buat Pekerjaan',
                              variant: NeoButtonVariant.primary,
                              isLoading: _isSaving,
                              onPressed: _handleSave,
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

  Widget _buildPriorityOption(String val, String label) {
    final isSelected = _priority.toLowerCase() == val.toLowerCase();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _priority = val),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Utils.neoYellow : Utils.neoCream,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: isSelected ? Utils.shadowMd : Utils.shadowNone,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoBadge.taskPriority(val),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 16, color: Utils.neoBlack),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
