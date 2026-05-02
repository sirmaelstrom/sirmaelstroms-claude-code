import { validateEmailAndName } from "./_validation";

function handleCreateUser(req: Request) {
  const validationError = validateEmailAndName(req.body.email, req.body.name);
  if (validationError) return validationError;

  // ... create user
}
