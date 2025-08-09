import 'dart:math' show pow;

int byte = pow(1024, 1).toInt();
int kilobyte = pow(1024, 2).toInt();
int megabyte = pow(1024, 3).toInt();
int gigabyte = pow(1024, 4).toInt();

String fromBytes(int bytes) {
  if (bytes < byte) return '$bytes B';
  if (bytes < kilobyte) return '${(bytes / byte).toStringAsFixed(2)} KB';
  if (bytes < megabyte) {
    return '${(bytes / kilobyte).toStringAsFixed(2)} MB';
  }
  if (bytes < gigabyte) {
    return '${(bytes / megabyte).toStringAsFixed(2)} GB';
  }
  return '${(bytes / gigabyte).toStringAsFixed(2)} TB';
}
