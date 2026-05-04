sealed class UIState<T> {}

final class Initial<T> extends UIState<T> {}

final class Loading<T> extends UIState<T> {
  final T? data;
  Loading([this.data]);
}

final class Success<T> extends UIState<T> {
  final T data;
  Success(this.data);
}

final class Error<T> extends UIState<T> {
  final String message;
  Error(this.message);
}
