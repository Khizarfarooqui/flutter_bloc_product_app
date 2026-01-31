import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial());
}
