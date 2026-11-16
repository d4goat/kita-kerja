import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/employee_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/repositories/master_data_repository.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class KaryawanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? employeeToEdit;

  const KaryawanFormScreen({super.key, this.employeeToEdit});

  @override
  State<KaryawanFormScreen> createState() => _KaryawanFormScreenState();
}

class _KaryawanFormScreenState extends State<KaryawanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _joinDateController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  int? _selectedPositionId;
  int? _selectedDepartmentId;
  int? _selectedSalaryTypeId;
  int? _selectedWorkScheduleId;
  int? _selectedSupervisorId;
  String _status = 'active';

  List<Map<String, dynamic>> _positions = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _salaryTypes = [];
  List<Map<String, dynamic>> _workSchedules = [];
  List<Map<String, dynamic>> _supervisors = [];

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
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    if (isEdit) {
      _selectedPositionId = item!['position_id'] as int?;
      _selectedDepartmentId = item['department_id'] as int?;
      _selectedSalaryTypeId = item['salary_type_id'] as int?;
      _selectedWorkScheduleId = item['work_schedule_id'] as int?;
      _selectedSupervisorId = item['supervisor_id'] as int?;
      _status = item['status'].toString();
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final masterRepo = MasterDataRepository();
    final empCtrl = context.read<EmployeeController>();
    final positions =
        (await masterRepo.getPositions()).map((e) => e.toMap()).toList();
    final departments =
        (await masterRepo.getDepartments()).map((e) => e.toMap()).toList();
    final salaryTypes =
        (await masterRepo.getSalaryTypes()).map((e) => e.toMap()).toList();
    final workSchedules =
        (await masterRepo.getWorkSchedules()).map((e) => e.toMap()).toList();
    final supervisors = await empCtrl.getSupervisors();

    if (!mounted) return;
    setState(() {
      _positions = positions;
      _departments = departments;
      _salaryTypes = salaryTypes;
      _workSchedules = workSchedules;
      _supervisors = supervisors
          .where((s) =>
              !isEdit ||
              s['id'].toString() != widget.employeeToEdit!['id'].toString())
          .toList();

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPositionId == null ||
          _selectedDepartmentId == null ||
          _selectedSalaryTypeId == null ||
          _selectedWorkScheduleId == null) {
        Utils.toast(
          context,
          'Harap lengkapi semua pilihan referensi struktur data.',
          ToastificationType.warning,
          Icons.warning,
          Utils.neoYellow,
        );
        return;
      }

      setState(() => _isSaving = true);
      final empCtrl = context.read<EmployeeController>();

      try {
        if (isEdit) {
          await empCtrl.updateEmployee(
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
            supervisorId: _selectedSupervisorId,
          );
        } else {
          await empCtrl.addEmployee(
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
            password: _passwordController.text,
            supervisorId: _selectedSupervisorId,
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
          Utils.neoGreen,
        );

        Navigator.pop(context, true);
      } catch (err) {
        if (!mounted) return;
        setState(() => _isSaving = false);

        String errStr = err.toString();
        String errorMessage = 'Gagal menyimpan data karyawan: $errStr';

        if (errStr.contains('1062') ||
            errStr.toLowerCase().contains('duplicate entry')) {
          if (errStr.contains('employee_code')) {
            errorMessage =
                'Kode Karyawan (NIK) "${_codeController.text.trim()}" sudah terdaftar.';
          } else if (errStr.contains('email')) {
            errorMessage =
                'Email "${_emailController.text.trim()}" sudah terdaftar.';
          }
        }

        Utils.toast(
          context,
          errorMessage,
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
      title: isEdit ? 'Sunting Data Karyawan' : 'Registrasi Karyawan Baru',
      activeMenu: 'karyawan',
      child: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator(color: Utils.neoBlack))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 820),
                  padding: const EdgeInsets.all(28),
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
                        // Header Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                NeoButton(
                                  text: 'Kembali',
                                  variant: NeoButtonVariant.neutral,
                                  size: NeoButtonSize.sm,
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: Utils.neoBlack,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  isEdit
                                      ? 'Sunting Profil Karyawan'
                                      : 'Registrasi Karyawan Baru',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Utils.neoBlack, thickness: 2, height: 2),
                        const SizedBox(height: 20),

                        // Section 1: Informasi Pribadi & Kontak
                        Text(
                          'INFORMASI PRIBADI & KONTAK',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.neoBlack,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Kode Karyawan (NIK)*',
                                placeholder: 'misal: EMP007',
                                controller: _codeController,
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoTextField(
                                label: 'Nama Lengkap*',
                                placeholder: 'Nama lengkap karyawan',
                                controller: _nameController,
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Wajib diisi'
                                    : null,
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

                        // Password (only for Add)
                        if (!isEdit) ...[
                          const SizedBox(height: 20),
                          Text(
                            'AKUN LOGIN KARYAWAN',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Utils.neoBlack,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: NeoTextField(
                                  label: 'Kata Sandi*',
                                  placeholder: 'Minimal 8 karakter',
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Wajib diisi';
                                    if (val.length < 8) return 'Minimal 8 karakter';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: NeoTextField(
                                  label: 'Konfirmasi Kata Sandi*',
                                  placeholder: 'Ulangi kata sandi',
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Wajib diisi';
                                    if (val != _passwordController.text) return 'Tidak cocok';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                        const Divider(color: Utils.neoBlack, thickness: 2, height: 2),
                        const SizedBox(height: 24),

                        // Section 2: Struktur Organisasi & Supervisor
                        Text(
                          'JABATAN, STRUKTUR & SUPERVISOR',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.neoBlack,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Jabatan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JABATAN*',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedPositionId,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _positions
                                        .map((p) => DropdownMenuItem<int>(
                                              value: p['id'] as int,
                                              child: Text(p['name'].toString()),
                                            ))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedPositionId = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Departemen
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DEPARTEMEN*',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedDepartmentId,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _departments
                                        .map((d) => DropdownMenuItem<int>(
                                              value: d['id'] as int,
                                              child: Text(d['name'].toString()),
                                            ))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedDepartmentId = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Jenis Gaji
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JENIS KOMPENSASI GAJI*',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedSalaryTypeId,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _salaryTypes
                                        .map((s) => DropdownMenuItem<int>(
                                              value: s['id'] as int,
                                              child: Text(s['name'].toString()),
                                            ))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedSalaryTypeId = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Jadwal Kerja
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JADWAL KERJA*',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedWorkScheduleId,
                                    dropdownColor: Utils.neoCream,
                                    decoration: _dropdownDecoration(),
                                    items: _workSchedules
                                        .map((w) => DropdownMenuItem<int>(
                                              value: w['id'] as int,
                                              child: Text(w['name'].toString()),
                                            ))
                                        .toList(),
                                    onChanged: (val) => setState(
                                        () => _selectedWorkScheduleId = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Supervisor Tim Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ATASAN / SUPERVISOR TIM (EMPLOYEE SUPERVISORS)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int?>(
                              initialValue: _selectedSupervisorId,
                              dropdownColor: Utils.neoCream,
                              decoration: _dropdownDecoration(),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Tidak Ada / Mandiri'),
                                ),
                                ..._supervisors.map(
                                  (s) => DropdownMenuItem<int?>(
                                    value: int.tryParse(s['id'].toString()),
                                    child: Text(
                                      '${s['full_name']} (${s['position_name'] ?? s['employee_code']})',
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedSupervisorId = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Tanggal Bergabung (YYYY-MM-DD)*',
                                placeholder: '2026-11-16',
                                controller: _joinDateController,
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATUS KARYAWAN',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      NeoToggleSwitch(
                                        value: _status == 'active',
                                        onChanged: (val) => setState(
                                            () => _status = val ? 'active' : 'inactive'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        // Submit Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NeoButton(
                              text: 'Batal',
                              variant: NeoButtonVariant.neutral,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 16),
                            NeoButton(
                              text: isEdit ? 'Simpan Perubahan' : 'Tambah Karyawan',
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
}
