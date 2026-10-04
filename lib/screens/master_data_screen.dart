import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();

  int _selectedTabIndex = 0; // 0: Jabatan, 1: Departemen, 2: Kategori Pekerjaan, 3: Jenis Gaji, 4: Jadwal Kerja
  String _searchQuery = '';
  bool _isLoading = false;

  List<Map<String, dynamic>> _dataList = [];

  final _tabs = [
    {
      'title': 'Jabatan',
      'table': 'positions',
      'desc': 'Digunakan untuk mengelompokkan peran karyawan',
    },
    {
      'title': 'Departemen',
      'table': 'departments',
      'desc': 'Mengelompokkan divisi atau departemen kerja',
    },
    {
      'title': 'Kategori Pekerjaan',
      'table': 'job_categories',
      'desc': 'Digunakan dalam penugasan & kategori pekerjaan',
    },
    {
      'title': 'Jenis Gaji',
      'table': 'salary_types',
      'desc': 'Acuan komponen dan sistem gaji/kompensasi',
    },
    {
      'title': 'Jadwal Kerja',
      'table': 'work_schedules',
      'desc': 'Acuan jam kerja, absensi, dan estimasi kapasitas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> result = [];
    switch (_selectedTabIndex) {
      case 0:
        result = await _dbHelper.getPositions();
        break;
      case 1:
        result = await _dbHelper.getDepartments();
        break;
      case 2:
        result = await _dbHelper.getJobCategories();
        break;
      case 3:
        result = await _dbHelper.getSalaryTypes();
        break;
      case 4:
        result = await _dbHelper.getWorkSchedules();
        break;
    }
    if (!mounted) return;
    setState(() {
      _dataList = result;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? editItem}) {
    final isEdit = editItem != null;
    final nameController = TextEditingController(
      text: isEdit ? editItem['name'].toString() : '',
    );
    final descController = TextEditingController(
      text: isEdit ? (editItem['description'] ?? '').toString() : '',
    );

    // For Work Schedule (index 4)
    final startTimeController = TextEditingController(
      text: isEdit ? (editItem['start_time'] ?? '08:00:00') : '08:00:00',
    );
    final endTimeController = TextEditingController(
      text: isEdit ? (editItem['end_time'] ?? '17:00:00') : '17:00:00',
    );
    final breakMinutesController = TextEditingController(
      text: isEdit ? (editItem['break_minutes'] ?? 60).toString() : '60',
    );
    final workingHoursController = TextEditingController(
      text: isEdit ? (editItem['working_hours'] ?? 8.0).toString() : '8.0',
    );

    String status = isEdit ? editItem['status'].toString() : 'active';

    final tabTitle = _tabs[_selectedTabIndex]['title'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Utils.border, width: 2),
              ),
              title: Text(
                isEdit ? 'Ubah Data $tabTitle' : 'Tambah Data $tabTitle',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Utils.border,
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeoTextField(
                        label: 'Nama $tabTitle',
                        placeholder: 'Masukkan nama',
                        controller: nameController,
                      ),
                      const SizedBox(height: 12),
                      if (_selectedTabIndex != 4) ...[
                        NeoTextField(
                          label: 'Deskripsi',
                          placeholder: 'Keterangan tambahan',
                          controller: descController,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Jam Masuk',
                                placeholder: '08:00:00',
                                controller: startTimeController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NeoTextField(
                                label: 'Jam Pulang',
                                placeholder: '17:00:00',
                                controller: endTimeController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: NeoTextField(
                                label: 'Istirahat (Menit)',
                                placeholder: '60',
                                controller: breakMinutesController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NeoTextField(
                                label: 'Jam Kerja (Jam)',
                                placeholder: '8.00',
                                controller: workingHoursController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isEdit) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Utils.border,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
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
                              child: Text('Aktif'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Nonaktif (Soft Delete)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Utils.border, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Utils.border),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(dialogContext);

                    if (_selectedTabIndex == 4) {
                      // Schedule
                      final sTime = startTimeController.text.trim();
                      final eTime = endTimeController.text.trim();
                      final bMin =
                          int.tryParse(breakMinutesController.text) ?? 60;
                      final wHours =
                          double.tryParse(workingHoursController.text) ?? 8.0;

                      if (isEdit) {
                        await _dbHelper.updateWorkSchedule(
                          id: editItem['id'],
                          name: name,
                          startTime: sTime,
                          endTime: eTime,
                          breakMinutes: bMin,
                          workingHours: wHours,
                          status: status,
                        );
                      } else {
                        await _dbHelper.addWorkSchedule(
                          name: name,
                          startTime: sTime,
                          endTime: eTime,
                          breakMinutes: bMin,
                          workingHours: wHours,
                        );
                      }
                    } else {
                      final desc = descController.text.trim();
                      switch (_selectedTabIndex) {
                        case 0:
                          if (isEdit) {
                            await _dbHelper.updatePosition(
                              editItem['id'],
                              name,
                              desc,
                              status,
                            );
                          } else {
                            await _dbHelper.addPosition(name, desc);
                          }
                          break;
                        case 1:
                          if (isEdit) {
                            await _dbHelper.updateDepartment(
                              editItem['id'],
                              name,
                              desc,
                              status,
                            );
                          } else {
                            await _dbHelper.addDepartment(name, desc);
                          }
                          break;
                        case 2:
                          if (isEdit) {
                            await _dbHelper.updateJobCategory(
                              editItem['id'],
                              name,
                              desc,
                              status,
                            );
                          } else {
                            await _dbHelper.addJobCategory(name, desc);
                          }
                          break;
                        case 3:
                          if (isEdit) {
                            await _dbHelper.updateSalaryType(
                              editItem['id'],
                              name,
                              desc,
                              status,
                            );
                          } else {
                            await _dbHelper.addSalaryType(name, desc);
                          }
                          break;
                      }
                    }

                    _loadData();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Data berhasil diperbarui!'
                              : 'Data berhasil ditambahkan!',
                        ),
                        backgroundColor: Utils.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Utils.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Utils.border, width: 2),
                    ),
                  ),
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleToggleStatus(Map<String, dynamic> item) async {
    final currentStatus = item['status'].toString();
    final id = item['id'];
    final name = item['name'];

    final actionLabel = currentStatus == 'active' ? 'nonaktifkan' : 'aktifkan';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Utils.border, width: 2),
          ),
          title: Text(
            'Konfirmasi $actionLabel Data',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Utils.border,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin me-$actionLabel "$name"?\n data yang di nonaktifkan tidak akan di hapus secara permanen, anda bisa mengaktifkan-nya kembali nanti.',
            style: const TextStyle(fontSize: 13, color: Utils.border),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Utils.border, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Batal', style: TextStyle(color: Utils.border)),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogContext);
                switch (_selectedTabIndex) {
                  case 0:
                    await _dbHelper.togglePositionStatus(id, currentStatus);
                    break;
                  case 1:
                    await _dbHelper.toggleDepartmentStatus(id, currentStatus);
                    break;
                  case 2:
                    await _dbHelper.toggleJobCategoryStatus(id, currentStatus);
                    break;
                  case 3:
                    await _dbHelper.toggleSalaryTypeStatus(id, currentStatus);
                    break;
                  case 4:
                    await _dbHelper.toggleWorkScheduleStatus(id, currentStatus);
                    break;
                }
                _loadData();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Status "$name" berhasil diubah!'),
                    backgroundColor: Utils.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStatus == 'active'
                    ? Utils.danger
                    : Utils.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Utils.border, width: 2),
                ),
              ),
              child: Text(
                currentStatus == 'active' ? 'Nonaktifkan' : 'Aktifkan',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _dataList.where((item) {
      final name = item['name'].toString().toLowerCase();
      final desc = (item['description'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();

    return MainLayout(
      title: 'Data Master',
      activeMenu: 'master_data',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TABS HEADER (Neo-Brutalist Tabs)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                            _searchQuery = '';
                          });
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Utils.secondary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Utils.border, width: 2),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Utils.border,
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                tab['title']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: Utils.border,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // 2. TAB INFO & SQL TOGGLE BAR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Utils.border, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Utils.border,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Utils.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Utils.border, width: 2),
                    ),
                    child: const Icon(
                      Icons.dataset_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Master Data ${_tabs[_selectedTabIndex]['title']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Utils.border,
                          ),
                        ),
                        Text(
                          _tabs[_selectedTabIndex]['desc']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. ACTION BAR (Search Input + Tambah Data Button)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Utils.border, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Utils.border, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Cari data master...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Utils.border,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  height: 42,
                  child: NeoButton(
                    text: '+ Tambah Data',
                    backgroundColor: Utils.primary,
                    onPressed: () => _showAddEditDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. DATA TABLE
            NeoTable(
              isLoading: _isLoading,
              emptyIcon: Icons.folder_off_outlined,
              emptyText: 'Tidak ada data ditemukan',
              columnWidths: _selectedTabIndex == 4
                  ? const {
                      0: FlexColumnWidth(0.8),
                      1: FlexColumnWidth(2.0),
                      2: FlexColumnWidth(2.5),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.5),
                    }
                  : const {
                      0: FlexColumnWidth(0.8),
                      1: FlexColumnWidth(2.0),
                      2: FlexColumnWidth(3.0),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.5),
                    },
              headers: [
                const NeoTableHeaderCell('ID'),
                const NeoTableHeaderCell('NAMA'),
                NeoTableHeaderCell(
                  _selectedTabIndex == 4 ? 'WAKTU KERJA' : 'DESKRIPSI',
                ),
                const NeoTableHeaderCell('STATUS'),
                const NeoTableHeaderCell('AKSI'),
              ],
              rows: filteredList.map((item) {
                final isActive = item['status'] == 'active';
                return [
                  NeoTableCell(text: '#${item['id']}'),
                  NeoTableCell(text: item['name'].toString(), isBold: true),
                  NeoTableCell(
                    text: _selectedTabIndex == 4
                        ? '${item['start_time']} - ${item['end_time']} (${item['working_hours']} Jam)'
                        : (item['description'] ?? '-').toString(),
                  ),
                  NeoTableCell(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE2F9E5)
                              : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Utils.border, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Utils.border,
                              blurRadius: 0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? const Color(0xFF1B7F2D)
                                : Utils.danger,
                          ),
                        ),
                      ),
                    ),
                  ),
                  NeoTableCell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            color: Utils.secondary,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 0,
                                color: Utils.border,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Ubah Data',
                            onPressed: () => _showAddEditDialog(editItem: item),
                          ),
                        ),
                        // Toggle Status Button (Soft Delete)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            color: isActive ? Utils.danger : Utils.success,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 0,
                                color: Utils.border,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isActive
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: isActive
                                ? 'Nonaktifkan (Soft Delete)'
                                : 'Aktifkan kembali',
                            onPressed: () => _handleToggleStatus(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
