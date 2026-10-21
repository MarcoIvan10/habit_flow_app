import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dashboard_filter_state.dart';

/// Manages the active [DashboardFilterState] including week navigation and category selection.
class DashboardFilterNotifier extends Notifier<DashboardFilterState> {
  @override
  DashboardFilterState build() => (
        weekOffset: 0,
        selectedCategory: 'Todas',
      );

  /// Shifts the active calendar window one week backward.
  void previousWeek() {
    state = (
      weekOffset: state.weekOffset - 1,
      selectedCategory: state.selectedCategory,
    );
  }

  /// Shifts the active calendar window one week forward, up to the current week (`0`).
  void nextWeek() {
    if (state.weekOffset >= 0) {
      return;
    }
    state = (
      weekOffset: state.weekOffset + 1,
      selectedCategory: state.selectedCategory,
    );
  }

  /// Resets the calendar window to the current week (`weekOffset: 0`).
  void resetToCurrentWeek() {
    state = (
      weekOffset: 0,
      selectedCategory: state.selectedCategory,
    );
  }

  /// Updates the active [category] filter.
  void selectCategory(String category) {
    state = (
      weekOffset: state.weekOffset,
      selectedCategory: category,
    );
  }
}

