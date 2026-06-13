  //  GLOBAL STAE OF THE APP
class AppState {
final bool isDarkMode;
final String? currentUserId;
  // checking the null of user is it ogged or not
static const _sentinel=Object();

const AppState({this.isDarkMode=false,this.currentUserId});

 AppState copyWith({bool? isDarkMode, Object? currentUserId=_sentinel,}){
  return AppState(
  isDarkMode:isDarkMode??this.isDarkMode,
 currentUserId: currentUserId == _sentinel
          ? this.currentUserId
          : currentUserId as String?,
  );
}
}