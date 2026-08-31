import '../models/booking.dart';

class BookingService {
  static List<Booking> bookings = [];

  static bool isAlreadyBooked(String name, String service) {
    return bookings.any((b) => b.providerName == name && b.service == service);
  }

  static void addBooking(Booking booking) {
    bookings.add(booking);
  }
}
