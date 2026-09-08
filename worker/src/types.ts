export type AppEnv = {
  Bindings: Env & { INVITE_CODE: string };
  Variables: { userId: string; tokenHash: string };
};
