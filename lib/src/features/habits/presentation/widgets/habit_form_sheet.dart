import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/habit.dart';
import '../../domain/models/habit_form_payload.dart';

/// Modal bottom sheet form used to create a new habit or edit an existing [Habit].
class HabitFormSheet extends StatefulWidget {
  /// Creates a [HabitFormSheet].
  const HabitFormSheet({
    this.initialHabit,
    super.key,
  });

  /// Optional existing habit to pre-populate the form for editing.
  final Habit? initialHabit;

  /// Displays the [HabitFormSheet] modal and resolves with a [HabitFormPayload] when submitted.
  static Future<HabitFormPayload?> show(
    BuildContext context, {
    Habit? initialHabit,
  }) {
    return showModalBottomSheet<HabitFormPayload>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => HabitFormSheet(initialHabit: initialHabit),
    );
  }

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late String _selectedCategory;
  late String _selectedIcon;
  late String _selectedColor;

  bool get _isEditing => widget.initialHabit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.initialHabit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _selectedCategory = habit?.category ?? AppConstants.categories.first;
    _selectedIcon = habit?.icon ?? AppConstants.habitIcons.first;
    _selectedColor = habit?.color ?? AppConstants.accentColorKeys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final HabitFormPayload payload = (
      name: Validators.sanitizeText(_nameController.text),
      category: _selectedCategory,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accentColor = AppConstants.resolveHabitColor(_selectedColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDark ? AppColors.slate900 : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 16),
          child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate700 : AppColors.slate300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Editar Hábito' : 'Nuevo Hábito',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: !_isEditing,
                maxLength: AppConstants.maxHabitNameLength,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.validateHabitName,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Nombre del hábito',
                  hintText: 'Ej. Meditar 15 minutos, Leer 20 páginas...',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Categoría',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: accentColor,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.slate300 : AppColors.slate700),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 20),
              Text(
                'Icono',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.habitIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.18)
                            : (isDark
                                ? AppColors.slate800
                                : AppColors.slate100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 21),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 20),
              Text(
                'Color de acento',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 10,
                children: AppConstants.accentColorKeys.map((colorKey) {
                  final color = AppConstants.resolveHabitColor(colorKey);
                  final isSelected = colorKey == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorKey),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.slate900)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                ),
                onPressed: _submit,
                icon: Icon(
                  _isEditing ? Icons.save_outlined : Icons.add_rounded,
                ),
                label: Text(
                  _isEditing ? 'Guardar Cambios' : 'Crear Hábito',
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
}
