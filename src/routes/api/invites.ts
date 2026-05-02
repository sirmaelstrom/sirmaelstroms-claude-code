import { validateEmailAndName } from "./_validation";

function handleCreateInvite(req: Request) {
  const validationError = validateEmailAndName(req.body.email, req.body.name);
  if (validationError) return validationError;

  // ... create invite
}
