import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardInitial());
}
