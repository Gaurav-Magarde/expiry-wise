class Validators{
  static bool validateName({required String? name, int minLength = 1}){
    if(name == null || name.trim().isEmpty || name.length < minLength) return false;
    return true;
  }

  static bool validateExpiry({required String? expiry}) {
    try{
      final now = DateTime.now();
      if(expiry==null || expiry.isEmpty) return false;
      return true;
    }catch(c){
      return false;
    }
  }
}