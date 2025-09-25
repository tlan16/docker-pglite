import { assertStringIncludes } from "https://deno.land/std@0.203.0/testing/asserts.ts";

Deno.test("main.ts contains PGlite and server setup", async () => {
  const src = await Deno.readTextFile("main.ts");
  assertStringIncludes(src, "PGlite.create()");
  assertStringIncludes(src, "PGLiteSocketServer");
  assertStringIncludes(src, "await server.start()");
  assertStringIncludes(src, "Deno.addSignalListener(\"SIGINT\"");
});

Deno.test("main.ts binds to 0.0.0.0 and uses port 5432", async () => {
  const src = await Deno.readTextFile("main.ts");
  assertStringIncludes(src, "port: 5432");
  assertStringIncludes(src, "host: '0.0.0.0'");
});

Deno.test("main.ts closes resources on SIGINT", async () => {
  const src = await Deno.readTextFile("main.ts");
  // Ensure stop/close calls are present in the signal handler
  assertStringIncludes(src, "await server.stop()");
  assertStringIncludes(src, "await db.close()");
});
