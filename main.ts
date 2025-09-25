import { PGlite } from '@electric-sql/pglite'
import { PGLiteSocketServer } from '@electric-sql/pglite-socket'

// Create a PGlite instance (in-memory by default; use { dataDir: '/data' } for persistence)
const db = await PGlite.create()

// Create and start a socket server on port 5432
const server = new PGLiteSocketServer({
  db,
  port: 5432,
  host: '0.0.0.0',  // Bind to all interfaces for Docker access
})

await server.start()
console.log('PGlite server started on 0.0.0.0:5432')

// Graceful shutdown
Deno.addSignalListener("SIGINT", async () => {
  await server.stop()
  await db.close()
  console.log('Server stopped and database closed')
  Deno.exit();
});
