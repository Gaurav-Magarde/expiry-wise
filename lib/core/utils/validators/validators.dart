class Validators{
  static bool validateName({required String? name, int minLength = 1}){
    if(name == null || name.trim().isEmpty || name.length < minLength) return false;
    return true;
  }

  static bool validateExpiry({required String? expiry}) {
    try{
      return true;
    }catch(c){
      return false;
    }
  }

  static bool validateAmount({required String? amount}) {
    try{
      final amountNum = double.tryParse(amount??'');
      return amountNum!=null && amountNum>=1;
    }catch(c){
      return false;
    }
  }
}