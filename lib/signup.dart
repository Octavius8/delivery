import 'package:flutter/material.dart';
import '_config.dart';
import 'model/_model.dart';
import '_logging.dart';
import 'model/_user.dart';

class SignUp extends StatefulWidget {
  User user;
  SignUp({required this.user});

  @override
  SignUpState createState() => new SignUpState();
}

class SignUpState extends State<SignUp> {
  Logging log = new Logging();
  Future<bool>? status;
  String user_message = "Please fill in the below to Sign Up.";
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController otpController = new TextEditingController();
  bool OTPscreen = false;

  @override
  void initState() {
    super.initState();
  }

  void signUp() async {
    Model model = new Model(log: log);
    bool fieldsOk = validateFields();

    //All Is Ok
    if (fieldsOk) {
      user_message = "Please wait... ";
      setState(() {});
      widget.user.setFullName(firstNameController.text.trim() +
          " " +
          lastNameController.text.trim());
      widget.user.setPhoneNumber(phoneNumberController.text);
      widget.user.setRating(Config.USER_DEFAULTRATING);

      bool value = await model.sendSignUpRequest(
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          phoneNumberController.text);
      user_message =
          "An SMS has been sent to your number with the activation code";
      OTPscreen = true;
      otpController.text = "";
      setState(() {});
    }
    setState(() {});
  }

  void validateOTP() async {
    Model model = new Model(log: log);
    user_message = "Validating...";
    setState(() {});
    bool value = await model.validateOTP(
        firstNameController.text,
        lastNameController.text,
        phoneNumberController.text,
        otpController.text);
    if (value == true) {
      log.info(
          "Signup | validateOTP() | Validation passed, redirecting back to Main screen.");
      widget.user.setLoggedInStatus(true);
      user_message = "Validation Passed.";
      setState(() {});
      Navigator.pop(context);
    } else {
      log.info("Signup | validateOTP() | Validation failed.");
      user_message = "Activation Code Entered is Not Correct.";
      setState(() {});
    }
  }

  bool validateFields() {
    bool status = true;

    //First Name Checks
    if (firstNameController.text.trim() == "") {
      user_message = 'Please fill in the First Name field.';
      status = false;
    }

    RegExp regExp = new RegExp(r'[0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?~]');

    if (regExp.hasMatch(firstNameController.text.trim())) {
      user_message = "Please enter a valid First Name";
      status = false;
    }

    //Last Name Checks
    if (lastNameController.text.trim() == "") {
      user_message = 'Please fill in the your Last Name';
      status = false;
    }

    if (regExp.hasMatch(lastNameController.text.trim())) {
      user_message = "Please enter a valid Last Name";
      status = false;
    }

    //Phone Number Checks
    if (phoneNumberController.text == "" ||
        phoneNumberController.text.length < 10) {
      user_message = 'Please enter a valid Phone Number.';
      status = false;
    }

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(30),
          child: !OTPscreen
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Sign Up", style: TextStyle(fontSize: 30)),
                  Text(user_message),
                  TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(hintText: ("First Name"))),
                  TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(hintText: ("Last Name"))),
                  TextField(
                      controller: phoneNumberController,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: ("Phone Number (e.g. 09xxxxxxxx)"))),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Config.COLOR_ACCENTCOLOR),
                      onPressed: () {
                        signUp();
                      },
                      child: Text("Sign Up"))
                ])
              :
              //OTP Screen
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text("Enter Activation Number",
                          style: TextStyle(fontSize: 30),
                          textAlign: TextAlign.center),
                      Text(user_message, textAlign: TextAlign.center),
                      TextField(
                          controller: otpController,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: ("Activation Number"))),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Config.COLOR_ACCENTCOLOR),
                          onPressed: () {
                            validateOTP();
                          },
                          child: Text("Confirm")),
                      Text(""),
                      GestureDetector(
                          onTap: () {
                            user_message = "Please wait...";
                            setState(() {});
                            signUp();
                          },
                          child: Text("(Resend Activation Code)",
                              style: TextStyle(color: Config.COLOR_PENDING)))
                    ]),
        )));
  }
}
