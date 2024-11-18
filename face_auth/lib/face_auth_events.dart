/// `FaceAuthEvent` is an abstract class representing different types of events.
///
///It is used to create an instance of one of the event subclasses based
///on a map input, which comes from the SDK's result.
///
///Depending on the event type, it creates an instance of either
///`FaceAuthEventConnecting`, `FaceAuthEventConnected`,
///`FaceAuthEventClosed`, `FaceAuthEventFailure` or `FaceAuthEventSuccess`. If the event is not recognized,
///it throws an internal exception.
///
///This setup allows for a structured and type-safe way to handle different
///outcomes of the document capture process in the SDK.
abstract class FaceAuthEvent {
  bool get isFinal;

  static const connectingEvent = "connecting";
  static const connectedEvent = "connected";
  static const validatingEvent = "validating";
  static const validatedEvent = "validated";
  static const canceledEvent = "canceled";
  static const successEvent = "success";
  static const failureEvent = "failure";
  static const resultMappingError =
      "Unexpected error mapping the document_detector execution return";

  factory FaceAuthEvent.fromMap(Map map) {
    switch (map['event']) {
      case connectingEvent:
        return const FaceAuthEventConnecting();
      case connectedEvent:
        return const FaceAuthEventConnected();
      case validatingEvent:
        return const FaceAuthEventConnecting();
      case validatedEvent:
        return const FaceAuthEventConnected();
      case canceledEvent:
        return const FaceAuthEventClosed();
      case successEvent:
        return FaceAuthEventSuccess(map['signedResponse']);
      case failureEvent:
        return FaceAuthEventFailure(
            errorType: map["errorType"],
            errorDescription: map["errorDescription"]);
    }
    throw Exception(resultMappingError);
  }
}

/// The SDK is connecting to the server. You should provide an indeterminate progress indicator
/// to let the user know that the connection is taking place.
class FaceAuthEventConnecting implements FaceAuthEvent {
  @override
  get isFinal => false;

  const FaceAuthEventConnecting();
}

/// The SDK has connected, and the iProov user interface will now be displayed. You should hide
/// any progress indication at this point.
class FaceAuthEventConnected implements FaceAuthEvent {
  @override
  get isFinal => false;

  const FaceAuthEventConnected();
}

/// The user canceled iProov, either by pressing the close button at the top right, or sending
/// the app to the background.
class FaceAuthEventClosed implements FaceAuthEvent {
  @override
  get isFinal => true;

  const FaceAuthEventClosed();
}

/// The user was successfully verified/enrolled and the token has been validated.
class FaceAuthEventSuccess implements FaceAuthEvent {
  @override
  get isFinal => true;

  /// The JWT containing the information of the execution.
  final String? signedResponse;

  const FaceAuthEventSuccess(this.signedResponse);
}

/// The user was not successfully verified/enrolled, as their identity could not be verified,
/// or there was another issue with their verification/enrollment.
class FaceAuthEventFailure implements FaceAuthEvent {
  @override
  get isFinal => true;

  /// The failure type which can be captured to implement a specific use case for each.
  final String? errorType;

  /// The reason for the failure which can be displayed directly to the user.
  final String? errorDescription;

  const FaceAuthEventFailure({this.errorType, this.errorDescription});
}
