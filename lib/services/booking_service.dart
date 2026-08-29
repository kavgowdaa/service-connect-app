import '../models/booking.dart';
class BookingService {
  static List<Booking> bookings = []; // later replace with Firestore

  static bool isAlreadyBooked(name, service) {
    return bookings.any((b) => b.providerName == name && b.service == service);
  }
  static void addBooking(Booking b) => bookings.add(b);
}