import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:toastification/toastification.dart';

class KaryawanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? employeeToEdit;

  const KaryawanFormScreen({super.key, this.employeeToEdit});

  @override
  State<KaryawanFormScreen> createState() => _KaryawanFormScreenState();
}

class _KaryawanFormScreenState extends State<KaryawanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MySQLHelper _dbHelper = MySQLHelper();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _joinDateController;

  int? _selectedPositionId;
  int? _selectedDepartmentId;
  int? _selectedSalaryTypeId;
  int? _selectedWorkScheduleId;
  String _status = 'active';

  List<Map<String, dynamic>> _positions = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _salaryTypes = [];
  List<Map<String, dynamic>> _workSchedules = [];

  bool _isLoadingDropdowns = true;
  bool _isSaving = false;

  bool get isEdit => widget.employeeToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.employeeToEdit;

    _codeController = TextEditingController(
      text: isEdit ? item!['employee_code'].toString() : 'EMP007',
    );
    _nameController = TextEditingController(
      text: isEdit ? item!['full_name'].toString() : '',
    );
    _emailController = TextEditingController(
      text: isEdit ? (item!['email'] ?? '').toString() : '',
    );
    _phoneController = TextEditingController(
      text: isEdit ? (item!['phone'] ?? '').toString() : '',
    );
    _joinDateController = TextEditingController(
      text: isEdit
          ? item!['join_date'].toString()
          : DateTime.now().toString().split(' ')[0],
    );

    if (isEdit) {
      _selectedPositionId = item!['position_id'] as int?;
      _selectedDepartmentId = item['department_id'] as int?;
      _selectedSalaryTypeId = item['salary_type_id'] as int?;
      _selectedWorkScheduleId = item['work_schedule_id'] as int?;
      _status = item['status'].toString();
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final positions = await _dbHelper.getPositions();
    final departments = await _dbHelper.getDepartments();
    final salaryTypes = await _dbHelper.getSalaryTypes();
    final workSchedules = await _dbHelper.getWorkSchedules();

    if (!mounted) return;
    setState(() {
      _positions = positions;
      _departments = departments;
      _salaryTypes = salaryTypes;
      _workSchedules = workSchedules;

      if (!isEdit) {
        if (_positions.isNotEmpty) {
          _selectedPositionId = _positions.first['id'] as int;
        }
        if (_departments.isNotEmpty) {
          _selectedDepartmentId = _departments.first['id'] as int;
        }
        if (_salaryTypes.isNotEmpty) {
          _selectedSalaryTypeId = _salaryTypes.first['id'] as int;
        }
        if (_workSchedules.isNotEmpty) {
          _selectedWorkScheduleId = _workSchedules.first['id'] as int;
        }
      }
      _isLoadingDropdowns = false;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  Future<void> _selectJoinDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
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
        _joinDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPositionId == null ||
          _selectedDepartmentId == null ||
          _selectedSalaryTypeId == null ||
          _selectedWorkScheduleId == null) {
        Utils.toast(
          context,
          'Harap pilih semua referensi master data (Jabatan, Departemen, Gaji, Jadwal)',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
        return;
      }

      setState(() => _isSaving = true);

      if (isEdit) {
        await _dbHelper.updateEmployee(
          id: widget.employeeToEdit!['id'] as int,
          employeeCode: _codeController.text.trim(),
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          positionId: _selectedPositionId!,
          departmentId: _selectedDepartmentId!,
          salaryTypeId: _selectedSalaryTypeId!,
          workScheduleId: _selectedWorkScheduleId!,
          joinDate: _joinDateController.text.trim(),
          status: _status,
        );
      } else {
        await _dbHelper.addEmployee(
          employeeCode: _codeController.text.trim(),
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          positionId: _selectedPositionId!,
          departmentId: _selectedDepartmentId!,
          salaryTypeId: _selectedSalaryTypeId!,
          workScheduleId: _selectedWorkScheduleId!,
          joinDate: _joinDateController.text.trim(),
          status: _status,
        );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      Utils.toast(
        context,
        isEdit
            ? 'Data karyawan berhasil diperbarui!'
            : 'Karyawan baru berhasil ditambahkan!',
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
      title: isEdit ? 'Edit Data Karyawan' : 'Tambah Karyawan Baru',
      activeMenu: 'karyawan',
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
                        // Header Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                      ? 'Form Sunting Karyawan'
                                      : 'Form Registrasi Karyawan Baru',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Utils.border,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Utils.smallSpace,
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 24),

                        // Form Section 1: Data Utama Karyawan
                        const Text(
                          'INFORMASI PRIBADI & KONTAK',
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
                                label: 'Kode Karyawan (NIK)',
                                placeholder: 'misal: EMP007',
                                controller: _codeController,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Kode karyawan wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: NeoTextField(
                                label: 'Nama Lengkap Karyawan',
                                placeholder: 'Nama lengkap karyawan',
                                controller: _nameController,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Nama lengkap wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Email',
                                placeholder: 'karyawan@perusahaan.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoTextField(
                                label: 'Nomor Telepon / WhatsApp',
                                placeholder: '081234567890',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                        const SizedBox(height: 24),

                        // Form Section 2: Data Master Referensi
                        const Text(
                          'REFERENSI STRUKTUR & MASTER DATA',
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
                            // Position Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'JABATAN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedPositionId,
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
                                    items: _positions.map((p) {
                                      return DropdownMenuItem<int>(
                                        value: p['id'] as int,
                                        child: Text(
                                          p['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedPositionId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Department Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DEPARTEMEN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedDepartmentId,
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
                                    items: _departments.map((d) {
                                      return DropdownMenuItem<int>(
                                        value: d['id'] as int,
                                        child: Text(
                                          d['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedDepartmentId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Salary Type Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'JENIS GAJI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedSalaryTypeId,
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
                                    items: _salaryTypes.map((st) {
                                      return DropdownMenuItem<int>(
                                        value: st['id'] as int,
                                        child: Text(
                                          st['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedSalaryTypeId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Work Schedule Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'JADWAL KERJA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedWorkScheduleId,
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
                                    items: _workSchedules.map((ws) {
                                      return DropdownMenuItem<int>(
                                        value: ws['id'] as int,
                                        child: Text(
                                          ws['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Utils.border,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => _selectedWorkScheduleId = val,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Join Date Picker Field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TANGGAL BERGABUNG',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _joinDateController,
                                    readOnly: true,
                                    onTap: _selectJoinDate,
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
                            // Status Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STATUS KARYAWAN',
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
                                        value: 'active',
                                        child: Text(
                                          'Aktif',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text(
                                          'Nonaktif',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _status = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                  vertical: 14,
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
                                    : 'Tambah Karyawan',
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
