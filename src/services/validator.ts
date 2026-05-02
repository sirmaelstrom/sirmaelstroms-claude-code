interface User {
  email?: string;
  verified?: boolean;
}

interface Settings {
  requireVerified?: boolean;
}

interface ValidationResult {
  valid: boolean;
  user?: User;
  error?: string;
}

function validateUser(user: User, settings?: Settings): ValidationResult {
  if (!user) return { valid: false, error: 'User required' };
  if (!user.email) return { valid: false, error: 'Email required' };
  if (!user.email.includes('@')) return { valid: false, error: 'Invalid email' };
  if (settings?.requireVerified && !user.verified) return { valid: false, error: 'User not verified' };

  return { valid: true, user };
}
