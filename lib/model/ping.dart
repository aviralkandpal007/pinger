/// This is the class for the ping model here we can define the data it will
/// carry with it so that it will be easier for us to maintain the data object
/// and the specific type of data the pinger will ping to the certain widget
/// in the widget tree.
/// The pinger is a generic class which means it can handle any type of data in
/// the model making it much more easier to maintain a class
class Ping<T> {
  /// Constructor of the pinger class for initializing all the required type
  /// of the the user requires in the class
  Ping({required this.name, this.data});

  /// Define the name for the ping so that you can see it in your logs which
  /// pings are being made by the pinger thinking of this as a single generic
  /// model in the class which the user can extend to have multiple data model
  /// for different case
  final String name;

  /// This is the generic data value of the pinger class which held the value
  /// from starting to the ending of the ping model
  final T? data;
}
