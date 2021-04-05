class ProjectConstants {
  static var emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static var phoneRegExp = RegExp(r'(^(?:[+0]9)?[0-9]{9,12}$)');
  static var prefsEmail = 'email';
  static var prefsPassword = 'password';
  static var usersCollectionName = 'users';
  static var settingsCollectionName = 'settings';
  static var settingsContactCollectionName = 'contact';
  static var formsCollectionName = 'forms';
  static var groupsCollectionName = 'user_groups';
  static var completedFormsCollectionName = 'completedForms';
  static var selectedUsersCollectionName = 'selectedUsers';
  static var defaultQuestionSec = 60;
}