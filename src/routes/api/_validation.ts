const MIN_NAME_LENGTH = 2;

type ValidationError = { status: 400; error: string };

export function validateEmailAndName(
  email: unknown,
  name: unknown
): ValidationError | null {
  if (!email || typeof email !== "string" || !email.includes("@")) {
    return { status: 400, error: "Invalid email" };
  }
  if (
    !name ||
    typeof name !== "string" ||
    name.length < MIN_NAME_LENGTH
  ) {
    return { status: 400, error: "Name too short" };
  }
  return null;
}
