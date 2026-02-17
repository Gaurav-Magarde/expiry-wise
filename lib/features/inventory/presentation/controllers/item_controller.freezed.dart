// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryScreenState {

 OrderBy get order; String? get searchText; bool get isItemLoading; String? get selectedChip;
/// Create a copy of InventoryScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryScreenStateCopyWith<InventoryScreenState> get copyWith => _$InventoryScreenStateCopyWithImpl<InventoryScreenState>(this as InventoryScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryScreenState&&(identical(other.order, order) || other.order == order)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.isItemLoading, isItemLoading) || other.isItemLoading == isItemLoading)&&(identical(other.selectedChip, selectedChip) || other.selectedChip == selectedChip));
}


@override
int get hashCode => Object.hash(runtimeType,order,searchText,isItemLoading,selectedChip);

@override
String toString() {
  return 'InventoryScreenState(order: $order, searchText: $searchText, isItemLoading: $isItemLoading, selectedChip: $selectedChip)';
}


}

/// @nodoc
abstract mixin class $InventoryScreenStateCopyWith<$Res>  {
  factory $InventoryScreenStateCopyWith(InventoryScreenState value, $Res Function(InventoryScreenState) _then) = _$InventoryScreenStateCopyWithImpl;
@useResult
$Res call({
 OrderBy order, String? searchText, bool isItemLoading, String? selectedChip
});




}
/// @nodoc
class _$InventoryScreenStateCopyWithImpl<$Res>
    implements $InventoryScreenStateCopyWith<$Res> {
  _$InventoryScreenStateCopyWithImpl(this._self, this._then);

  final InventoryScreenState _self;
  final $Res Function(InventoryScreenState) _then;

/// Create a copy of InventoryScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? searchText = freezed,Object? isItemLoading = null,Object? selectedChip = freezed,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderBy,searchText: freezed == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String?,isItemLoading: null == isItemLoading ? _self.isItemLoading : isItemLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedChip: freezed == selectedChip ? _self.selectedChip : selectedChip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryScreenState].
extension InventoryScreenStatePatterns on InventoryScreenState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryScreenState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryScreenState value)  $default,){
final _that = this;
switch (_that) {
case _InventoryScreenState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryScreenState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderBy order,  String? searchText,  bool isItemLoading,  String? selectedChip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryScreenState() when $default != null:
return $default(_that.order,_that.searchText,_that.isItemLoading,_that.selectedChip);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderBy order,  String? searchText,  bool isItemLoading,  String? selectedChip)  $default,) {final _that = this;
switch (_that) {
case _InventoryScreenState():
return $default(_that.order,_that.searchText,_that.isItemLoading,_that.selectedChip);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderBy order,  String? searchText,  bool isItemLoading,  String? selectedChip)?  $default,) {final _that = this;
switch (_that) {
case _InventoryScreenState() when $default != null:
return $default(_that.order,_that.searchText,_that.isItemLoading,_that.selectedChip);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryScreenState implements InventoryScreenState {
  const _InventoryScreenState({required this.order, this.searchText, required this.isItemLoading, this.selectedChip});
  

@override final  OrderBy order;
@override final  String? searchText;
@override final  bool isItemLoading;
@override final  String? selectedChip;

/// Create a copy of InventoryScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryScreenStateCopyWith<_InventoryScreenState> get copyWith => __$InventoryScreenStateCopyWithImpl<_InventoryScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryScreenState&&(identical(other.order, order) || other.order == order)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.isItemLoading, isItemLoading) || other.isItemLoading == isItemLoading)&&(identical(other.selectedChip, selectedChip) || other.selectedChip == selectedChip));
}


@override
int get hashCode => Object.hash(runtimeType,order,searchText,isItemLoading,selectedChip);

@override
String toString() {
  return 'InventoryScreenState(order: $order, searchText: $searchText, isItemLoading: $isItemLoading, selectedChip: $selectedChip)';
}


}

/// @nodoc
abstract mixin class _$InventoryScreenStateCopyWith<$Res> implements $InventoryScreenStateCopyWith<$Res> {
  factory _$InventoryScreenStateCopyWith(_InventoryScreenState value, $Res Function(_InventoryScreenState) _then) = __$InventoryScreenStateCopyWithImpl;
@override @useResult
$Res call({
 OrderBy order, String? searchText, bool isItemLoading, String? selectedChip
});




}
/// @nodoc
class __$InventoryScreenStateCopyWithImpl<$Res>
    implements _$InventoryScreenStateCopyWith<$Res> {
  __$InventoryScreenStateCopyWithImpl(this._self, this._then);

  final _InventoryScreenState _self;
  final $Res Function(_InventoryScreenState) _then;

/// Create a copy of InventoryScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? searchText = freezed,Object? isItemLoading = null,Object? selectedChip = freezed,}) {
  return _then(_InventoryScreenState(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderBy,searchText: freezed == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String?,isItemLoading: null == isItemLoading ? _self.isItemLoading : isItemLoading // ignore: cast_nullable_to_non_nullable
as bool,selectedChip: freezed == selectedChip ? _self.selectedChip : selectedChip // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
