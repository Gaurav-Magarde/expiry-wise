import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
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
  final sqf = ref.read(sqfLiteSetupProvider);
  final prefs = ref.read(prefsServiceProvider);
  return AuthenticationRepository(localDatabase: sqf,prefs: prefs);
});
class AuthenticationRepository{

  final auth = FirebaseAuth.instance;
  final SqfLiteSetup localDatabase;
  final PrefsService prefs;
  AuthenticationRepository({required this.localDatabase,required this.prefs,});
  Future<UserCredential?> loginWithGoogle() async {
      try {
        final instance =  GoogleSignIn();
        await instance.signOut();
        final GoogleSignInAccount? googleUser = await instance.signIn();

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
        throw 'something went wrong $e';
      }

  }

  Future<void> logOutUser()async{
    await FirebaseAuth.instance.signOut();
    await localDatabase.deleteDataBase();
    await prefs.clearAllPrefs();

  }

}