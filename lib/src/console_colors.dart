enum ConsoleColors {
  black('\x1B[30m'),
  red('\x1B[31m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  blue('\x1B[34m'),
  magenta('\x1B[35m'),
  cyan('\x1B[36m'),
  white('\x1B[37m'),
  reset('\x1B[0m');

  final String code;

  const ConsoleColors(this.code);

  static ConsoleColors fromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return black;
      case 'red':
        return red;
      case 'green':
        return green;
      case 'yellow':
        return yellow;
      case 'blue':
        return blue;
      case 'magenta':
        return magenta;
      case 'cyan':
        return cyan;
      case 'white':
        return white;
      default:
        return reset;
    }
  }

  @override
  String toString() => code;
}
