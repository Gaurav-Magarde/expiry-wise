import '../../data/model/space_model.dart';

class SpaceState{
  final List<SpaceModel> allSpaces;

  SpaceState(this.allSpaces);

  factory SpaceState.copyWith({required List<SpaceModel> allSpaces}){
    return SpaceState(allSpaces);
  }


}