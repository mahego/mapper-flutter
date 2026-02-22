/// Input validation rules for all forms in the application.
/// Centralized validators to ensure consistency across UI.
class InputValidators {
  // Prevent instantiation
  InputValidators._();

  /// Validates full name
  /// - Required
  /// - Min 2 characters
  /// - Max 100 characters
  /// - Only letters, spaces, hyphens, apostrophes
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    
    if (trimmed.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (trimmed.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    
    // Allow letters, spaces, hyphens, apostrophes
    if (!RegExp(r"^[a-zA-Záéíóúâêôãõäëïöüçñ\s\-']+$").hasMatch(trimmed)) {
      return 'El nombre contiene caracteres inválidos';
    }
    
    return null;
  }

  /// Validates phone number
  /// - Optional (null is valid)
  /// - Min 10 digits
  /// - Max 15 digits
  /// - Only digits, spaces, hyphen, plus, parentheses
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final trimmed = value.trim();
    
    if (!RegExp(r'^[0-9\-+\s()]+$').hasMatch(trimmed)) {
      return 'Teléfono contiene caracteres inválidos';
    }
    
    // Extract only digits to check length
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Teléfono debe tener al menos 10 dígitos';
    }
    
    if (digitsOnly.length > 15) {
      return 'Teléfono no puede exceder 15 dígitos';
    }
    
    return null;
  }

  /// Validates email address
  /// - Required
  /// - Valid email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final trimmed = value.trim();
    
    // Basic email validation pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Validates password for registration/new password
  /// - Required
  /// - Min 6 characters (backend: 8)
  /// - Backend recommends: uppercase, lowercase, numbers, special chars
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    // Optional: Enforce strong password
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(value)) {
    //   return 'Contraseña débil: usa mayúsculas, minúsculas, números y caracteres especiales';
    // }
    
    return null;
  }

  /// Validates current password (same as validatePassword)
  static String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña actual es requerida';
    }
    
    if (value.length < 6) {
      return 'Contraseña inválida';
    }
    
    return null;
  }

  /// Validates new password (same as validatePassword)
  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  /// Validates password confirmation
  /// - Required
  /// - Matches another password field
  static String? validatePasswordConfirmation(
    String? value,
    String? passwordToMatch,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != passwordToMatch) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Validates postal code (Mexican format: 5 digits)
  /// - Optional
  /// - Exactly 5 digits if provided
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Postal code is optional
    }
    
    final trimmed = value.trim();
    
    if (!RegExp(r'^\d{5}$').hasMatch(trimmed)) {
      return 'Código postal debe ser 5 dígitos';
    }
    
    return null;
  }

  /// Validates product quantity
  /// - Must be >= 1
  /// - Must be <= 999
  static String? validateQuantity(int? value) {
    if (value == null || value <= 0) {
      return 'La cantidad debe ser al menos 1';
    }
    
    if (value > 999) {
      return 'La cantidad no puede exceder 999';
    }
    
    return null;
  }

  /// Validates price (non-negative number)
  static String? validatePrice(double? value) {
    if (value == null || value < 0) {
      return 'El precio debe ser válido';
    }
    
    return null;
  }

  /// Validates optional notes/description field
  /// - Optional
  /// - Max 500 characters
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.length > 500) {
      return 'Las notas no pueden exceder 500 caracteres';
    }
    
    return null;
  }

  /// Validates search query
  /// - Optional
  /// - Trim whitespace
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Search is optional
    }
    
    if (value.trim().isEmpty) {
      return null; // Only whitespace
    }
    
    return null;
  }

  /// Validates address field
  /// - Required
  /// - Not just whitespace
  /// - Min 5 characters
  /// - Max 200 characters
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es requerida';
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'La dirección no puede estar vacía';
    }
    
    if (trimmed.length < 5) {
      return 'La dirección es muy corta';
    }
    
    if (trimmed.length > 200) {
      return 'La dirección es demasiado larga';
    }
    
    return null;
  }

  /// Validates state/province field
  /// - Optional
  /// - Max 50 characters
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return null; // State is optional
    }
    
    if (value.length > 50) {
      return 'El estado no puede exceder 50 caracteres';
    }
    
    return null;
  }

  /// Validates city field
  /// - Optional
  /// - Max 50 characters
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return null; // City is optional
    }
    
    if (value.length > 50) {
      return 'La ciudad no puede exceder 50 caracteres';
    }
    
    return null;
  }

  /// Validates colony/neighborhood field
  /// - Optional
  /// - Max 100 characters
  static String? validateColony(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Colony is optional
    }
    
    if (value.length > 100) {
      return 'La colonia no puede exceder 100 caracteres';
    }
    
    return null;
  }

  /// Validates saved address name
  /// - Required
  /// - Min 2 characters
  /// - Max 30 characters
  /// - Examples: "Casa", "Oficina", "Departamento"
  static String? validateAddressName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de dirección es requerido';
    }
    
    if (value.length < 2) {
      return 'Nombre debe tener al menos 2 caracteres';
    }
    
    if (value.length > 30) {
      return 'Nombre no puede exceder 30 caracteres';
    }
    
    return null;
  }

  /// Validates geographic coordinates
  /// - Latitude: [-90, 90]
  /// - Longitude: [-180, 180]
  static String? validateLatitude(double? value) {
    if (value == null) {
      return 'Latitud es requerida';
    }
    
    if (value < -90 || value > 90) {
      return 'Latitud debe estar entre -90 y 90';
    }
    
    return null;
  }

  static String? validateLongitude(double? value) {
    if (value == null) {
      return 'Longitud es requerida';
    }
    
    if (value < -180 || value > 180) {
      return 'Longitud debe estar entre -180 y 180';
    }
    
    return null;
  }

  /// Batch validation for forms
  /// Returns list of error messages (empty if all valid)
  static List<String> validateMultiple(Map<String, dynamic> fields) {
    final errors = <String>[];
    
    // Example usage in calling code:
    // errors.addAll(InputValidators.validateMultiple({
    //   'name': _nameController.text,
    //   'email': _emailController.text,
    //   'password': _passwordController.text,
    // }));
    
    return errors;
  }
}
