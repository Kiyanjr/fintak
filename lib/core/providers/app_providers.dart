
import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/data/models/app_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class AppStateNotifier extends StateNotifier<AppState>{
  final LocalDatasource _dataSource;
  AppStateNotifier(this._dataSource):super(const AppState()){
    _loadTheme();
  }
 Future<void>_loadTheme()async{
  final isDarkMode= await _dataSource.getTheme();
  state=state.copyWith(
    isDarkMode:isDarkMode,
  );
 }
 Future <void> toggleTheme() async{
  final newTheme=!state.isDarkMode;
  state=state.copyWith(
    isDarkMode:newTheme,
  );
  await _dataSource.saveTheme(newTheme);
 }
 void setUser(String id){
  state=state.copyWith(
    currentUserId: id,
  );
 }
 void clearUser(){
  state=state.copyWith(currentUserId: null);
 }
}

final appStateProvider=StateNotifierProvider<AppStateNotifier,AppState>((ref){
  final datasource=ref.watch(localDataSourceProvider).requireValue;
  return AppStateNotifier(datasource);
});