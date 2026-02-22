import 'package:flutter/material.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/provider_bottom_nav.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/shift_repository.dart';
import '../../domain/entities/shift.dart';
import '../widgets/shift_card.dart';

class BolsaTrabajoPage extends StatefulWidget {
  const BolsaTrabajoPage({super.key});

  @override
  State<BolsaTrabajoPage> createState() => _BolsaTrabajoPageState();
}

class _BolsaTrabajoPageState extends State<BolsaTrabajoPage>
    with SingleTickerProviderStateMixin {
  final _shiftRepo = ShiftRepository();
  late TabController _tabController;

  List<Shift> openShifts = [];
  List<Shift> myShifts = [];
  bool isLoadingOpen = true;
  bool isLoadingMy = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadOpenShifts(),
      _loadMyShifts(),
    ]);
  }

  Future<void> _loadOpenShifts() async {
    try {
      final shifts = await _shiftRepo.getOpenShifts();
      if (mounted) {
        setState(() {
          openShifts = shifts;
          isLoadingOpen = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading open shifts: $e');
      if (mounted) {
        setState(() {
          isLoadingOpen = false;
        });
      }
    }
  }

  Future<void> _loadMyShifts() async {
    try {
      final shifts = await _shiftRepo.getMyShifts();
      if (mounted) {
        setState(() {
          myShifts = shifts;
          isLoadingMy = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading my shifts: $e');
      if (mounted) {
        setState(() {
          isLoadingMy = false;
        });
      }
    }
  }

  Future<void> _applyToShift(Shift shift) async {
    try {
      await _shiftRepo.applyToShift(shift.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postulación enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      debugPrint('Error applying to shift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al postularse'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 2),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary600,
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bolsa de Trabajo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trabaja en tiendas y gana dinero extra',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(text: 'Disponibles'),
                  Tab(text: 'Mis Turnos'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab: Open Shifts
            RefreshIndicator(
              onRefresh: _loadOpenShifts,
              child: _buildOpenShiftsList(),
            ),
            // Tab: My Shifts
            RefreshIndicator(
              onRefresh: _loadMyShifts,
              child: _buildMyShiftsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenShiftsList() {
    if (isLoadingOpen) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (openShifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay turnos disponibles',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Vuelve más tarde para ver nuevas oportunidades',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: openShifts.length,
      itemBuilder: (context, index) {
        final shift = openShifts[index];
        return ShiftCard(
          shift: shift,
          onApply: () => _applyToShift(shift),
          onTap: () {
            // TODO: Navigate to shift detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ver detalle de turno ${shift.id}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMyShiftsList() {
    if (isLoadingMy) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (myShifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes turnos asignados',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Postúlate a los turnos disponibles para empezar a trabajar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: myShifts.length,
      itemBuilder: (context, index) {
        final shift = myShifts[index];
        return ShiftCard(
          shift: shift,
          showApplyButton: false,
          onTap: () {
            // TODO: Navigate to shift detail or POS
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ir a turno ${shift.id}')),
            );
          },
        );
      },
    );
  }
}
