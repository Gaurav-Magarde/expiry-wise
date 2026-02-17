import 'package:expiry_wise_app/core/utils/exception/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'exceptions.dart';
import 'firebase_auth_exceptions.dart';
import 'firebase_exceptions.dart';
import 'format_exceptions.dart';

mixin RepositoryErrorHandler{

  Future safeCall(Future Function() action) async {
    try{
      return await action();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'Something went wrong: $e';
    }
  }
}