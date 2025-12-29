import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';


final authRepositoryProvider = Provider((ref){
  return AuthenticationRepository();
});
class AuthenticationRepository{

  final auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> loginWithGoogle() async {
      try {
        final instance =  GoogleSignIn();
        await instance.signOut();
        final GoogleSignInAccount? googleUser = await instance.signIn();
        // ya supportsAuthenticate() ke hisaab se

        if (googleUser == null) {
          return null;
        }


        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        final user =  await FirebaseAuth.instance.signInWithCredential(credential);
        return user;

      } on FirebaseAuthException catch (e){
        throw TFirebaseAuthException(e.code).message;
      } on PlatformException catch (e){
        throw TPlatformException(e.code).message;
      } on FormatException catch (e){
        throw TFormatException(e.message).message;
      } on FirebaseException catch (e){
        throw TFirebaseException(e.code).message;
      }on Exception {
        throw TExceptions().message;
      }catch (e){
        throw 'some went wrong';
      }

  }

}