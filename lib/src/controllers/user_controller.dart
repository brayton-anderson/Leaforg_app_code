//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pinput/pin_put/pin_put.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  Userss user = new Userss();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final fires.Auth _auth = fires.auth();
  //GlobalKey<ScaffoldMessengerState> scaffoldKey;
  //FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  var infoColor = Color(0xFFFFC001);
  var errorColor = Color(0xFFDE3F44);
  var successColor = Theme.of(Get.context).secondaryHeaderColor;

  UserController() {
    loader = Helper.overlayLoader(Get.context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    //this.scaffoldKey = new GlobalKey<ScaffoldMessengerState>();
    // _firebaseMessaging = FirebaseMessaging.instance;
    // _firebaseMessaging.getToken().then((String _deviceToken) {
    //     user.deviceToken = _deviceToken;
    //   }).catchError((e) {
    //     print('Notification not configured');
    //   });
  }

  get credential => null;

  void login() async {
    Get.focusScope.unfocus();
    //FocusScope.of(Get.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();

      Overlay.of(Get.overlayContext).insert(loader);
      //registerVerifyPhone(Get.context);
      print(user);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(Get.context)
              .pushReplacementNamed('/Pages', arguments: 2);
          // registerVerifyPhone(Get.context);
        } else {
          Get.snackbar(
            "Hi",
            "Leaforg",
            showProgressIndicator: false,
            duration: Duration(seconds: 5),
            snackStyle: SnackStyle.FLOATING,
            maxWidth: MediaQuery.of(Get.context).size.width - 200,
            backgroundColor: infoColor,
            messageText: Text(
              S.of(Get.context).wrong_email_or_password,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          );
          loader.remove();
        }
      }).catchError((e) {
        loader.remove();
        Get.snackbar(
          "Hi",
          "Leaforg",
          showProgressIndicator: false,
          duration: Duration(seconds: 5),
          snackStyle: SnackStyle.FLOATING,
          maxWidth: MediaQuery.of(Get.context).size.width - 200,
          backgroundColor: errorColor,
          messageText: Text(
            S.of(Get.context).this_account_not_exist,
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        );
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    Get.focusScope.unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(Get.overlayContext).insert(loader);
      print(user);
      repository.register(user).then((value) {
        print(value);
        if (value != null && value.apiToken != null) {
          Navigator.of(Get.context)
              .pushReplacementNamed('/Pages', arguments: 2);
          // Navigator.of(scaffoldKey.currentContext)
          //     .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          Get.snackbar(
            "Hi",
            "Leaforg",
            showProgressIndicator: false,
            duration: Duration(seconds: 5),
            snackStyle: SnackStyle.FLOATING,
            maxWidth: MediaQuery.of(Get.context).size.width - 200,
            backgroundColor: infoColor,
            messageText: Text(
              S.of(Get.context).wrong_email_or_password,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          );
        }
      }).catchError((e) {
        Get.snackbar(
          "Hi",
          "Leaforg",
          showProgressIndicator: false,
          duration: Duration(seconds: 2),
          snackStyle: SnackStyle.FLOATING,
          maxWidth: MediaQuery.of(Get.context).size.width - 200,
          backgroundColor: errorColor,
          messageText: Text(
            S.of(Get.context).this_email_account_exists,
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        );
        loader?.remove();
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void resetPassword() {
    Get.focusScope.unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(Get.overlayContext).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          Get.snackbar(
            "Hi",
            "${S.of(Get.context).your_reset_link_has_been_sent_to_your_email}",
          );
          // scaffoldKey?.currentState?.showSnackBar(SnackBar(
          //   content: ,
          //   action: SnackBarAction(
          //     label: S.of(Get.context).login,
          //     onPressed: () {
          //       Navigator.of(Get.context).pushReplacementNamed('/Login');
          //     },
          //   ),
          //   duration: Duration(seconds: 10),
          // ));
        } else {
          loader.remove();
          Get.snackbar(
            "Hi",
            "${S.of(Get.context).error_verify_email_settings}",
          );
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  String _verificationId;
  String otp, authStatus = "";
  String errorMessage = '';
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(255, 255, 255, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  Future<void> registerVerifyPhone(BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: user.phone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((value) async {
              if (value.user != null) {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Pages', arguments: 2);
              }
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            print(e.message);
            Get.snackbar(
              "Hi",
              "Leaforg",
              showProgressIndicator: false,
              duration: Duration(seconds: 5),
              snackStyle: SnackStyle.FLOATING,
              maxWidth: MediaQuery.of(Get.context).size.width - 200,
              backgroundColor: errorColor,
              messageText: Text(
                "Sorry!, We are unable to verify ${user.phone}. Please again.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            );
          },
          codeSent: (String verficationID, int resendToken) {
            setState(() {
              _verificationId = verficationID;
            });
            registerotp(Get.context).then((value) {});
          },
          codeAutoRetrievalTimeout: (String verificationID) {
            setState(() {
              _verificationId = verificationID;
            });
          },
          timeout: Duration(seconds: 120));
    } catch (e) {
      loader?.remove();
      Get.snackbar(
        "Hi",
        "Leaforg",
        showProgressIndicator: false,
        duration: Duration(seconds: 5),
        snackStyle: SnackStyle.FLOATING,
        maxWidth: MediaQuery.of(Get.context).size.width - 200,
        backgroundColor: errorColor,
        messageText: Text(
          "Sorry!, ${user.phone} an Error just happened. Please again.",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );
    }
  }

  Future<bool> registerotp(BuildContext context) {
    user.email;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter OTP sent to ${user.phone}'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PinPut(
                fieldsCount: 6,
                textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                eachFieldWidth: 40.0,
                eachFieldHeight: 55.0,
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                submittedFieldDecoration: pinPutDecoration,
                selectedFieldDecoration: pinPutDecoration,
                followingFieldDecoration: pinPutDecoration,
                pinAnimationType: PinAnimationType.fade,
                onSubmit: (pin) async {
                  try {
                    await FirebaseAuth.instance
                        .signInWithCredential(PhoneAuthProvider.credential(
                            verificationId: _verificationId, smsCode: pin))
                        .then((value) async {
                      if (value.user != null) {
                        Navigator.of(scaffoldKey.currentContext)
                            .pushReplacementNamed('/Pages', arguments: 2);

                        //Navigator.of(context).pushNamed('/PasswordsResets');
                      }
                    });
                  } catch (e) {
                    FocusScope.of(context).unfocus();
                    Get.snackbar(
                      "Hi",
                      "Leaforg",
                      showProgressIndicator: false,
                      duration: Duration(seconds: 5),
                      snackStyle: SnackStyle.FLOATING,
                      maxWidth: MediaQuery.of(Get.context).size.width - 200,
                      backgroundColor: infoColor,
                      messageText: Text(
                        "Sorry!, invalid OTP.",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }
                },
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            // actions: <Widget>[
            //   FlatButton(
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //       firebaseRepo.signIn(otp);
            //     },
            //     child: Text(
            //       'Submit',
            //     ),
            //   ),
            // ],
          );
        });
  }
}
