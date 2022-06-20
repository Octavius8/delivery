import 'package:localstorage/localstorage.dart';
import '../_logging.dart';

class User {
  final LocalStorage userDataLocalStorage = new LocalStorage('user_data');
  Logging log = new Logging();

  // Get States
  int getUserId() {
    int user_id = userDataLocalStorage.getItem("user_id");
    return user_id;
  }

  String getFullName() {
    String fullName = userDataLocalStorage.getItem("fullname");
    return fullName;
  }

  String getPhoneNumber() {
    String msisdn = userDataLocalStorage.getItem("msisdn");
    return msisdn;
  }

  String getRating() {
    String rating = userDataLocalStorage.getItem("rating");
    return rating;
  }

  bool getIsLoggedInStatus() {
    String isLoggedIn = userDataLocalStorage.getItem("isLoggedIn");
    if (isLoggedIn == null || isLoggedIn == "false") return false;
    return true;
  }

  // Set States
  Future<bool> setUserId(int user_id) async {
    try {
      log.debug("User | setUserId | starting setUserId");
      await userDataLocalStorage.setItem("user_id", user_id);
      log.debug("User | setUserId | Function ended.");
    } catch (ex) {
      log.error("User | setUserId | " + ex.toString());
    }
    return true;
  }

  bool setFullName(String fullName) {
    userDataLocalStorage.setItem("fullname", fullName);
    return true;
  }

  bool setPhoneNumber(String msisdn) {
    userDataLocalStorage.setItem("msisdn", msisdn);
    return true;
  }

  Future<bool> setRating(int rating) async {
    try {
      log.debug("User | setRating | starting setRating");
      await userDataLocalStorage.setItem("rating", rating.toString());
      log.debug("User | setRating | Function ended.");
    } catch (ex) {
      log.error("User | setRating | " + ex.toString());
    }
    return true;
  }

  Future<bool> setLoggedInStatus(bool status) async {
    try {
      String value = "";
      if (status)
        value = "true";
      else
        value = "false";

      log.debug(
          "User | setLoggedInStatus | starting setLoggedInStatus value:$value");
      await userDataLocalStorage.setItem("isLoggedIn", value);
      log.debug("User | setLoggedInStatus | Function ended.");
    } catch (ex) {
      log.error("User | setLoggedInStatus | " + ex.toString());
    }
    return true;
  }
}
